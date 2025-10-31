defmodule SpeakFirstAiWeb.SubscriptionPlanLiveTest do
  use SpeakFirstAiWeb.ConnCase

  import Phoenix.LiveViewTest
  import SpeakFirstAi.SubscriptionPlansFixtures

  @create_attrs %{
    active: true,
    name: "some name",
    description: "some description",
    currency: "some currency",
    price_cents: 120.5,
    interval: "some interval",
    stripe_price_id: "some stripe_price_id",
    trial_period_days: 42
  }
  @update_attrs %{
    active: false,
    name: "some updated name",
    description: "some updated description",
    currency: "some updated currency",
    price_cents: 456.7,
    interval: "some updated interval",
    stripe_price_id: "some updated stripe_price_id",
    trial_period_days: 43
  }
  @invalid_attrs %{
    active: false,
    name: nil,
    description: nil,
    currency: nil,
    price_cents: nil,
    interval: nil,
    stripe_price_id: nil,
    trial_period_days: nil
  }

  setup :register_and_log_in_user

  defp create_subscription_plan(%{scope: scope}) do
    subscription_plan = subscription_plan_fixture(scope)

    %{subscription_plan: subscription_plan}
  end

  describe "Index" do
    setup [:create_subscription_plan]

    test "lists all subscription_plan", %{conn: conn, subscription_plan: subscription_plan} do
      {:ok, _index_live, html} = live(conn, ~p"/subscription_plan")

      assert html =~ "Listing Subscription plan"
      assert html =~ subscription_plan.name
    end

    test "saves new subscription_plan", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/subscription_plan")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Subscription plan")
               |> render_click()
               |> follow_redirect(conn, ~p"/subscription_plan/new")

      assert render(form_live) =~ "New Subscription plan"

      assert form_live
             |> form("#subscription_plan-form", subscription_plan: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#subscription_plan-form", subscription_plan: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/subscription_plan")

      html = render(index_live)
      assert html =~ "Subscription plan created successfully"
      assert html =~ "some name"
    end

    test "updates subscription_plan in listing", %{
      conn: conn,
      subscription_plan: subscription_plan
    } do
      {:ok, index_live, _html} = live(conn, ~p"/subscription_plan")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#subscription_plan-#{subscription_plan.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/subscription_plan/#{subscription_plan}/edit")

      assert render(form_live) =~ "Edit Subscription plan"

      assert form_live
             |> form("#subscription_plan-form", subscription_plan: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#subscription_plan-form", subscription_plan: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/subscription_plan")

      html = render(index_live)
      assert html =~ "Subscription plan updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes subscription_plan in listing", %{
      conn: conn,
      subscription_plan: subscription_plan
    } do
      {:ok, index_live, _html} = live(conn, ~p"/subscription_plan")

      assert index_live
             |> element("#subscription_plan-#{subscription_plan.id} a", "Delete")
             |> render_click()

      refute has_element?(index_live, "#subscription_plan-#{subscription_plan.id}")
    end
  end

  describe "Show" do
    setup [:create_subscription_plan]

    test "displays subscription_plan", %{conn: conn, subscription_plan: subscription_plan} do
      {:ok, _show_live, html} = live(conn, ~p"/subscription_plan/#{subscription_plan}")

      assert html =~ "Show Subscription plan"
      assert html =~ subscription_plan.name
    end

    test "updates subscription_plan and returns to show", %{
      conn: conn,
      subscription_plan: subscription_plan
    } do
      {:ok, show_live, _html} = live(conn, ~p"/subscription_plan/#{subscription_plan}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(
                 conn,
                 ~p"/subscription_plan/#{subscription_plan}/edit?return_to=show"
               )

      assert render(form_live) =~ "Edit Subscription plan"

      assert form_live
             |> form("#subscription_plan-form", subscription_plan: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#subscription_plan-form", subscription_plan: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/subscription_plan/#{subscription_plan}")

      html = render(show_live)
      assert html =~ "Subscription plan updated successfully"
      assert html =~ "some updated name"
    end
  end
end
