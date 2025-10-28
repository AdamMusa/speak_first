defmodule SpeakFirstAi.Repo.Migrations.CreateConversations do
  use Ecto.Migration

  def change do
    create table(:conversations) do
      add :title, :string
      add :description, :text
      add :emoji, :string
      add :recommanded_persona, references(:coaching_personas, on_delete: :nothing)
      add :user_id, references(:users, type: :id, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:conversations, [:user_id])

    create index(:conversations, [:recommanded_persona])
  end
end
