defmodule SpeakFirstAiWeb.ConversationTopicLive.Show do
  use SpeakFirstAiWeb, :live_view

  alias SpeakFirstAi.Conversation

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        Conversation topic {@conversation_topic.id}
        <:subtitle>This is a conversation_topic record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/admin/conversation_topics"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button
            variant="primary"
            navigate={~p"/admin/conversation_topics/#{@conversation_topic}/edit?return_to=show"}
          >
            <.icon name="hero-pencil-square" /> Edit conversation_topic
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Title">{@conversation_topic.title}</:item>
        <:item title="Description">{@conversation_topic.description}</:item>
        <:item title="Emoji">{@conversation_topic.emoji}</:item>
      </.list>
    </div>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Conversation.subscribe_conversations(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Show Conversation topic")
     |> assign(
       :conversation_topic,
       Conversation.get_conversation_topic!(socket.assigns.current_scope, id)
     )}
  end

  @impl true
  def handle_info(
        {:updated, %SpeakFirstAi.Conversation.ConversationTopic{id: id} = conversation_topic},
        %{assigns: %{conversation_topic: %{id: id}}} = socket
      ) do
    {:noreply, assign(socket, :conversation_topic, conversation_topic)}
  end

  def handle_info(
        {:deleted, %SpeakFirstAi.Conversation.ConversationTopic{id: id}},
        %{assigns: %{conversation_topic: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "The current conversation_topic was deleted.")
     |> push_navigate(to: ~p"/admin/conversation_topics")}
  end

  def handle_info({type, %SpeakFirstAi.Conversation.ConversationTopic{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end
end
