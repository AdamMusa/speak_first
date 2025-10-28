defmodule SpeakFirstAiWeb.LessonLive.Show do
  use SpeakFirstAiWeb, :live_view

  alias SpeakFirstAi.Lessons

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Lesson {@lesson.id}
        <:subtitle>This is a lesson record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/lessons"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/lessons/#{@lesson}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit lesson
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Title">{@lesson.title}</:item>
        <:item title="Description">{@lesson.description}</:item>
        <:item title="Lesson type">{@lesson.lesson_type}</:item>
        <:item title="Lesson difficulty">{@lesson.lesson_difficulty}</:item>
        <:item title="Estimated minutes">{@lesson.estimated_minutes}</:item>
        <:item title="Key vocabulary">{@lesson.key_vocabulary}</:item>
        <:item title="Is active">{@lesson.is_active}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Lessons.subscribe_lessons(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Show Lesson")
     |> assign(:lesson, Lessons.get_lesson!(socket.assigns.current_scope, id))}
  end

  @impl true
  def handle_info(
        {:updated, %SpeakFirstAi.Lessons.Lesson{id: id} = lesson},
        %{assigns: %{lesson: %{id: id}}} = socket
      ) do
    {:noreply, assign(socket, :lesson, lesson)}
  end

  def handle_info(
        {:deleted, %SpeakFirstAi.Lessons.Lesson{id: id}},
        %{assigns: %{lesson: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "The current lesson was deleted.")
     |> push_navigate(to: ~p"/lessons")}
  end

  def handle_info({type, %SpeakFirstAi.Lessons.Lesson{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end
end
