defmodule SpeakFirstAi.CoachingFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `SpeakFirstAi.Coaching` context.
  """

  @doc """
  Generate a coaching_persona.
  """
  def coaching_persona_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        description: "some description",
        title: "some title"
      })

    {:ok, coaching_persona} = SpeakFirstAi.Coaching.create_coaching_persona(scope, attrs)
    coaching_persona
  end
end
