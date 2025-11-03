defmodule SpeakFirstAiWeb.LessonLive.Form do
  use SpeakFirstAiWeb, :live_view

  alias SpeakFirstAi.Lessons
  alias SpeakFirstAi.Lessons.Lesson
  alias SpeakFirstAi.Courses

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-4xl mx-auto">
      <div class="bg-white border-2 border-gray-100 rounded-3xl shadow-xl p-8 lg:p-10">
        <.header>
          {@page_title}
          <:subtitle>Use this form to manage lesson records in your database.</:subtitle>
        </.header>

        <.form for={@form} id="lesson-form" phx-change="validate" phx-submit="save" class="mt-8 space-y-6">
          <.input field={@form[:title]} type="text" label="Title" />
          <.input field={@form[:description]} type="textarea" label="Description" />
          <.input
            field={@form[:course_id]}
            type="select"
            label="Course"
            prompt="Select a course"
            options={@course_options}
          />
          <.input field={@form[:lesson_type]} type="text" label="Lesson type" />
          <.input field={@form[:lesson_difficulty]} type="text" label="Lesson difficulty" />
          <.input field={@form[:estimated_minutes]} type="number" label="Estimated minutes" />
          <.input field={@form[:is_active]} type="checkbox" label="Is active" />
          <.input field={@form[:is_completed]} type="checkbox" label="Is completed" />
          <div class="mt-8 flex items-center gap-4 pt-6 border-t border-gray-200">
            <button
              type="submit"
              phx-disable-with="Saving..."
              class="group relative inline-flex items-center gap-2 px-6 py-3 text-sm font-semibold rounded-2xl bg-gradient-to-r from-gray-900 to-gray-800 text-white shadow-lg hover:shadow-xl transition-all duration-300 hover:scale-105 transform overflow-hidden"
            >
              <span class="absolute inset-0 bg-gradient-to-r from-blue-600 to-purple-600 opacity-0 group-hover:opacity-100 transition-opacity duration-300"></span>
              <span class="relative flex items-center gap-2">
                <.icon name="hero-check" class="w-5 h-5" />
                Save Lesson
              </span>
            </button>
            <.link
              navigate={return_path(@current_scope, @return_to, @lesson)}
              class="px-6 py-3 text-sm font-semibold rounded-2xl border-2 border-gray-200 text-gray-700 hover:border-gray-300 hover:bg-gray-50 transition-all duration-300 hover:scale-105 transform shadow-sm"
            >
              Cancel
            </.link>
          </div>
        </.form>
      </div>
    </div>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    lesson = Lessons.get_lesson!(socket.assigns.current_scope, id)
    courses = Courses.list_courses(socket.assigns.current_scope)
    course_options = Enum.map(courses, fn course -> {course.title, course.id} end)

    socket
    |> assign(:page_title, "Edit Lesson")
    |> assign(:lesson, lesson)
    |> assign(:courses, courses)
    |> assign(:course_options, course_options)
    |> assign(:form, to_form(Lessons.change_lesson(socket.assigns.current_scope, lesson)))
  end

  defp apply_action(socket, :new, _params) do
    lesson = %Lesson{user_id: socket.assigns.current_scope.user.id}
    courses = Courses.list_courses(socket.assigns.current_scope)
    course_options = Enum.map(courses, fn course -> {course.title, course.id} end)

    socket
    |> assign(:page_title, "New Lesson")
    |> assign(:lesson, lesson)
    |> assign(:courses, courses)
    |> assign(:course_options, course_options)
    |> assign(:form, to_form(Lessons.change_lesson(socket.assigns.current_scope, lesson)))
  end

  @impl true
  def handle_event("validate", %{"lesson" => lesson_params}, socket) do
    changeset =
      Lessons.change_lesson(socket.assigns.current_scope, socket.assigns.lesson, lesson_params)

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"lesson" => lesson_params}, socket) do
    save_lesson(socket, socket.assigns.live_action, lesson_params)
  end

  defp save_lesson(socket, :edit, lesson_params) do
    case Lessons.update_lesson(socket.assigns.current_scope, socket.assigns.lesson, lesson_params) do
      {:ok, lesson} ->
        {:noreply,
         socket
         |> put_flash(:info, "Lesson updated successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, lesson)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_lesson(socket, :new, lesson_params) do
    case Lessons.create_lesson(socket.assigns.current_scope, lesson_params) do
      {:ok, lesson} ->
        {:noreply,
         socket
         |> put_flash(:info, "Lesson created successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, lesson)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path(_scope, "index", _lesson), do: ~p"/admin/lessons"
  defp return_path(_scope, "show", lesson), do: ~p"/admin/lessons/#{lesson}"
end
