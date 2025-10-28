defmodule SpeakFirstAiWeb.LessonLiveTest do
  use SpeakFirstAiWeb.ConnCase

  import Phoenix.LiveViewTest
  import SpeakFirstAi.LessonsFixtures

  @create_attrs %{description: "some description", title: "some title", lesson_type: "some lesson_type", lesson_difficulty: "some lesson_difficulty", estimated_minutes: 42, key_vocabulary: %{}, is_active: true}
  @update_attrs %{description: "some updated description", title: "some updated title", lesson_type: "some updated lesson_type", lesson_difficulty: "some updated lesson_difficulty", estimated_minutes: 43, key_vocabulary: %{}, is_active: false}
  @invalid_attrs %{description: nil, title: nil, lesson_type: nil, lesson_difficulty: nil, estimated_minutes: nil, key_vocabulary: nil, is_active: false}

  setup :register_and_log_in_user

  defp create_lesson(%{scope: scope}) do
    lesson = lesson_fixture(scope)

    %{lesson: lesson}
  end

  describe "Index" do
    setup [:create_lesson]

    test "lists all lessons", %{conn: conn, lesson: lesson} do
      {:ok, _index_live, html} = live(conn, ~p"/lessons")

      assert html =~ "Listing Lessons"
      assert html =~ lesson.title
    end

    test "saves new lesson", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/lessons")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Lesson")
               |> render_click()
               |> follow_redirect(conn, ~p"/lessons/new")

      assert render(form_live) =~ "New Lesson"

      assert form_live
             |> form("#lesson-form", lesson: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#lesson-form", lesson: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/lessons")

      html = render(index_live)
      assert html =~ "Lesson created successfully"
      assert html =~ "some title"
    end

    test "updates lesson in listing", %{conn: conn, lesson: lesson} do
      {:ok, index_live, _html} = live(conn, ~p"/lessons")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#lessons-#{lesson.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/lessons/#{lesson}/edit")

      assert render(form_live) =~ "Edit Lesson"

      assert form_live
             |> form("#lesson-form", lesson: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#lesson-form", lesson: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/lessons")

      html = render(index_live)
      assert html =~ "Lesson updated successfully"
      assert html =~ "some updated title"
    end

    test "deletes lesson in listing", %{conn: conn, lesson: lesson} do
      {:ok, index_live, _html} = live(conn, ~p"/lessons")

      assert index_live |> element("#lessons-#{lesson.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#lessons-#{lesson.id}")
    end
  end

  describe "Show" do
    setup [:create_lesson]

    test "displays lesson", %{conn: conn, lesson: lesson} do
      {:ok, _show_live, html} = live(conn, ~p"/lessons/#{lesson}")

      assert html =~ "Show Lesson"
      assert html =~ lesson.title
    end

    test "updates lesson and returns to show", %{conn: conn, lesson: lesson} do
      {:ok, show_live, _html} = live(conn, ~p"/lessons/#{lesson}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/lessons/#{lesson}/edit?return_to=show")

      assert render(form_live) =~ "Edit Lesson"

      assert form_live
             |> form("#lesson-form", lesson: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#lesson-form", lesson: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/lessons/#{lesson}")

      html = render(show_live)
      assert html =~ "Lesson updated successfully"
      assert html =~ "some updated title"
    end
  end
end
