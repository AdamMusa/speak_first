defmodule SpeakFirstAi.Coaching.CoachingPersona do
  use Ecto.Schema
  import Ecto.Changeset

  schema "coaching_personas" do
    field :title, :string
    field :description, :string
    field :user_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(coaching_persona, attrs, user_scope) do
    coaching_persona
    |> cast(attrs, [:title, :description])
    |> validate_required([:title, :description])
    |> put_change(:user_id, user_scope.user.id)
  end
end
