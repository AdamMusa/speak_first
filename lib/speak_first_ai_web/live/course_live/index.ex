defmodule SpeakFirstAiWeb.CourseLive.Index do
  use SpeakFirstAiWeb, :live_view

  alias SpeakFirstAi.Courses

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        Listing Courses
        <:actions>
          <.button variant="primary" navigate={~p"/admin/courses/new"}>
            <.icon name="hero-plus" /> New Course
          </.button>
        </:actions>
      </.header>

      <.table
        id="courses"
        rows={@streams.courses}
        row_click={fn {_id, course} -> JS.navigate(~p"/admin/courses/#{course}") end}
      >
        <:col :let={{_id, course}} label="Title">{course.title}</:col>
        <:col :let={{_id, course}} label="Descriptions">{course.descriptions}</:col>
        <:col :let={{_id, course}} label="Content">{course.content}</:col>
        <:action :let={{_id, course}}>
          <div class="sr-only">
            <.link navigate={~p"/admin/courses/#{course}"}>Show</.link>
          </div>
          <.link navigate={~p"/admin/courses/#{course}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, course}}>
          <.link
            phx-click={JS.push("delete", value: %{id: course.id}) |> hide("##{id}")}
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
      Courses.subscribe_courses(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Listing Courses")
     |> stream(:courses, list_courses(socket.assigns.current_scope))}
  end

  @impl true
  def handle_params(_params, _uri, socket) do
    {:noreply, SpeakFirstAiWeb.LiveAdminHooks.update_current_path(socket)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    course = Courses.get_course!(socket.assigns.current_scope, id)
    {:ok, _} = Courses.delete_course(socket.assigns.current_scope, course)

    {:noreply, stream_delete(socket, :courses, course)}
  end

  @impl true
  def handle_info({type, %SpeakFirstAi.Courses.Course{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, stream(socket, :courses, list_courses(socket.assigns.current_scope), reset: true)}
  end

  defp list_courses(current_scope) do
    Courses.list_courses(current_scope)
  end
end
