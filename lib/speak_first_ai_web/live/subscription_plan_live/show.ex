defmodule SpeakFirstAiWeb.SubscriptionPlanLive.Show do
  use SpeakFirstAiWeb, :live_view

  alias SpeakFirstAi.SubscriptionPlans

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        Subscription plan {@subscription_plan.id}
        <:subtitle>This is a subscription_plan record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/admin/subscription_plans"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button
            variant="primary"
            navigate={~p"/admin/subscription_plans/#{@subscription_plan}/edit?return_to=show"}
          >
            <.icon name="hero-pencil-square" /> Edit subscription_plan
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Name">{@subscription_plan.name}</:item>
        <:item title="Description">{@subscription_plan.description}</:item>
        <:item title="Price cents">{@subscription_plan.price_cents}</:item>
        <:item title="Currency">{@subscription_plan.currency}</:item>
        <:item title="Interval">{@subscription_plan.interval}</:item>
        <:item title="Stripe price">{@subscription_plan.stripe_price_id}</:item>
        <:item title="Active">{@subscription_plan.active}</:item>
        <:item title="Trial period days">{@subscription_plan.trial_period_days}</:item>
      </.list>
    </div>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      SubscriptionPlans.subscribe_subscription_plan(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Show Subscription plan")
     |> assign(
       :subscription_plan,
       SubscriptionPlans.get_subscription_plan!(socket.assigns.current_scope, id)
     )}
  end

  @impl true
  def handle_info(
        {:updated, %SpeakFirstAi.SubscriptionPlans.SubscriptionPlan{id: id} = subscription_plan},
        %{assigns: %{subscription_plan: %{id: id}}} = socket
      ) do
    {:noreply, assign(socket, :subscription_plan, subscription_plan)}
  end

  def handle_info(
        {:deleted, %SpeakFirstAi.SubscriptionPlans.SubscriptionPlan{id: id}},
        %{assigns: %{subscription_plan: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "The current subscription_plan was deleted.")
     |> push_navigate(to: ~p"/admin/subscription_plans")}
  end

  def handle_info({type, %SpeakFirstAi.SubscriptionPlans.SubscriptionPlan{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end
end
