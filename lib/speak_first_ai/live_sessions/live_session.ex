defmodule SpeakFirstAi.LiveSessions.LiveSession do
  use Ecto.Schema
  import Ecto.Changeset

  @status_values [:pending, :active, :paused, :completed, :cancelled]

  schema "live_sessions" do
    field :started_at, :utc_datetime
    field :ended_at, :utc_datetime
    field :duration_minutes, :integer
    field :paused_at, :utc_datetime
    field :total_elapsed_seconds, :integer, default: 0
    field :target_duration_minutes, :integer
    field :status, Ecto.Enum, values: @status_values, default: :pending
    field :notes, :string

    belongs_to :user, SpeakFirstAi.Accounts.User
    belongs_to :lesson, SpeakFirstAi.Lessons.Lesson

    has_many :messages, SpeakFirstAi.LiveSessions.LiveSessionMessage

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(live_session, attrs) do
    live_session
    |> cast(attrs, [
      :user_id,
      :lesson_id,
      :started_at,
      :ended_at,
      :duration_minutes,
      :paused_at,
      :total_elapsed_seconds,
      :target_duration_minutes,
      :status,
      :notes
    ])
    |> validate_required([:user_id, :lesson_id, :started_at, :status])
    |> validate_inclusion(:status, @status_values)
    |> compute_duration()
  end

  defp compute_duration(%Ecto.Changeset{} = changeset) do
    started_at = get_field(changeset, :started_at)
    ended_at = get_field(changeset, :ended_at)

    if started_at && ended_at do
      duration_minutes =
        DateTime.diff(ended_at, started_at, :second)
        |> div(60)

      put_change(changeset, :duration_minutes, duration_minutes)
    else
      changeset
    end
  end
end
