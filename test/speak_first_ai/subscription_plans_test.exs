defmodule SpeakFirstAi.SubscriptionPlansTest do
  use SpeakFirstAi.DataCase

  alias SpeakFirstAi.SubscriptionPlans

  describe "subscription_plan" do
    alias SpeakFirstAi.SubscriptionPlans.SubscriptionPlan

    import SpeakFirstAi.AccountsFixtures, only: [user_scope_fixture: 0]
    import SpeakFirstAi.SubscriptionPlansFixtures

    @invalid_attrs %{
      active: nil,
      name: nil,
      description: nil,
      currency: nil,
      price_cents: nil,
      interval: nil,
      stripe_price_id: nil,
      trial_period_days: nil
    }

    test "list_subscription_plan/1 returns all scoped subscription_plan" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      subscription_plan = subscription_plan_fixture(scope)
      other_subscription_plan = subscription_plan_fixture(other_scope)
      assert SubscriptionPlans.list_subscription_plan(scope) == [subscription_plan]
      assert SubscriptionPlans.list_subscription_plan(other_scope) == [other_subscription_plan]
    end

    test "get_subscription_plan!/2 returns the subscription_plan with given id" do
      scope = user_scope_fixture()
      subscription_plan = subscription_plan_fixture(scope)
      other_scope = user_scope_fixture()

      assert SubscriptionPlans.get_subscription_plan!(scope, subscription_plan.id) ==
               subscription_plan

      assert_raise Ecto.NoResultsError, fn ->
        SubscriptionPlans.get_subscription_plan!(other_scope, subscription_plan.id)
      end
    end

    test "create_subscription_plan/2 with valid data creates a subscription_plan" do
      valid_attrs = %{
        active: true,
        name: "some name",
        description: "some description",
        currency: "some currency",
        price_cents: 120.5,
        interval: "some interval",
        stripe_price_id: "some stripe_price_id",
        trial_period_days: 42
      }

      scope = user_scope_fixture()

      assert {:ok, %SubscriptionPlan{} = subscription_plan} =
               SubscriptionPlans.create_subscription_plan(scope, valid_attrs)

      assert subscription_plan.active == true
      assert subscription_plan.name == "some name"
      assert subscription_plan.description == "some description"
      assert subscription_plan.currency == "some currency"
      assert subscription_plan.price_cents == 120.5
      assert subscription_plan.interval == "some interval"
      assert subscription_plan.stripe_price_id == "some stripe_price_id"
      assert subscription_plan.trial_period_days == 42
      assert subscription_plan.user_id == scope.user.id
    end

    test "create_subscription_plan/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()

      assert {:error, %Ecto.Changeset{}} =
               SubscriptionPlans.create_subscription_plan(scope, @invalid_attrs)
    end

    test "update_subscription_plan/3 with valid data updates the subscription_plan" do
      scope = user_scope_fixture()
      subscription_plan = subscription_plan_fixture(scope)

      update_attrs = %{
        active: false,
        name: "some updated name",
        description: "some updated description",
        currency: "some updated currency",
        price_cents: 456.7,
        interval: "some updated interval",
        stripe_price_id: "some updated stripe_price_id",
        trial_period_days: 43
      }

      assert {:ok, %SubscriptionPlan{} = subscription_plan} =
               SubscriptionPlans.update_subscription_plan(scope, subscription_plan, update_attrs)

      assert subscription_plan.active == false
      assert subscription_plan.name == "some updated name"
      assert subscription_plan.description == "some updated description"
      assert subscription_plan.currency == "some updated currency"
      assert subscription_plan.price_cents == 456.7
      assert subscription_plan.interval == "some updated interval"
      assert subscription_plan.stripe_price_id == "some updated stripe_price_id"
      assert subscription_plan.trial_period_days == 43
    end

    test "update_subscription_plan/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      subscription_plan = subscription_plan_fixture(scope)

      assert_raise MatchError, fn ->
        SubscriptionPlans.update_subscription_plan(other_scope, subscription_plan, %{})
      end
    end

    test "update_subscription_plan/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      subscription_plan = subscription_plan_fixture(scope)

      assert {:error, %Ecto.Changeset{}} =
               SubscriptionPlans.update_subscription_plan(
                 scope,
                 subscription_plan,
                 @invalid_attrs
               )

      assert subscription_plan ==
               SubscriptionPlans.get_subscription_plan!(scope, subscription_plan.id)
    end

    test "delete_subscription_plan/2 deletes the subscription_plan" do
      scope = user_scope_fixture()
      subscription_plan = subscription_plan_fixture(scope)

      assert {:ok, %SubscriptionPlan{}} =
               SubscriptionPlans.delete_subscription_plan(scope, subscription_plan)

      assert_raise Ecto.NoResultsError, fn ->
        SubscriptionPlans.get_subscription_plan!(scope, subscription_plan.id)
      end
    end

    test "delete_subscription_plan/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      subscription_plan = subscription_plan_fixture(scope)

      assert_raise MatchError, fn ->
        SubscriptionPlans.delete_subscription_plan(other_scope, subscription_plan)
      end
    end

    test "change_subscription_plan/2 returns a subscription_plan changeset" do
      scope = user_scope_fixture()
      subscription_plan = subscription_plan_fixture(scope)

      assert %Ecto.Changeset{} =
               SubscriptionPlans.change_subscription_plan(scope, subscription_plan)
    end
  end
end
