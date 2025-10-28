defmodule SpeakFirstAi.SubscriptionPlansFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `SpeakFirstAi.SubscriptionPlans` context.
  """

  @doc """
  Generate a subscription_plan.
  """
  def subscription_plan_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        active: true,
        currency: "some currency",
        description: "some description",
        interval: "some interval",
        name: "some name",
        price_cents: 120.5,
        stripe_price_id: "some stripe_price_id",
        trial_period_days: 42
      })

    {:ok, subscription_plan} = SpeakFirstAi.SubscriptionPlans.create_subscription_plan(scope, attrs)
    subscription_plan
  end
end
