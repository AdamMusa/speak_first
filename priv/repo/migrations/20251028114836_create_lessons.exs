defmodule SpeakFirstAi.Repo.Migrations.CreateLessons do
  use Ecto.Migration

  def change do
    create table(:lessons) do
      add :title, :string
      add :description, :text
      add :lesson_type, :string
      add :lesson_difficulty, :string
      add :estimated_minutes, :integer
      add :key_vocabulary, :map
      add :is_active, :boolean, default: false, null: false
      add :user_id, references(:users, type: :id, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:lessons, [:user_id])
  end
end
