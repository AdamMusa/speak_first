defmodule SpeakFirstAi.Repo.Migrations.AddIsCompletedAndCourseIdToLessons do
  use Ecto.Migration

  def change do
    alter table(:lessons) do
      add :is_completed, :boolean, default: false, null: false
      add :course_id, references(:courses, type: :id, on_delete: :delete_all)
    end

    create index(:lessons, [:course_id])
  end
end
