defmodule SpeakFirstAiWeb.LessonLive.Form do
  use SpeakFirstAiWeb, :live_view

  alias SpeakFirstAi.Lessons
  alias SpeakFirstAi.Lessons.Lesson

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-3xl mx-auto">
      <div class="bg-white border border-gray-200 rounded-lg shadow-sm p-6">
        <.header>
          {@page_title}
          <:subtitle>Use this form to manage lesson records in your database.</:subtitle>
        </.header>

        <.form for={@form} id="lesson-form" phx-change="validate" phx-submit="save">
          <.input field={@form[:title]} type="text" label="Title" />
          <.input field={@form[:description]} type="textarea" label="Description" />
          <.input field={@form[:lesson_type]} type="text" label="Lesson type" />
          <.input field={@form[:lesson_difficulty]} type="text" label="Lesson difficulty" />
          <.input field={@form[:estimated_minutes]} type="number" label="Estimated minutes" />
          <.input field={@form[:is_active]} type="checkbox" label="Is active" />
          <div class="mt-6 flex items-center gap-3">
            <.button phx-disable-with="Saving..." variant="primary">Save Lesson</.button>
            <.button navigate={return_path(@current_scope, @return_to, @lesson)}>Cancel</.button>
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

    socket
    |> assign(:page_title, "Edit Lesson")
    |> assign(:lesson, lesson)
    |> assign(:form, to_form(Lessons.change_lesson(socket.assigns.current_scope, lesson)))
  end

  defp apply_action(socket, :new, _params) do
    lesson = %Lesson{user_id: socket.assigns.current_scope.user.id}

    socket
    |> assign(:page_title, "New Lesson")
    |> assign(:lesson, lesson)
    |> assign(:form, to_form(Lessons.change_lesson(socket.assigns.current_scope, lesson)))
  end

  @impl true
  def handle_event("validate", %{"lesson" => lesson_params}, socket) do
    changeset = Lessons.change_lesson(socket.assigns.current_scope, socket.assigns.lesson, lesson_params)
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
