defmodule SpeakFirstAi.CoursesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `SpeakFirstAi.Courses` context.
  """

  @doc """
  Generate a course.
  """
  def course_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        content: "some content",
        descriptions: "some descriptions",
        title: "some title"
      })

    {:ok, course} = SpeakFirstAi.Courses.create_course(scope, attrs)
    course
  end
end
