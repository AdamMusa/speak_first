defmodule SpeakFirstAi.Lessons.Lesson do
  use Ecto.Schema
  import Ecto.Changeset

  schema "lessons" do
    field :title, :string
    field :description, :string
    field :lesson_type, :string
    field :lesson_difficulty, :string
    field :estimated_minutes, :integer
    field :key_vocabulary, :map
    field :is_active, :boolean, default: false
    field :user_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(lesson, attrs, user_scope) do
    lesson
    |> cast(attrs, [:title, :description, :lesson_type, :lesson_difficulty, :estimated_minutes, :key_vocabulary, :is_active])
    |> validate_required([:title, :description, :lesson_type, :lesson_difficulty, :estimated_minutes, :is_active])
    |> put_change(:user_id, user_scope.user.id)
  end
end
