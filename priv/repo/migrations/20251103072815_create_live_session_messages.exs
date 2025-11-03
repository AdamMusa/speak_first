defmodule SpeakFirstAi.Repo.Migrations.CreateLiveSessionMessages do
  use Ecto.Migration

  def change do
    create table(:live_session_messages) do
      add :live_session_id, references(:live_sessions, type: :id, on_delete: :delete_all), null: false
      add :sender, :string, null: false
      add :content, :text, null: false
      add :recording_url, :string

      timestamps(type: :utc_datetime)
    end

    create index(:live_session_messages, [:live_session_id])
    create index(:live_session_messages, [:sender])

    # Add check constraint for sender enum values
    create constraint(:live_session_messages, :sender_must_be_valid,
      check: "sender IN ('ai', 'user')"
    )
  end
end
