defmodule SpeakFirstAi.ConversationTest do
  use SpeakFirstAi.DataCase

  alias SpeakFirstAi.Conversation

  describe "conversations" do
    alias SpeakFirstAi.Conversation.ConversationTopic

    import SpeakFirstAi.AccountsFixtures, only: [user_scope_fixture: 0]
    import SpeakFirstAi.ConversationFixtures

    @invalid_attrs %{description: nil, title: nil, emoji: nil}

    test "list_conversations/1 returns all scoped conversations" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      conversation_topic = conversation_topic_fixture(scope)
      other_conversation_topic = conversation_topic_fixture(other_scope)
      assert Conversation.list_conversations(scope) == [conversation_topic]
      assert Conversation.list_conversations(other_scope) == [other_conversation_topic]
    end

    test "get_conversation_topic!/2 returns the conversation_topic with given id" do
      scope = user_scope_fixture()
      conversation_topic = conversation_topic_fixture(scope)
      other_scope = user_scope_fixture()

      assert Conversation.get_conversation_topic!(scope, conversation_topic.id) ==
               conversation_topic

      assert_raise Ecto.NoResultsError, fn ->
        Conversation.get_conversation_topic!(other_scope, conversation_topic.id)
      end
    end

    test "create_conversation_topic/2 with valid data creates a conversation_topic" do
      valid_attrs = %{description: "some description", title: "some title", emoji: "some emoji"}
      scope = user_scope_fixture()

      assert {:ok, %ConversationTopic{} = conversation_topic} =
               Conversation.create_conversation_topic(scope, valid_attrs)

      assert conversation_topic.description == "some description"
      assert conversation_topic.title == "some title"
      assert conversation_topic.emoji == "some emoji"
      assert conversation_topic.user_id == scope.user.id
    end

    test "create_conversation_topic/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Conversation.create_conversation_topic(scope, @invalid_attrs)
    end

    test "update_conversation_topic/3 with valid data updates the conversation_topic" do
      scope = user_scope_fixture()
      conversation_topic = conversation_topic_fixture(scope)

      update_attrs = %{
        description: "some updated description",
        title: "some updated title",
        emoji: "some updated emoji"
      }

      assert {:ok, %ConversationTopic{} = conversation_topic} =
               Conversation.update_conversation_topic(scope, conversation_topic, update_attrs)

      assert conversation_topic.description == "some updated description"
      assert conversation_topic.title == "some updated title"
      assert conversation_topic.emoji == "some updated emoji"
    end

    test "update_conversation_topic/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      conversation_topic = conversation_topic_fixture(scope)

      assert_raise MatchError, fn ->
        Conversation.update_conversation_topic(other_scope, conversation_topic, %{})
      end
    end

    test "update_conversation_topic/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      conversation_topic = conversation_topic_fixture(scope)

      assert {:error, %Ecto.Changeset{}} =
               Conversation.update_conversation_topic(scope, conversation_topic, @invalid_attrs)

      assert conversation_topic ==
               Conversation.get_conversation_topic!(scope, conversation_topic.id)
    end

    test "delete_conversation_topic/2 deletes the conversation_topic" do
      scope = user_scope_fixture()
      conversation_topic = conversation_topic_fixture(scope)

      assert {:ok, %ConversationTopic{}} =
               Conversation.delete_conversation_topic(scope, conversation_topic)

      assert_raise Ecto.NoResultsError, fn ->
        Conversation.get_conversation_topic!(scope, conversation_topic.id)
      end
    end

    test "delete_conversation_topic/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      conversation_topic = conversation_topic_fixture(scope)

      assert_raise MatchError, fn ->
        Conversation.delete_conversation_topic(other_scope, conversation_topic)
      end
    end

    test "change_conversation_topic/2 returns a conversation_topic changeset" do
      scope = user_scope_fixture()
      conversation_topic = conversation_topic_fixture(scope)
      assert %Ecto.Changeset{} = Conversation.change_conversation_topic(scope, conversation_topic)
    end
  end
end
