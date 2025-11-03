defmodule SpeakFirstAi.Repo.Migrations.AddPauseResumeFieldsToLiveSessions do
  use Ecto.Migration

  def change do
    alter table(:live_sessions) do
      add :paused_at, :utc_datetime
      add :total_elapsed_seconds, :integer, default: 0
      add :target_duration_minutes, :integer
    end

    # Update the status constraint to include 'paused'
    drop constraint(:live_sessions, :status_must_be_valid)

    create constraint(:live_sessions, :status_must_be_valid,
      check: "status IN ('pending', 'active', 'paused', 'completed', 'cancelled')"
    )
  end
end
