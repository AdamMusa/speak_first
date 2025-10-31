defmodule SpeakFirstAiWeb.CoachingPersonaLive.Show do
  use SpeakFirstAiWeb, :live_view

  alias SpeakFirstAi.Coaching

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        Coaching persona {@coaching_persona.id}
        <:subtitle>This is a coaching_persona record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/admin/coaching_personas"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button
            variant="primary"
            navigate={~p"/admin/coaching_personas/#{@coaching_persona}/edit?return_to=show"}
          >
            <.icon name="hero-pencil-square" /> Edit coaching_persona
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Title">{@coaching_persona.title}</:item>
        <:item title="Description">{@coaching_persona.description}</:item>
      </.list>
    </div>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Coaching.subscribe_coaching_personas(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Show Coaching persona")
     |> assign(
       :coaching_persona,
       Coaching.get_coaching_persona!(socket.assigns.current_scope, id)
     )}
  end

  @impl true
  def handle_info(
        {:updated, %SpeakFirstAi.Coaching.CoachingPersona{id: id} = coaching_persona},
        %{assigns: %{coaching_persona: %{id: id}}} = socket
      ) do
    {:noreply, assign(socket, :coaching_persona, coaching_persona)}
  end

  def handle_info(
        {:deleted, %SpeakFirstAi.Coaching.CoachingPersona{id: id}},
        %{assigns: %{coaching_persona: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "The current coaching_persona was deleted.")
     |> push_navigate(to: ~p"/admin/coaching_personas")}
  end

  def handle_info({type, %SpeakFirstAi.Coaching.CoachingPersona{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end
end
