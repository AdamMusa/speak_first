defmodule SpeakFirstAi.Subscriptions do
  @moduledoc """
  The Subscriptions context.
  """

  import Ecto.Query, warn: false
  alias SpeakFirstAi.Repo

  alias SpeakFirstAi.Subscriptions.Subscription
  alias SpeakFirstAi.Accounts.User

  @doc """
  Gets a single subscription for a user with preloaded subscription_plan.
  """
  def get_user_subscription(%User{} = user) do
    from(s in Subscription,
      where: s.user_id == ^user.id,
      preload: [:subscription_plan]
    )
    |> Repo.one()
  end

  @doc """
  Creates or updates a subscription.
  """
  def upsert_subscription(user_id, attrs) do
    case Repo.get_by(Subscription, user_id: user_id) do
      nil ->
        %Subscription{user_id: user_id}
        |> Subscription.changeset(attrs)
        |> Repo.insert()

      subscription ->
        subscription
        |> Subscription.changeset(attrs)
        |> Repo.update()
    end
  end

  @doc """
  Updates subscription cancel_at_period_end.
  """
  def update_cancel_at_period_end(%Subscription{} = subscription, value) do
    subscription
    |> Subscription.changeset(%{cancel_at_period_end: value})
    |> Repo.update()
  end

  @doc """
  Checks if user can request a refund (within 7 days of subscription creation).
  """
  def can_request_refund?(%Subscription{} = subscription) do
    if subscription.inserted_at do
      days_ago = DateTime.diff(DateTime.utc_now(), subscription.inserted_at, :day)
      days_ago <= 7
    else
      false
    end
  end

  @doc """
  Calculates refund deadline (7 days after subscription creation).
  """
  def refund_deadline(%Subscription{} = subscription) do
    if subscription.inserted_at do
      DateTime.add(subscription.inserted_at, 7 * 24 * 60 * 60, :second)
    else
      nil
    end
  end
end
