defmodule SpeakFirstAiWeb.LessonLive.Index do
  use SpeakFirstAiWeb, :live_view

  alias SpeakFirstAi.Lessons

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Listing Lessons
        <:actions>
          <.button variant="primary" navigate={~p"/lessons/new"}>
            <.icon name="hero-plus" /> New Lesson
          </.button>
        </:actions>
      </.header>

      <.table
        id="lessons"
        rows={@streams.lessons}
        row_click={fn {_id, lesson} -> JS.navigate(~p"/lessons/#{lesson}") end}
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
            <.link navigate={~p"/lessons/#{lesson}"}>Show</.link>
          </div>
          <.link navigate={~p"/lessons/#{lesson}/edit"}>Edit</.link>
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
    </Layouts.app>
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
