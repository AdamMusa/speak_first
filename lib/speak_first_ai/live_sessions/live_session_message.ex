defmodule SpeakFirstAi.LiveSessions.LiveSessionMessage do
  use Ecto.Schema
  import Ecto.Changeset

  @sender_values [:ai, :user]

  schema "live_session_messages" do
    field :sender, Ecto.Enum, values: @sender_values
    field :content, :string
    field :recording_url, :string

    belongs_to :live_session, SpeakFirstAi.LiveSessions.LiveSession

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(live_session_message, attrs) do
    live_session_message
    |> cast(attrs, [
      :live_session_id,
      :sender,
      :content,
      :recording_url
    ])
    |> validate_required([:live_session_id, :sender, :content])
    |> validate_inclusion(:sender, @sender_values)
  end
end
