defmodule SpeakFirstAi.Conversation.ConversationTopic do
  use Ecto.Schema
  import Ecto.Changeset

  schema "conversations" do
    field :title, :string
    field :description, :string
    field :emoji, :string
    field :recommanded_persona, :id
    field :user_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(conversation_topic, attrs, user_scope) do
    conversation_topic
    |> cast(attrs, [:title, :description, :emoji])
    |> validate_required([:title, :description, :emoji])
    |> put_change(:user_id, user_scope.user.id)
  end
end
