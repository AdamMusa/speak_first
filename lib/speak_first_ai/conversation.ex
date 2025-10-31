defmodule SpeakFirstAi.Conversation do
  @moduledoc """
  The Conversation context.
  """

  import Ecto.Query, warn: false
  alias SpeakFirstAi.Repo

  alias SpeakFirstAi.Conversation.ConversationTopic
  alias SpeakFirstAi.Accounts.Scope

  @doc """
  Subscribes to scoped notifications about any conversation_topic changes.

  The broadcasted messages match the pattern:

    * {:created, %ConversationTopic{}}
    * {:updated, %ConversationTopic{}}
    * {:deleted, %ConversationTopic{}}

  """
  def subscribe_conversations(%Scope{} = scope) do
    key = scope.user.id

    Phoenix.PubSub.subscribe(SpeakFirstAi.PubSub, "user:#{key}:conversations")
  end

  defp broadcast_conversation_topic(%Scope{} = scope, message) do
    key = scope.user.id

    Phoenix.PubSub.broadcast(SpeakFirstAi.PubSub, "user:#{key}:conversations", message)
  end

  @doc """
  Returns the list of conversations.

  ## Examples

      iex> list_conversations(scope)
      [%ConversationTopic{}, ...]

  """
  def list_conversations(%Scope{} = scope) do
    from(c in ConversationTopic, where: c.user_id == ^scope.user.id)
    |> Repo.all()
  end

  @doc """
  Gets a single conversation_topic.

  Raises `Ecto.NoResultsError` if the Conversation topic does not exist.

  ## Examples

      iex> get_conversation_topic!(scope, 123)
      %ConversationTopic{}

      iex> get_conversation_topic!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_conversation_topic!(%Scope{} = scope, id) do
    Repo.get_by!(ConversationTopic, id: id, user_id: scope.user.id)
  end

  @doc """
  Creates a conversation_topic.

  ## Examples

      iex> create_conversation_topic(scope, %{field: value})
      {:ok, %ConversationTopic{}}

      iex> create_conversation_topic(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_conversation_topic(%Scope{} = scope, attrs) do
    with {:ok, conversation_topic = %ConversationTopic{}} <-
           %ConversationTopic{}
           |> ConversationTopic.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast_conversation_topic(scope, {:created, conversation_topic})
      {:ok, conversation_topic}
    end
  end

  @doc """
  Updates a conversation_topic.

  ## Examples

      iex> update_conversation_topic(scope, conversation_topic, %{field: new_value})
      {:ok, %ConversationTopic{}}

      iex> update_conversation_topic(scope, conversation_topic, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_conversation_topic(
        %Scope{} = scope,
        %ConversationTopic{} = conversation_topic,
        attrs
      ) do
    true = conversation_topic.user_id == scope.user.id

    with {:ok, conversation_topic = %ConversationTopic{}} <-
           conversation_topic
           |> ConversationTopic.changeset(attrs, scope)
           |> Repo.update() do
      broadcast_conversation_topic(scope, {:updated, conversation_topic})
      {:ok, conversation_topic}
    end
  end

  @doc """
  Deletes a conversation_topic.

  ## Examples

      iex> delete_conversation_topic(scope, conversation_topic)
      {:ok, %ConversationTopic{}}

      iex> delete_conversation_topic(scope, conversation_topic)
      {:error, %Ecto.Changeset{}}

  """
  def delete_conversation_topic(%Scope{} = scope, %ConversationTopic{} = conversation_topic) do
    true = conversation_topic.user_id == scope.user.id

    with {:ok, conversation_topic = %ConversationTopic{}} <-
           Repo.delete(conversation_topic) do
      broadcast_conversation_topic(scope, {:deleted, conversation_topic})
      {:ok, conversation_topic}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking conversation_topic changes.

  ## Examples

      iex> change_conversation_topic(scope, conversation_topic)
      %Ecto.Changeset{data: %ConversationTopic{}}

  """
  def change_conversation_topic(
        %Scope{} = scope,
        %ConversationTopic{} = conversation_topic,
        attrs \\ %{}
      ) do
    true = conversation_topic.user_id == scope.user.id

    ConversationTopic.changeset(conversation_topic, attrs, scope)
  end
end
