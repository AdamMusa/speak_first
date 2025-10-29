defmodule SpeakFirstAiWeb.CoachingPersonaLive.Index do
  use SpeakFirstAiWeb, :live_view

  alias SpeakFirstAi.Coaching

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        Listing Coaching personas
        <:actions>
          <.button variant="primary" navigate={~p"/admin/coaching_personas/new"}>
            <.icon name="hero-plus" /> New Coaching persona
          </.button>
        </:actions>
      </.header>

      <.table
        id="coaching_personas"
        rows={@streams.coaching_personas}
        row_click={fn {_id, coaching_persona} -> JS.navigate(~p"/admin/coaching_personas/#{coaching_persona}") end}
      >
        <:col :let={{_id, coaching_persona}} label="Title">{coaching_persona.title}</:col>
        <:col :let={{_id, coaching_persona}} label="Description">{coaching_persona.description}</:col>
        <:action :let={{_id, coaching_persona}}>
          <div class="sr-only">
            <.link navigate={~p"/admin/coaching_personas/#{coaching_persona}"}>Show</.link>
          </div>
          <.link navigate={~p"/admin/coaching_personas/#{coaching_persona}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, coaching_persona}}>
          <.link
            phx-click={JS.push("delete", value: %{id: coaching_persona.id}) |> hide("##{id}")}
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
      Coaching.subscribe_coaching_personas(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Listing Coaching personas")
     |> stream(:coaching_personas, list_coaching_personas(socket.assigns.current_scope))}
  end

  @impl true
  def handle_params(_params, _uri, socket) do
    {:noreply, SpeakFirstAiWeb.LiveAdminHooks.update_current_path(socket)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    coaching_persona = Coaching.get_coaching_persona!(socket.assigns.current_scope, id)
    {:ok, _} = Coaching.delete_coaching_persona(socket.assigns.current_scope, coaching_persona)

    {:noreply, stream_delete(socket, :coaching_personas, coaching_persona)}
  end

  @impl true
  def handle_info({type, %SpeakFirstAi.Coaching.CoachingPersona{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, stream(socket, :coaching_personas, list_coaching_personas(socket.assigns.current_scope), reset: true)}
  end

  defp list_coaching_personas(current_scope) do
    Coaching.list_coaching_personas(current_scope)
  end
end
