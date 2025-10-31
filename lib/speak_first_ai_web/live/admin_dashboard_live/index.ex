defmodule SpeakFirstAiWeb.AdminDashboardLive do
  use SpeakFirstAiWeb, :live_view

  alias SpeakFirstAi.{Coaching, Conversation, Lessons, SubscriptionPlans}

  @impl true
  def render(assigns) do
    ~H"""
    <div class="p-6">
      <div class="mb-8">
        <h1 class="text-3xl font-bold text-gray-900 mb-2">Welcome to Admin Dashboard</h1>
        <p class="text-gray-600">Manage your SpeakFirst AI platform from here.</p>
      </div>
      
    <!-- Stats Grid -->
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
        <.stat_card
          title="Coaching Personas"
          count={@coaching_personas_count}
          icon="hero-user-group"
          color="from-blue-500 to-blue-600"
          href={~p"/admin/coaching_personas"}
        />

        <.stat_card
          title="Conversation Topics"
          count={@conversation_topics_count}
          icon="hero-chat-bubble-left-right"
          color="from-green-500 to-green-600"
          href={~p"/admin/conversation_topics"}
        />

        <.stat_card
          title="Lessons"
          count={@lessons_count}
          icon="hero-academic-cap"
          color="from-purple-500 to-purple-600"
          href={~p"/admin/lessons"}
        />

        <.stat_card
          title="Subscription Plans"
          count={@subscription_plans_count}
          icon="hero-credit-card"
          color="from-orange-500 to-orange-600"
          href={~p"/admin/subscription_plans"}
        />
      </div>
      
    <!-- Quick Actions -->
      <div class="bg-gradient-to-r from-indigo-50 to-purple-50 rounded-lg p-6">
        <h2 class="text-xl font-semibold text-gray-900 mb-4">Quick Actions</h2>
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
          <.quick_action_button
            title="New Coaching Persona"
            icon="hero-user-plus"
            href={~p"/admin/coaching_personas/new"}
            color="bg-blue-500 hover:bg-blue-600"
          />

          <.quick_action_button
            title="New Conversation Topic"
            icon="hero-chat-bubble-plus"
            href={~p"/admin/conversation_topics/new"}
            color="bg-green-500 hover:bg-green-600"
          />

          <.quick_action_button
            title="New Lesson"
            icon="hero-book-open"
            href={~p"/admin/lessons/new"}
            color="bg-purple-500 hover:bg-purple-600"
          />

          <.quick_action_button
            title="New Subscription Plan"
            icon="hero-plus-circle"
            href={~p"/admin/subscription_plans/new"}
            color="bg-orange-500 hover:bg-orange-600"
          />
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Admin Dashboard")
     |> load_stats()}
  end

  @impl true
  def handle_params(_params, _uri, socket) do
    {:noreply, SpeakFirstAiWeb.LiveAdminHooks.update_current_path(socket)}
  end

  defp load_stats(socket) do
    scope = socket.assigns.current_scope

    coaching_personas_count = length(Coaching.list_coaching_personas(scope))
    conversation_topics_count = length(Conversation.list_conversations(scope))
    lessons_count = length(Lessons.list_lessons(scope))
    subscription_plans_count = length(SubscriptionPlans.list_subscription_plan(scope))

    socket
    |> assign(:coaching_personas_count, coaching_personas_count)
    |> assign(:conversation_topics_count, conversation_topics_count)
    |> assign(:lessons_count, lessons_count)
    |> assign(:subscription_plans_count, subscription_plans_count)
  end

  # Stat Card Component
  defp stat_card(assigns) do
    ~H"""
    <div class="bg-white rounded-lg shadow-sm border border-gray-200 p-6 hover:shadow-md transition-shadow duration-200">
      <.link navigate={@href} class="block">
        <div class="flex items-center">
          <div class={["p-3 rounded-lg bg-gradient-to-r", @color]}>
            <.icon name={@icon} class="w-6 h-6 text-white" />
          </div>
          <div class="ml-4">
            <p class="text-sm font-medium text-gray-600">{@title}</p>
            <p class="text-2xl font-bold text-gray-900">{@count}</p>
          </div>
        </div>
      </.link>
    </div>
    """
  end

  # Quick Action Button Component
  defp quick_action_button(assigns) do
    ~H"""
    <.link
      navigate={@href}
      class={[
        "text-white px-4 py-3 rounded-lg font-medium transition-colors duration-200 flex items-center space-x-2",
        @color
      ]}
    >
      <.icon name={@icon} class="w-5 h-5" />
      <span>{@title}</span>
    </.link>
    """
  end
end
