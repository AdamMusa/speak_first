defmodule SpeakFirstAiWeb.SubscriptionController do
  use SpeakFirstAiWeb, :controller

  import Ecto.Query

  alias SpeakFirstAi.{Subscriptions, Repo}
  alias SpeakFirstAi.Accounts.User

  plug :require_authenticated_user

  def create(conn, %{"plan_id" => plan_id}) do
    current_scope = conn.assigns.current_scope

    with {:ok, updated_user} <- ensure_stripe_customer(current_scope.user),
         {:ok, subscription_plan} <- get_subscription_plan(plan_id),
         {:ok, session} <- create_checkout_session(updated_user, subscription_plan) do
      redirect(conn, external: session.url)
    else
      {:error, %Stripe.Error{message: message}} ->
        conn
        |> put_status(:unprocessable_entity)
        |> text(message)

      {:error, reason} ->
        conn
        |> put_flash(:error, reason)
        |> redirect(to: ~p"/")
    end
  end

  def success(conn, _params) do
    conn
    |> put_flash(:info, "Subscription activated successfully!")
    |> redirect(to: ~p"/subscriptions")
  end

  def cancel(conn, _params) do
    redirect(conn, to: ~p"/")
  end

  def show(conn, params) do
    # If plan_id is in params, redirect to create subscription
    if plan_id = params["plan_id"] do
      create(conn, %{"plan_id" => plan_id})
    else
      show_subscription(conn)
    end
  end

  defp show_subscription(conn) do
    current_scope = conn.assigns.current_scope
    subscription = Subscriptions.get_user_subscription(current_scope.user)
    can_request_refund = subscription && Subscriptions.can_request_refund?(subscription)
    refund_deadline = subscription && Subscriptions.refund_deadline(subscription)

    # Fetch Pro and Elite plans for upgrade options
    available_plans = Repo.all(
      from(sp in SpeakFirstAi.SubscriptionPlans.SubscriptionPlan,
        where: sp.name in ["Pro", "Ultimate", "Elite"],
        where: sp.active == true
      )
    )

    current_plan_name = subscription && subscription.subscription_plan && subscription.subscription_plan.name
    is_basic = is_nil(current_plan_name) || String.downcase(current_plan_name) in ["free", "basic"]

    render(conn, :show,
      subscription: subscription,
      can_request_refund: can_request_refund,
      refund_deadline: refund_deadline,
      available_plans: available_plans,
      is_basic: is_basic
    )
  end

  def cancel_subscription(conn, _params) do
    current_scope = conn.assigns.current_scope
    subscription = Subscriptions.get_user_subscription(current_scope.user)

    if subscription && subscription.stripe_subscription_id do
      case Stripe.Subscription.update(subscription.stripe_subscription_id, %{
             cancel_at_period_end: true
           }) do
        {:ok, _stripe_sub} ->
          Subscriptions.update_cancel_at_period_end(subscription, true)

          conn
          |> put_flash(:info, "Subscription will be canceled at the end of the current billing period.")
          |> redirect(to: ~p"/subscriptions")

        {:error, %Stripe.Error{message: message}} ->
          conn
          |> put_flash(:error, "Error canceling subscription: #{message}")
          |> redirect(to: ~p"/subscriptions")
      end
    else
      conn
      |> put_flash(:error, "No active subscription found.")
      |> redirect(to: ~p"/subscriptions")
    end
  end

  def request_refund(conn, _params) do
    current_scope = conn.assigns.current_scope
    subscription = Subscriptions.get_user_subscription(current_scope.user)

    unless Subscriptions.can_request_refund?(subscription) do
      conn
      |> put_flash(:error, "Refund requests are only accepted within 7 days of subscription start.")
      |> redirect(to: ~p"/subscriptions")
    else
      case Stripe.Invoice.list(%{
             customer: current_scope.user.stripe_customer_id,
             subscription: subscription.stripe_subscription_id,
             limit: 1
           }) do
        {:ok, %{data: [invoice | _]}} ->
          case Stripe.Refund.create(%{
                 charge: invoice.charge,
                 reason: "requested_by_customer",
                 metadata: %{
                   user_id: current_scope.user.id,
                   subscription_id: subscription.id,
                   refund_requested_at: DateTime.utc_now() |> DateTime.to_iso8601()
                 }
               }) do
            {:ok, _refund} ->
              Subscriptions.upsert_subscription(subscription.user_id, %{status: "canceled"})

              conn
              |> put_flash(:info, "Refund request submitted successfully. Your subscription has been canceled.")
              |> redirect(to: ~p"/subscriptions")

            {:error, %Stripe.Error{message: message}} ->
              conn
              |> put_flash(:error, "Error processing refund: #{message}")
              |> redirect(to: ~p"/subscriptions")
          end

        {:ok, %{data: []}} ->
          conn
          |> put_flash(:error, "No invoice found for refund.")
          |> redirect(to: ~p"/subscriptions")

        {:error, %Stripe.Error{message: message}} ->
          conn
          |> put_flash(:error, "Error fetching invoice: #{message}")
          |> redirect(to: ~p"/subscriptions")
      end
    end
  end

  def upgrade(conn, %{"plan_id" => plan_id}) do
    current_scope = conn.assigns.current_scope
    user = current_scope.user
    subscription = Subscriptions.get_user_subscription(user)

    target_plan = Repo.get_by(SpeakFirstAi.SubscriptionPlans.SubscriptionPlan, stripe_price_id: plan_id)

    unless target_plan do
      conn
      |> put_flash(:error, "Plan not found.")
      |> redirect(to: ~p"/subscriptions")
    else
      # If user has no subscription, create a new one
      if is_nil(subscription) || is_nil(user.stripe_customer_id) do
        with {:ok, updated_user} <- ensure_stripe_customer(user),
             {:ok, session} <- create_checkout_session(updated_user, target_plan) do
          redirect(conn, external: session.url)
        else
          {:error, %Stripe.Error{message: message}} ->
            conn
            |> put_flash(:error, message)
            |> redirect(to: ~p"/subscriptions")

          {:error, reason} ->
            conn
            |> put_flash(:error, reason)
            |> redirect(to: ~p"/subscriptions")
        end
      else
        # Upgrade existing subscription
        case Stripe.Checkout.Session.create(%{
               customer: user.stripe_customer_id,
               payment_method_types: ["card"],
               line_items: [
                 %{
                   price: target_plan.stripe_price_id,
                   quantity: 1
                 }
               ],
               mode: "subscription",
               subscription_data: %{
                 trial_from_plan: false,
                 items: [
                   %{price: target_plan.stripe_price_id}
                 ],
                 default_tax_rates: [],
                 metadata: %{upgrade: true}
               },
               allow_promotion_codes: true,
               success_url: build_url(~p"/subscriptions") <> "?upgrade_success=1",
               cancel_url: build_url(~p"/subscriptions") <> "?upgrade_cancel=1",
               client_reference_id: subscription.stripe_subscription_id
             }) do
          {:ok, session} ->
            redirect(conn, external: session.url)

          {:error, %Stripe.Error{message: message}} ->
            conn
            |> put_flash(:error, message)
            |> redirect(to: ~p"/subscriptions")
        end
      end
    end
  end

  def upgrade(conn, _params) do
    # Fallback to Pro if no plan_id provided (backward compatibility)
    pro_plan =
      Repo.one(
        from(sp in SpeakFirstAi.SubscriptionPlans.SubscriptionPlan,
          where: sp.name == "Pro",
          limit: 1
        )
      )

    if pro_plan do
      upgrade(conn, %{"plan_id" => pro_plan.stripe_price_id})
    else
      conn
      |> put_flash(:error, "Pro plan not found.")
      |> redirect(to: ~p"/subscriptions")
    end
  end

  def update_payment_method(conn, _params) do
    current_scope = conn.assigns.current_scope

    unless current_scope.user.stripe_customer_id do
      conn
      |> put_flash(:error, "No Stripe customer found.")
      |> redirect(to: ~p"/subscriptions")
    else
      case Stripe.BillingPortal.Session.create(%{
             customer: current_scope.user.stripe_customer_id,
             return_url: build_url(~p"/subscriptions")
           }) do
        {:ok, session} ->
          redirect(conn, external: session.url)

        {:error, %Stripe.Error{message: message}} ->
          conn
          |> put_flash(:error, message)
          |> redirect(to: ~p"/subscriptions")
      end
    end
  end

  defp require_authenticated_user(conn, _opts) do
    if conn.assigns.current_scope && conn.assigns.current_scope.user do
      conn
    else
      conn
      |> put_flash(:error, "You must log in to access this page.")
      |> redirect(to: ~p"/users/log-in")
      |> halt()
    end
  end

  defp ensure_stripe_customer(%User{stripe_customer_id: customer_id} = user) when is_binary(customer_id) do
    {:ok, user}
  end

  defp ensure_stripe_customer(%User{} = user) do
    case Stripe.Customer.create(%{
           email: user.email,
           name: user.email
         }) do
      {:ok, %{id: customer_id}} ->
        user
        |> Ecto.Changeset.change(stripe_customer_id: customer_id)
        |> Repo.update()
        |> case do
          {:ok, updated_user} -> {:ok, updated_user}
          {:error, _} -> {:error, "Failed to save Stripe customer ID"}
        end

      {:error, error} ->
        {:error, error}
    end
  end

  defp get_subscription_plan(plan_id) when is_binary(plan_id) do
    case Repo.get_by(SpeakFirstAi.SubscriptionPlans.SubscriptionPlan, stripe_price_id: plan_id) do
      nil -> {:error, "Subscription plan not found"}
      plan -> {:ok, plan}
    end
  end

  defp get_subscription_plan(_), do: {:error, "Invalid plan ID"}

  defp create_checkout_session(%User{} = user, %SpeakFirstAi.SubscriptionPlans.SubscriptionPlan{} = plan) do
    Stripe.Checkout.Session.create(%{
      customer: user.stripe_customer_id,
      payment_method_types: ["card"],
      line_items: [
        %{
          price: plan.stripe_price_id,
          quantity: 1
        }
      ],
      mode: "subscription",
      # subscription_data: %{
      #   trial_period_days: plan.trial_period_days || 7
      # },
      success_url: build_url(~p"/subscriptions/success"),
      cancel_url: build_url(~p"/subscriptions/cancel")
    })
  end

  defp build_url(path) do
    SpeakFirstAiWeb.Endpoint.url() <> path
  end
end
