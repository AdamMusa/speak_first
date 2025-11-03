defmodule SpeakFirstAiWeb.CourseLiveTest do
  use SpeakFirstAiWeb.ConnCase

  import Phoenix.LiveViewTest
  import SpeakFirstAi.CoursesFixtures

  @create_attrs %{title: "some title", descriptions: "some descriptions", content: "some content"}
  @update_attrs %{title: "some updated title", descriptions: "some updated descriptions", content: "some updated content"}
  @invalid_attrs %{title: nil, descriptions: nil, content: nil}

  setup :register_and_log_in_user

  defp create_course(%{scope: scope}) do
    course = course_fixture(scope)

    %{course: course}
  end

  describe "Index" do
    setup [:create_course]

    test "lists all courses", %{conn: conn, course: course} do
      {:ok, _index_live, html} = live(conn, ~p"/courses")

      assert html =~ "Listing Courses"
      assert html =~ course.title
    end

    test "saves new course", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/courses")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Course")
               |> render_click()
               |> follow_redirect(conn, ~p"/courses/new")

      assert render(form_live) =~ "New Course"

      assert form_live
             |> form("#course-form", course: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#course-form", course: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/courses")

      html = render(index_live)
      assert html =~ "Course created successfully"
      assert html =~ "some title"
    end

    test "updates course in listing", %{conn: conn, course: course} do
      {:ok, index_live, _html} = live(conn, ~p"/courses")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#courses-#{course.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/courses/#{course}/edit")

      assert render(form_live) =~ "Edit Course"

      assert form_live
             |> form("#course-form", course: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#course-form", course: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/courses")

      html = render(index_live)
      assert html =~ "Course updated successfully"
      assert html =~ "some updated title"
    end

    test "deletes course in listing", %{conn: conn, course: course} do
      {:ok, index_live, _html} = live(conn, ~p"/courses")

      assert index_live |> element("#courses-#{course.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#courses-#{course.id}")
    end
  end

  describe "Show" do
    setup [:create_course]

    test "displays course", %{conn: conn, course: course} do
      {:ok, _show_live, html} = live(conn, ~p"/courses/#{course}")

      assert html =~ "Show Course"
      assert html =~ course.title
    end

    test "updates course and returns to show", %{conn: conn, course: course} do
      {:ok, show_live, _html} = live(conn, ~p"/courses/#{course}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/courses/#{course}/edit?return_to=show")

      assert render(form_live) =~ "Edit Course"

      assert form_live
             |> form("#course-form", course: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#course-form", course: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/courses/#{course}")

      html = render(show_live)
      assert html =~ "Course updated successfully"
      assert html =~ "some updated title"
    end
  end
end
