defmodule SpeakFirstAiWeb.ConversationTopicLive.Form do
  use SpeakFirstAiWeb, :live_view

  alias SpeakFirstAi.Conversation
  alias SpeakFirstAi.Conversation.ConversationTopic

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-3xl mx-auto">
      <div class="bg-white border border-gray-200 rounded-lg shadow-sm p-6">
        <.header>
          {@page_title}
          <:subtitle>Use this form to manage conversation_topic records in your database.</:subtitle>
        </.header>

        <.form for={@form} id="conversation_topic-form" phx-change="validate" phx-submit="save">
          <.input field={@form[:title]} type="text" label="Title" />
          <.input field={@form[:description]} type="textarea" label="Description" />
          <.input field={@form[:emoji]} type="text" label="Emoji" />
          <div class="mt-6 flex items-center gap-3">
            <.button phx-disable-with="Saving..." variant="primary">Save Conversation topic</.button>
            <.button navigate={return_path(@current_scope, @return_to, @conversation_topic)}>Cancel</.button>
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
    conversation_topic = Conversation.get_conversation_topic!(socket.assigns.current_scope, id)

    socket
    |> assign(:page_title, "Edit Conversation topic")
    |> assign(:conversation_topic, conversation_topic)
    |> assign(:form, to_form(Conversation.change_conversation_topic(socket.assigns.current_scope, conversation_topic)))
  end

  defp apply_action(socket, :new, _params) do
    conversation_topic = %ConversationTopic{user_id: socket.assigns.current_scope.user.id}

    socket
    |> assign(:page_title, "New Conversation topic")
    |> assign(:conversation_topic, conversation_topic)
    |> assign(:form, to_form(Conversation.change_conversation_topic(socket.assigns.current_scope, conversation_topic)))
  end

  @impl true
  def handle_event("validate", %{"conversation_topic" => conversation_topic_params}, socket) do
    changeset = Conversation.change_conversation_topic(socket.assigns.current_scope, socket.assigns.conversation_topic, conversation_topic_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"conversation_topic" => conversation_topic_params}, socket) do
    save_conversation_topic(socket, socket.assigns.live_action, conversation_topic_params)
  end

  defp save_conversation_topic(socket, :edit, conversation_topic_params) do
    case Conversation.update_conversation_topic(socket.assigns.current_scope, socket.assigns.conversation_topic, conversation_topic_params) do
      {:ok, conversation_topic} ->
        {:noreply,
         socket
         |> put_flash(:info, "Conversation topic updated successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, conversation_topic)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_conversation_topic(socket, :new, conversation_topic_params) do
    case Conversation.create_conversation_topic(socket.assigns.current_scope, conversation_topic_params) do
      {:ok, conversation_topic} ->
        {:noreply,
         socket
         |> put_flash(:info, "Conversation topic created successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, conversation_topic)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path(_scope, "index", _conversation_topic), do: ~p"/admin/conversation_topics"
  defp return_path(_scope, "show", conversation_topic), do: ~p"/admin/conversation_topics/#{conversation_topic}"
end
