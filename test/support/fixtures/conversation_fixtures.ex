defmodule SpeakFirstAi.ConversationFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `SpeakFirstAi.Conversation` context.
  """

  @doc """
  Generate a conversation_topic.
  """
  def conversation_topic_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        description: "some description",
        emoji: "some emoji",
        title: "some title"
      })

    {:ok, conversation_topic} = SpeakFirstAi.Conversation.create_conversation_topic(scope, attrs)
    conversation_topic
  end
end
