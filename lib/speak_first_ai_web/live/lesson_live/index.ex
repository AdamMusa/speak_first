defmodule SpeakFirstAiWeb.LessonLive.Index do
  use SpeakFirstAiWeb, :live_view

  alias SpeakFirstAi.Lessons

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        Listing Lessons
        <:actions>
          <.link
            navigate={~p"/admin/lessons/new"}
            class="group relative inline-flex items-center gap-2 px-5 py-2.5 text-sm font-semibold rounded-2xl bg-gradient-to-r from-gray-900 to-gray-800 text-white shadow-lg hover:shadow-xl transition-all duration-300 hover:scale-105 transform overflow-hidden"
          >
            <span class="absolute inset-0 bg-gradient-to-r from-blue-600 to-purple-600 opacity-0 group-hover:opacity-100 transition-opacity duration-300"></span>
            <span class="relative flex items-center gap-2">
              <.icon name="hero-plus" class="w-5 h-5" />
              New Lesson
            </span>
          </.link>
        </:actions>
      </.header>

      <.table
        id="lessons"
        rows={@streams.lessons}
        row_click={fn {_id, lesson} -> JS.navigate(~p"/admin/lessons/#{lesson}") end}
      >
        <:col :let={{_id, lesson}} label="Title">{lesson.title}</:col>
        <:col :let={{_id, lesson}} label="Description">{lesson.description}</:col>
        <:col :let={{_id, lesson}} label="Lesson type">{lesson.lesson_type}</:col>
        <:col :let={{_id, lesson}} label="Lesson difficulty">{lesson.lesson_difficulty}</:col>
        <:col :let={{_id, lesson}} label="Estimated minutes">{lesson.estimated_minutes}</:col>
        <:col :let={{_id, lesson}} label="Key vocabulary">{lesson.key_vocabulary}</:col>
        <:col :let={{_id, lesson}} label="Is active">{lesson.is_active}</:col>
        <:action :let={{_id, lesson}}>
          <div class="sr-only">
            <.link navigate={~p"/admin/lessons/#{lesson}"}>Show</.link>
          </div>
          <.link navigate={~p"/admin/lessons/#{lesson}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, lesson}}>
          <.link
            phx-click={JS.push("delete", value: %{id: lesson.id}) |> hide("##{id}")}
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
      Lessons.subscribe_lessons(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Listing Lessons")
     |> stream(:lessons, list_lessons(socket.assigns.current_scope))}
  end

  @impl true
  def handle_params(_params, _uri, socket) do
    {:noreply, SpeakFirstAiWeb.LiveAdminHooks.update_current_path(socket)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    lesson = Lessons.get_lesson!(socket.assigns.current_scope, id)
    {:ok, _} = Lessons.delete_lesson(socket.assigns.current_scope, lesson)

    {:noreply, stream_delete(socket, :lessons, lesson)}
  end

  @impl true
  def handle_info({type, %SpeakFirstAi.Lessons.Lesson{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, stream(socket, :lessons, list_lessons(socket.assigns.current_scope), reset: true)}
  end

  defp list_lessons(current_scope) do
    Lessons.list_lessons(current_scope)
  end
end
