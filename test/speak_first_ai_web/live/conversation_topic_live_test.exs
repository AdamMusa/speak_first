defmodule SpeakFirstAiWeb.ConversationTopicLiveTest do
  use SpeakFirstAiWeb.ConnCase

  import Phoenix.LiveViewTest
  import SpeakFirstAi.ConversationFixtures

  @create_attrs %{description: "some description", title: "some title", emoji: "some emoji"}
  @update_attrs %{description: "some updated description", title: "some updated title", emoji: "some updated emoji"}
  @invalid_attrs %{description: nil, title: nil, emoji: nil}

  setup :register_and_log_in_user

  defp create_conversation_topic(%{scope: scope}) do
    conversation_topic = conversation_topic_fixture(scope)

    %{conversation_topic: conversation_topic}
  end

  describe "Index" do
    setup [:create_conversation_topic]

    test "lists all conversations", %{conn: conn, conversation_topic: conversation_topic} do
      {:ok, _index_live, html} = live(conn, ~p"/conversations")

      assert html =~ "Listing Conversations"
      assert html =~ conversation_topic.title
    end

    test "saves new conversation_topic", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/conversations")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Conversation topic")
               |> render_click()
               |> follow_redirect(conn, ~p"/conversations/new")

      assert render(form_live) =~ "New Conversation topic"

      assert form_live
             |> form("#conversation_topic-form", conversation_topic: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#conversation_topic-form", conversation_topic: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/conversations")

      html = render(index_live)
      assert html =~ "Conversation topic created successfully"
      assert html =~ "some title"
    end

    test "updates conversation_topic in listing", %{conn: conn, conversation_topic: conversation_topic} do
      {:ok, index_live, _html} = live(conn, ~p"/conversations")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#conversations-#{conversation_topic.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/conversations/#{conversation_topic}/edit")

      assert render(form_live) =~ "Edit Conversation topic"

      assert form_live
             |> form("#conversation_topic-form", conversation_topic: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#conversation_topic-form", conversation_topic: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/conversations")

      html = render(index_live)
      assert html =~ "Conversation topic updated successfully"
      assert html =~ "some updated title"
    end

    test "deletes conversation_topic in listing", %{conn: conn, conversation_topic: conversation_topic} do
      {:ok, index_live, _html} = live(conn, ~p"/conversations")

      assert index_live |> element("#conversations-#{conversation_topic.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#conversations-#{conversation_topic.id}")
    end
  end

  describe "Show" do
    setup [:create_conversation_topic]

    test "displays conversation_topic", %{conn: conn, conversation_topic: conversation_topic} do
      {:ok, _show_live, html} = live(conn, ~p"/conversations/#{conversation_topic}")

      assert html =~ "Show Conversation topic"
      assert html =~ conversation_topic.title
    end

    test "updates conversation_topic and returns to show", %{conn: conn, conversation_topic: conversation_topic} do
      {:ok, show_live, _html} = live(conn, ~p"/conversations/#{conversation_topic}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/conversations/#{conversation_topic}/edit?return_to=show")

      assert render(form_live) =~ "Edit Conversation topic"

      assert form_live
             |> form("#conversation_topic-form", conversation_topic: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#conversation_topic-form", conversation_topic: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/conversations/#{conversation_topic}")

      html = render(show_live)
      assert html =~ "Conversation topic updated successfully"
      assert html =~ "some updated title"
    end
  end
end
