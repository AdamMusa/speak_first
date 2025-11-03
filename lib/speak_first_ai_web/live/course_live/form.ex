defmodule SpeakFirstAiWeb.CourseLive.Form do
  use SpeakFirstAiWeb, :live_view

  alias SpeakFirstAi.Courses
  alias SpeakFirstAi.Courses.Course

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-4xl mx-auto">
      <div class="bg-white border-2 border-gray-100 rounded-3xl shadow-xl p-8 lg:p-10">
        <.header>
          {@page_title}
          <:subtitle>Use this form to manage course records in your database.</:subtitle>
        </.header>

        <.form for={@form} id="course-form" phx-change="validate" phx-submit="save" class="mt-8 space-y-6">
          <.input field={@form[:title]} type="text" label="Title" />
          <.input field={@form[:descriptions]} type="textarea" label="Descriptions" />
          <.input field={@form[:content]} type="textarea" label="Content" />
          <div class="mt-8 flex items-center gap-4 pt-6 border-t border-gray-200">
            <button
              type="submit"
              phx-disable-with="Saving..."
              class="group relative inline-flex items-center gap-2 px-6 py-3 text-sm font-semibold rounded-2xl bg-gradient-to-r from-gray-900 to-gray-800 text-white shadow-lg hover:shadow-xl transition-all duration-300 hover:scale-105 transform overflow-hidden"
            >
              <span class="absolute inset-0 bg-gradient-to-r from-blue-600 to-purple-600 opacity-0 group-hover:opacity-100 transition-opacity duration-300"></span>
              <span class="relative flex items-center gap-2">
                <.icon name="hero-check" class="w-5 h-5" />
                Save Course
              </span>
            </button>
            <.link
              navigate={return_path(@current_scope, @return_to, @course)}
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
    course = Courses.get_course!(socket.assigns.current_scope, id)

    socket
    |> assign(:page_title, "Edit Course")
    |> assign(:course, course)
    |> assign(:form, to_form(Courses.change_course(socket.assigns.current_scope, course)))
  end

  defp apply_action(socket, :new, _params) do
    course = %Course{user_id: socket.assigns.current_scope.user.id}

    socket
    |> assign(:page_title, "New Course")
    |> assign(:course, course)
    |> assign(:form, to_form(Courses.change_course(socket.assigns.current_scope, course)))
  end

  @impl true
  def handle_event("validate", %{"course" => course_params}, socket) do
    changeset = Courses.change_course(socket.assigns.current_scope, socket.assigns.course, course_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"course" => course_params}, socket) do
    save_course(socket, socket.assigns.live_action, course_params)
  end

  defp save_course(socket, :edit, course_params) do
    case Courses.update_course(socket.assigns.current_scope, socket.assigns.course, course_params) do
      {:ok, course} ->
        {:noreply,
         socket
         |> put_flash(:info, "Course updated successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, course)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_course(socket, :new, course_params) do
    case Courses.create_course(socket.assigns.current_scope, course_params) do
      {:ok, course} ->
        {:noreply,
         socket
         |> put_flash(:info, "Course created successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, course)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path(_scope, "index", _course), do: ~p"/admin/courses"
  defp return_path(_scope, "show", course), do: ~p"/admin/courses/#{course}"
end
