defmodule SpeakFirstAiWeb.LandingLive do
  use SpeakFirstAiWeb, :live_view

  embed_templates "landing_live/*"

  @impl true
  def render(assigns) do
    ~H"""
    <.index flash={@flash} current_scope={@current_scope} billing_period={@billing_period} />
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Learn a new language the natural way — SpeakFirst AI")
     |> assign(:billing_period, :monthly)}
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
end
