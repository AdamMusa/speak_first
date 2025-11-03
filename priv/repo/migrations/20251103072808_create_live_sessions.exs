defmodule SpeakFirstAi.Repo.Migrations.CreateLiveSessions do
  use Ecto.Migration

  def change do
    create table(:live_sessions) do
      add :user_id, references(:users, type: :id, on_delete: :delete_all), null: false
      add :lesson_id, references(:lessons, type: :id, on_delete: :delete_all), null: false
      add :started_at, :utc_datetime, null: false
      add :ended_at, :utc_datetime
      add :duration_minutes, :integer
      add :status, :string, null: false, default: "pending"
      add :notes, :text

      timestamps(type: :utc_datetime)
    end

    create index(:live_sessions, [:user_id])
    create index(:live_sessions, [:lesson_id])
    create index(:live_sessions, [:status])

    # Add check constraint for status enum values (will be updated in later migration to include 'paused')
    create constraint(:live_sessions, :status_must_be_valid,
      check: "status IN ('pending', 'active', 'completed', 'cancelled')"
    )
  end
end
