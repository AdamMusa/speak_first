defmodule SpeakFirstAi.Repo.Migrations.CreateSubscriptionPlan do
  use Ecto.Migration

  def change do
    create table(:subscription_plan) do
      add :name, :string
      add :description, :text
      add :price_cents, :float
      add :currency, :string
      add :interval, :string
      add :stripe_price_id, :string
      add :active, :boolean, default: false, null: false
      add :trial_period_days, :integer
      add :user_id, references(:users, type: :id, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:subscription_plan, [:user_id])
  end
end
