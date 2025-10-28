defmodule SpeakFirstAiWeb.AdminDashboardLive do
  use SpeakFirstAiWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <h1>Admin Dashboard</h1>
    <p>Welcome to the admin dashboard!</p>
    """
  end
end
