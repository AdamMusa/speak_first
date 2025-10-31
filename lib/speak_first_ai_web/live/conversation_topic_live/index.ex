defmodule SpeakFirstAiWeb.ConversationTopicLive.Index do
  use SpeakFirstAiWeb, :live_view

  alias SpeakFirstAi.Conversation

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        Listing Conversations
        <:actions>
          <.button variant="primary" navigate={~p"/admin/conversation_topics/new"}>
            <.icon name="hero-plus" /> New Conversation topic
          </.button>
        </:actions>
      </.header>

      <.table
        id="conversations"
        rows={@streams.conversations}
        row_click={
          fn {_id, conversation_topic} ->
            JS.navigate(~p"/admin/conversation_topics/#{conversation_topic}")
          end
        }
      >
        <:col :let={{_id, conversation_topic}} label="Title">{conversation_topic.title}</:col>
        <:col :let={{_id, conversation_topic}} label="Description">
          {conversation_topic.description}
        </:col>
        <:col :let={{_id, conversation_topic}} label="Emoji">{conversation_topic.emoji}</:col>
        <:action :let={{_id, conversation_topic}}>
          <div class="sr-only">
            <.link navigate={~p"/admin/conversation_topics/#{conversation_topic}"}>Show</.link>
          </div>
          <.link navigate={~p"/admin/conversation_topics/#{conversation_topic}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, conversation_topic}}>
          <.link
            phx-click={JS.push("delete", value: %{id: conversation_topic.id}) |> hide("##{id}")}
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
      Conversation.subscribe_conversations(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Listing Conversations")
     |> stream(:conversations, list_conversations(socket.assigns.current_scope))}
  end

  @impl true
  def handle_params(_params, _uri, socket) do
    {:noreply, SpeakFirstAiWeb.LiveAdminHooks.update_current_path(socket)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    conversation_topic = Conversation.get_conversation_topic!(socket.assigns.current_scope, id)

    {:ok, _} =
      Conversation.delete_conversation_topic(socket.assigns.current_scope, conversation_topic)

    {:noreply, stream_delete(socket, :conversations, conversation_topic)}
  end

  @impl true
  def handle_info({type, %SpeakFirstAi.Conversation.ConversationTopic{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply,
     stream(socket, :conversations, list_conversations(socket.assigns.current_scope), reset: true)}
  end

  defp list_conversations(current_scope) do
    Conversation.list_conversations(current_scope)
  end
end
