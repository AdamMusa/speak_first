defmodule SpeakFirstAi.Courses.Course do
  use Ecto.Schema
  import Ecto.Changeset

  schema "courses" do
    field :title, :string
    field :descriptions, :string
    field :content, :string
    field :user_id, :id

    has_many :lessons, SpeakFirstAi.Lessons.Lesson

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(course, attrs, user_scope) do
    course
    |> cast(attrs, [:title, :descriptions, :content])
    |> validate_required([:title, :descriptions, :content])
    |> put_change(:user_id, user_scope.user.id)
  end
end
