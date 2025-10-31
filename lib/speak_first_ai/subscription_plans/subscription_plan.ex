defmodule SpeakFirstAi.SubscriptionPlans.SubscriptionPlan do
  use Ecto.Schema
  import Ecto.Changeset

  schema "subscription_plan" do
    field :name, :string
    field :description, :string
    field :price_cents, :float
    field :currency, :string
    field :interval, :string
    field :stripe_price_id, :string
    field :active, :boolean, default: false
    field :trial_period_days, :integer
    field :user_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(subscription_plan, attrs, user_scope) do
    subscription_plan
    |> cast(attrs, [
      :name,
      :description,
      :price_cents,
      :currency,
      :interval,
      :stripe_price_id,
      :active,
      :trial_period_days
    ])
    |> validate_required([
      :name,
      :description,
      :price_cents,
      :currency,
      :interval,
      :stripe_price_id,
      :active,
      :trial_period_days
    ])
    |> put_change(:user_id, user_scope.user.id)
  end
end
