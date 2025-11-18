defmodule SpeakFirstAiWeb.StripeWebhookController do
  use SpeakFirstAiWeb, :controller

  alias SpeakFirstAi.{Repo, Accounts}
  alias SpeakFirstAi.Subscriptions.Subscription
  alias SpeakFirstAi.SubscriptionPlans.SubscriptionPlan

  plug :accepts, ["json"]

  def create(conn, _params) do
    with {:ok, payload, conn} <- read_raw_body(conn),
         {:ok, sig} <- fetch_signature(conn),
         {:ok, secret} <- fetch_secret(),
         :ok <- verify_signature(payload, sig, secret),
         {:ok, event} <- Jason.decode(payload) do
      process_event(event)
      json(conn, %{message: "success"})
    else
      {:error, :invalid_payload} -> json(conn |> put_status(400), %{error: "Invalid payload"})
      {:error, :invalid_signature} -> json(conn |> put_status(400), %{error: "Invalid signature"})
      {:error, :missing_secret} -> json(conn |> put_status(500), %{error: "Missing webhook secret"})
      {:error, _} -> json(conn |> put_status(400), %{error: "Bad request"})
    end
  end

  defp read_raw_body(conn) do
    case Plug.Conn.read_body(conn) do
      {:ok, body, conn} when is_binary(body) -> {:ok, body, conn}
      _ -> {:error, :invalid_payload}
    end
  end

  defp fetch_signature(conn) do
    case Plug.Conn.get_req_header(conn, "stripe-signature") do
      [sig | _] -> {:ok, sig}
      _ -> {:error, :invalid_signature}
    end
  end

  defp fetch_secret do
    case System.get_env("STRIPE_WEBHOOK_SECRET") do
      nil -> {:error, :missing_secret}
      secret when byte_size(secret) > 0 -> {:ok, secret}
    end
  end

  # Minimal Stripe signature verification based on their scheme: t=timestamp, v1=signature
  defp verify_signature(payload, sig_header, secret) do
    with %{"t" => t, "v1" => v1} <- parse_sig(sig_header),
         true <- secure_compare(hmac("#{t}.#{payload}", secret), v1) do
      :ok
    else
      _ -> {:error, :invalid_signature}
    end
  end

  defp parse_sig(sig_header) do
    sig_header
    |> String.split(",")
    |> Enum.reduce(%{}, fn kv, acc ->
      case String.split(kv, "=") do
        [k, v] -> Map.put(acc, String.trim(k), String.trim(v))
        _ -> acc
      end
    end)
  end

  defp hmac(data, secret) do
    :crypto.mac(:hmac, :sha256, secret, data) |> Base.encode16(case: :lower)
  end

  defp secure_compare(a, b) when is_binary(a) and is_binary(b) and byte_size(a) == byte_size(b) do
    Plug.Crypto.secure_compare(a, b)
  end

  defp secure_compare(_, _), do: false

  # Normalize Stripe structs to maps with string keys
  defp normalize_stripe_object(obj) when is_map(obj) do
    # If it's a struct, convert to map and then to string keys
    if Map.has_key?(obj, :__struct__) do
      obj
      |> Map.from_struct()
      |> Enum.map(fn {k, v} -> {Atom.to_string(k), normalize_stripe_value(v)} end)
      |> Map.new()
    else
      # Already a map, just ensure string keys
      Enum.map(obj, fn
        {k, v} when is_atom(k) -> {Atom.to_string(k), normalize_stripe_value(v)}
        {k, v} -> {k, normalize_stripe_value(v)}
      end)
      |> Map.new()
    end
  end

  defp normalize_stripe_object(obj), do: obj

  defp normalize_stripe_value(value) when is_map(value) do
    normalize_stripe_object(value)
  end

  defp normalize_stripe_value(value) when is_list(value) do
    Enum.map(value, &normalize_stripe_value/1)
  end

  defp normalize_stripe_value(value), do: value

  # Event processing
  defp process_event(%{"type" => type, "data" => %{"object" => obj}}) do
    case type do
      "customer.subscription.created" -> handle_subscription_upsert(obj)
      "customer.subscription.updated" -> handle_subscription_upsert(obj)
      "customer.subscription.deleted" -> handle_subscription_deleted(obj)
      "invoice.payment_failed" -> handle_payment_failed(obj)
      "invoice.payment_succeeded" -> handle_payment_succeeded(obj)
      "invoice.paid" -> handle_payment_succeeded(obj)
      "invoice_payment.paid" -> handle_invoice_payment_paid(obj)
      "checkout.session.completed" -> handle_checkout_session_completed(obj)
      "charge.succeeded" -> :ok
      "customer.subscription.paused" -> handle_pause_resume(obj, :paused)
      "customer.subscription.resumed" -> handle_pause_resume(obj, :active)
      "customer.subscription.trial_will_end" -> :ok
      _ -> :ok
    end
  end

  defp handle_subscription_upsert(obj) do
    user = find_user_by_customer_id(obj["customer"]) || nil
    plan_id = obj |> get_in(["items", "data"]) |> List.wrap() |> List.first() |> then(&(&1 && get_in(&1, ["price", "id"])) )
    subscription_plan = plan_id && Repo.get_by(SubscriptionPlan, stripe_price_id: plan_id)

    if user && subscription_plan do
      upsert_user_subscription(user.id, %{
        stripe_subscription_id: obj["id"],
        status: obj["status"],
        subscription_plan_id: subscription_plan.id,
        current_period_end: unix_to_datetime(get_in(obj, ["current_period_end"])) ||
          (obj |> get_in(["items", "data"]) |> List.wrap() |> List.first() |> then(&(&1 && get_in(&1, ["current_period_end"]))) |> unix_to_datetime()),
        cancel_at_period_end: obj["cancel_at_period_end"] || false
      })
    end
  end

  defp handle_subscription_deleted(obj) do
    with user when not is_nil(user) <- find_user_by_customer_id(obj["customer"]),
         %Subscription{} = sub <- Repo.get_by(Subscription, user_id: user.id) do
      Ecto.Changeset.change(sub, status: "canceled") |> Repo.update()
    else
      _ -> :ok
    end
  end

  defp handle_payment_failed(obj) do
    with user when not is_nil(user) <- find_user_by_customer_id(obj["customer"]),
         %Subscription{} = sub <- Repo.get_by(Subscription, user_id: user.id) do
      Ecto.Changeset.change(sub, status: "past_due") |> Repo.update()
    else
      _ -> :ok
    end
  end

  defp handle_payment_succeeded(obj) do
    handle_invoice_like(obj, "active")
  end

  defp handle_invoice_payment_paid(obj) do
    # invoice_payment.paid has a different structure - we need to fetch the invoice
    invoice_id = obj["invoice"]

    if invoice_id do
      case Stripe.Invoice.retrieve(invoice_id) do
        {:ok, invoice} ->
          normalized_invoice = normalize_stripe_object(invoice)
          handle_invoice_like(normalized_invoice, "active")
        {:error, _} ->
          :ok
      end
    else
      :ok
    end
  end

  defp handle_invoice_like(invoice, status) do
    user = find_user_by_customer_id(invoice["customer"]) || nil
    sub_id = get_in(invoice, ["subscription"]) ||
      (invoice["lines"] && invoice["lines"]["data"] |> List.wrap() |> List.first() |> then(&(&1 && &1["subscription"])))

    if user && sub_id do
      upsert_user_subscription(user.id, %{
        stripe_subscription_id: sub_id,
        status: status,
        plan: invoice |> get_in(["lines", "data"]) |> List.wrap() |> List.first() |> then(&(&1 && &1["description"])) ,
        current_period_end: invoice |> get_in(["lines", "data"]) |> List.wrap() |> List.first() |> then(&(&1 && get_in(&1, ["period", "end"]))) |> unix_to_datetime()
      })
    end
  end

  defp handle_checkout_session_completed(obj) do
    # For subscription mode, retrieve the subscription from the invoice
    if obj["mode"] == "subscription" do
      invoice_id = obj["invoice"]
      customer_id = obj["customer"]

      if invoice_id && customer_id do
        case Stripe.Invoice.retrieve(invoice_id) do
          {:ok, invoice} ->
            normalized_invoice = normalize_stripe_object(invoice)
            sub_id = normalized_invoice["subscription"]

            if sub_id do
              case Stripe.Subscription.retrieve(sub_id) do
                {:ok, subscription} ->
                  normalized_subscription = normalize_stripe_object(subscription)
                  handle_subscription_upsert(normalized_subscription)
                {:error, _} ->
                  :ok
              end
            else
              :ok
            end
          {:error, _} ->
            :ok
        end
      else
        :ok
      end
    else
      :ok
    end
  end

  defp handle_pause_resume(obj, status) do
    with user when not is_nil(user) <- find_user_by_customer_id(obj["customer"]),
         %Subscription{} = sub <- Repo.get_by(Subscription, user_id: user.id) do
      Ecto.Changeset.change(sub, status: Atom.to_string(status)) |> Repo.update()
    else
      _ -> :ok
    end
  end

  defp upsert_user_subscription(user_id, attrs) do
    case Repo.get_by(Subscription, user_id: user_id) do
      nil ->
        %Subscription{user_id: user_id}
        |> Subscription.changeset(attrs)
        |> Repo.insert()

      %Subscription{} = sub ->
        sub
        |> Subscription.changeset(attrs)
        |> Repo.update()
    end
  end

  defp unix_to_datetime(nil), do: nil
  defp unix_to_datetime(int) when is_integer(int), do: DateTime.from_unix!(int)

  defp find_user_by_customer_id(customer_id) when is_binary(customer_id) do
    Repo.get_by(Accounts.User, stripe_customer_id: customer_id)
  end

  defp find_user_by_customer_id(_), do: nil
end
