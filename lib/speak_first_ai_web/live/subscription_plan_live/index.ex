defmodule SpeakFirstAiWeb.SubscriptionPlanLive.Index do
  use SpeakFirstAiWeb, :live_view

  alias SpeakFirstAi.SubscriptionPlans

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        Listing Subscription plan
        <:actions>
          <.link
            navigate={~p"/admin/subscription_plans/new"}
            class="group relative inline-flex items-center gap-2 px-5 py-2.5 text-sm font-semibold rounded-2xl bg-gradient-to-r from-gray-900 to-gray-800 text-white shadow-lg hover:shadow-xl transition-all duration-300 hover:scale-105 transform overflow-hidden"
          >
            <span class="absolute inset-0 bg-gradient-to-r from-blue-600 to-purple-600 opacity-0 group-hover:opacity-100 transition-opacity duration-300"></span>
            <span class="relative flex items-center gap-2">
              <.icon name="hero-plus" class="w-5 h-5" />
              New Subscription plan
            </span>
          </.link>
        </:actions>
      </.header>

      <.table
        id="subscription_plan"
        rows={@streams.subscription_plan_collection}
        row_click={
          fn {_id, subscription_plan} ->
            JS.navigate(~p"/admin/subscription_plans/#{subscription_plan}")
          end
        }
      >
        <:col :let={{_id, subscription_plan}} label="Name">{subscription_plan.name}</:col>
        <:col :let={{_id, subscription_plan}} label="Description">
          {subscription_plan.description}
        </:col>
        <:col :let={{_id, subscription_plan}} label="Price cents">
          {subscription_plan.price_cents}
        </:col>
        <:col :let={{_id, subscription_plan}} label="Currency">{subscription_plan.currency}</:col>
        <:col :let={{_id, subscription_plan}} label="Interval">{subscription_plan.interval}</:col>
        <:col :let={{_id, subscription_plan}} label="Stripe price">
          {subscription_plan.stripe_price_id}
        </:col>
        <:col :let={{_id, subscription_plan}} label="Active">{subscription_plan.active}</:col>
        <:col :let={{_id, subscription_plan}} label="Trial period days">
          {subscription_plan.trial_period_days}
        </:col>
        <:action :let={{_id, subscription_plan}}>
          <div class="sr-only">
            <.link navigate={~p"/admin/subscription_plans/#{subscription_plan}"}>Show</.link>
          </div>
          <.link navigate={~p"/admin/subscription_plans/#{subscription_plan}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, subscription_plan}}>
          <.link
            phx-click={JS.push("delete", value: %{id: subscription_plan.id}) |> hide("##{id}")}
            data-confirm="Are you sure?"
          >
            Delete
          </.link>
        </:action>
      </.table>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      SubscriptionPlans.subscribe_subscription_plan(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Listing Subscription plan")
     |> stream(
       :subscription_plan_collection,
       list_subscription_plan(socket.assigns.current_scope)
     )}
  end

  @impl true
  def handle_params(_params, _uri, socket) do
    {:noreply, SpeakFirstAiWeb.LiveAdminHooks.update_current_path(socket)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    subscription_plan = SubscriptionPlans.get_subscription_plan!(socket.assigns.current_scope, id)

    {:ok, _} =
      SubscriptionPlans.delete_subscription_plan(socket.assigns.current_scope, subscription_plan)

    {:noreply, stream_delete(socket, :subscription_plan_collection, subscription_plan)}
  end

  @impl true
  def handle_info({type, %SpeakFirstAi.SubscriptionPlans.SubscriptionPlan{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply,
     stream(
       socket,
       :subscription_plan_collection,
       list_subscription_plan(socket.assigns.current_scope),
       reset: true
     )}
  end

  defp list_subscription_plan(current_scope) do
    SubscriptionPlans.list_subscription_plan(current_scope)
  end
end
