defmodule SpeakFirstAiWeb.CoachingPersonaLive.Form do
  use SpeakFirstAiWeb, :live_view

  alias SpeakFirstAi.Coaching
  alias SpeakFirstAi.Coaching.CoachingPersona

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-4xl mx-auto">
      <div class="bg-white border-2 border-gray-100 rounded-3xl shadow-xl p-8 lg:p-10">
        <.header>
          {@page_title}
          <:subtitle>Use this form to manage coaching persona records in your database.</:subtitle>
        </.header>

        <.form for={@form} id="coaching_persona-form" phx-change="validate" phx-submit="save" class="mt-8 space-y-6">
          <.input field={@form[:title]} type="text" label="Title" />
          <.input field={@form[:description]} type="textarea" label="Description" />
          <div class="mt-8 flex items-center gap-4 pt-6 border-t border-gray-200">
            <button
              type="submit"
              phx-disable-with="Saving..."
              class="group relative inline-flex items-center gap-2 px-6 py-3 text-sm font-semibold rounded-2xl bg-gradient-to-r from-gray-900 to-gray-800 text-white shadow-lg hover:shadow-xl transition-all duration-300 hover:scale-105 transform overflow-hidden"
            >
              <span class="absolute inset-0 bg-gradient-to-r from-blue-600 to-purple-600 opacity-0 group-hover:opacity-100 transition-opacity duration-300"></span>
              <span class="relative flex items-center gap-2">
                <.icon name="hero-check" class="w-5 h-5" />
                Save Coaching persona
              </span>
            </button>
            <.link
              navigate={return_path(@current_scope, @return_to, @coaching_persona)}
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
    coaching_persona = Coaching.get_coaching_persona!(socket.assigns.current_scope, id)

    socket
    |> assign(:page_title, "Edit Coaching persona")
    |> assign(:coaching_persona, coaching_persona)
    |> assign(
      :form,
      to_form(Coaching.change_coaching_persona(socket.assigns.current_scope, coaching_persona))
    )
  end

  defp apply_action(socket, :new, _params) do
    coaching_persona = %CoachingPersona{user_id: socket.assigns.current_scope.user.id}

    socket
    |> assign(:page_title, "New Coaching persona")
    |> assign(:coaching_persona, coaching_persona)
    |> assign(
      :form,
      to_form(Coaching.change_coaching_persona(socket.assigns.current_scope, coaching_persona))
    )
  end

  @impl true
  def handle_event("validate", %{"coaching_persona" => coaching_persona_params}, socket) do
    changeset =
      Coaching.change_coaching_persona(
        socket.assigns.current_scope,
        socket.assigns.coaching_persona,
        coaching_persona_params
      )

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"coaching_persona" => coaching_persona_params}, socket) do
    save_coaching_persona(socket, socket.assigns.live_action, coaching_persona_params)
  end

  defp save_coaching_persona(socket, :edit, coaching_persona_params) do
    case Coaching.update_coaching_persona(
           socket.assigns.current_scope,
           socket.assigns.coaching_persona,
           coaching_persona_params
         ) do
      {:ok, coaching_persona} ->
        {:noreply,
         socket
         |> put_flash(:info, "Coaching persona updated successfully")
         |> push_navigate(
           to:
             return_path(socket.assigns.current_scope, socket.assigns.return_to, coaching_persona)
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
           to:
             return_path(socket.assigns.current_scope, socket.assigns.return_to, coaching_persona)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path(_scope, "index", _coaching_persona), do: ~p"/admin/coaching_personas"

  defp return_path(_scope, "show", coaching_persona),
    do: ~p"/admin/coaching_personas/#{coaching_persona}"
end
