defmodule SpeakFirstAiWeb.CoachingPersonaLive.Form do
  use SpeakFirstAiWeb, :live_view

  alias SpeakFirstAi.Coaching
  alias SpeakFirstAi.Coaching.CoachingPersona

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-3xl mx-auto">
      <div class="bg-white border border-gray-200 rounded-lg shadow-sm p-6">
        <.header>
          {@page_title}
          <:subtitle>Use this form to manage coaching_persona records in your database.</:subtitle>
        </.header>

        <.form for={@form} id="coaching_persona-form" phx-change="validate" phx-submit="save">
          <.input field={@form[:title]} type="text" label="Title" />
          <.input field={@form[:description]} type="textarea" label="Description" />
          <div class="mt-6 flex items-center gap-3">
            <.button phx-disable-with="Saving..." variant="primary">Save Coaching persona</.button>
            <.button navigate={return_path(@current_scope, @return_to, @coaching_persona)}>Cancel</.button>
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
    coaching_persona = Coaching.get_coaching_persona!(socket.assigns.current_scope, id)

    socket
    |> assign(:page_title, "Edit Coaching persona")
    |> assign(:coaching_persona, coaching_persona)
    |> assign(:form, to_form(Coaching.change_coaching_persona(socket.assigns.current_scope, coaching_persona)))
  end

  defp apply_action(socket, :new, _params) do
    coaching_persona = %CoachingPersona{user_id: socket.assigns.current_scope.user.id}

    socket
    |> assign(:page_title, "New Coaching persona")
    |> assign(:coaching_persona, coaching_persona)
    |> assign(:form, to_form(Coaching.change_coaching_persona(socket.assigns.current_scope, coaching_persona)))
  end

  @impl true
  def handle_event("validate", %{"coaching_persona" => coaching_persona_params}, socket) do
    changeset = Coaching.change_coaching_persona(socket.assigns.current_scope, socket.assigns.coaching_persona, coaching_persona_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"coaching_persona" => coaching_persona_params}, socket) do
    save_coaching_persona(socket, socket.assigns.live_action, coaching_persona_params)
  end

  defp save_coaching_persona(socket, :edit, coaching_persona_params) do
    case Coaching.update_coaching_persona(socket.assigns.current_scope, socket.assigns.coaching_persona, coaching_persona_params) do
      {:ok, coaching_persona} ->
        {:noreply,
         socket
         |> put_flash(:info, "Coaching persona updated successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, coaching_persona)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_coaching_persona(socket, :new, coaching_persona_params) do
    case Coaching.create_coaching_persona(socket.assigns.current_scope, coaching_persona_params) do
      {:ok, coaching_persona} ->
        {:noreply,
         socket
         |> put_flash(:info, "Coaching persona created successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, coaching_persona)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path(_scope, "index", _coaching_persona), do: ~p"/admin/coaching_personas"
  defp return_path(_scope, "show", coaching_persona), do: ~p"/admin/coaching_personas/#{coaching_persona}"
end
