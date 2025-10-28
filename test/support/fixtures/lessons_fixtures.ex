defmodule SpeakFirstAi.LessonsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `SpeakFirstAi.Lessons` context.
  """

  @doc """
  Generate a lesson.
  """
  def lesson_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        description: "some description",
        estimated_minutes: 42,
        is_active: true,
        key_vocabulary: %{},
        lesson_difficulty: "some lesson_difficulty",
        lesson_type: "some lesson_type",
        title: "some title"
      })

    {:ok, lesson} = SpeakFirstAi.Lessons.create_lesson(scope, attrs)
    lesson
  end
end
