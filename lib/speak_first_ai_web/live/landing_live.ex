defmodule SpeakFirstAiWeb.LandingLive do
  use SpeakFirstAiWeb, :live_view

  alias SpeakFirstAi.SubscriptionPlans

  embed_templates "landing_live/*"

  @impl true
  def render(assigns) do
    ~H"""
    <.index flash={@flash} current_scope={@current_scope} billing_period={@billing_period} plans={@plans} plan_map={@plan_map} />
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    # Load active subscription plans
    plans = SubscriptionPlans.list_active_plans()

    # Organize plans by name for easy access
    plan_map =
      plans
      |> Enum.group_by(& &1.name)
      |> Enum.map(fn {name, [plan | _]} -> {String.downcase(name), plan} end)
      |> Map.new()

    {:ok,
     socket
     |> assign(:page_title, "Learn a new language the natural way — SpeakFirst AI")
     |> assign(:billing_period, :monthly)
     |> assign(:plans, plans)
     |> assign(:plan_map, plan_map)}
  end

  @impl true
  def handle_event("toggle_billing", %{"period" => period}, socket) do
    period_atom =
      case period do
        "monthly" -> :monthly
        "yearly" -> :yearly
        _ -> :monthly
      end

    {:noreply, assign(socket, :billing_period, period_atom)}
  end

  @impl true
  def handle_event("start_free", _params, socket) do
    if socket.assigns.current_scope && socket.assigns.current_scope.user do
      # User is logged in, redirect to app
      {:noreply, push_navigate(socket, to: ~p"/admin")}
    else
      # User not logged in, redirect to registration
      {:noreply, push_navigate(socket, to: ~p"/users/register")}
    end
  end

  @impl true
  def handle_event("select_plan", %{"plan_id" => plan_id}, socket) do
    if socket.assigns.current_scope && socket.assigns.current_scope.user do
      # User is logged in, redirect to subscription creation
      {:noreply, push_navigate(socket, to: ~p"/subscriptions?plan_id=#{plan_id}")}
    else
      # User not logged in, redirect to registration with plan_id
      {:noreply, push_navigate(socket, to: ~p"/users/register?plan_id=#{plan_id}")}
    end
  end
end
