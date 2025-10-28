defmodule SpeakFirstAi.Repo.Migrations.CreateCoachingPersonas do
  use Ecto.Migration

  def change do
    create table(:coaching_personas) do
      add :title, :string
      add :description, :text
      add :user_id, references(:users, type: :id, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:coaching_personas, [:user_id])
  end
end
