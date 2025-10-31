defmodule SpeakFirstAi.Subscriptions.Subscription do
  use Ecto.Schema
  import Ecto.Changeset

  alias SpeakFirstAi.Accounts.User
  alias SpeakFirstAi.SubscriptionPlans.SubscriptionPlan

  schema "subscriptions" do
    field :stripe_subscription_id, :string
    field :status, :string
    field :plan, :string
    field :current_period_end, :utc_datetime
    field :cancel_at_period_end, :boolean, default: false

    belongs_to :user, User
    belongs_to :subscription_plan, SubscriptionPlan

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(subscription, attrs) do
    subscription
    |> cast(attrs, [
      :stripe_subscription_id,
      :status,
      :plan,
      :current_period_end,
      :cancel_at_period_end,
      :subscription_plan_id
    ])
    |> validate_required([:subscription_plan_id])
  end
end
