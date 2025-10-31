defmodule SpeakFirstAi.Repo.Migrations.CreateSubscriptions do
  use Ecto.Migration

  def change do
    create table(:subscriptions) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :stripe_subscription_id, :string
      add :status, :string
      add :plan, :string
      add :current_period_end, :utc_datetime
      add :cancel_at_period_end, :boolean, default: false
      add :subscription_plan_id, references(:subscription_plan, on_delete: :restrict), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:subscriptions, [:user_id])
    create index(:subscriptions, [:subscription_plan_id])
  end
end
