defmodule SpeakFirstAiWeb.CourseLive.Show do
  use SpeakFirstAiWeb, :live_view

  alias SpeakFirstAi.Courses

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        Course {@course.id}
        <:subtitle>This is a course record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/admin/courses"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/admin/courses/#{@course}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit course
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Title">{@course.title}</:item>
        <:item title="Descriptions">{@course.descriptions}</:item>
        <:item title="Content">{@course.content}</:item>
      </.list>
    </div>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Courses.subscribe_courses(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Show Course")
     |> assign(:course, Courses.get_course!(socket.assigns.current_scope, id))}
  end

  @impl true
  def handle_params(_params, _uri, socket) do
    {:noreply, SpeakFirstAiWeb.LiveAdminHooks.update_current_path(socket)}
  end

  @impl true
  def handle_info(
        {:updated, %SpeakFirstAi.Courses.Course{id: id} = course},
        %{assigns: %{course: %{id: id}}} = socket
      ) do
    {:noreply, assign(socket, :course, course)}
  end

  def handle_info(
        {:deleted, %SpeakFirstAi.Courses.Course{id: id}},
        %{assigns: %{course: %{id: id}}} = socket
      ) do
      {:noreply,
       socket
       |> put_flash(:error, "The current course was deleted.")
       |> push_navigate(to: ~p"/admin/courses")}
  end

  def handle_info({type, %SpeakFirstAi.Courses.Course{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end
end
