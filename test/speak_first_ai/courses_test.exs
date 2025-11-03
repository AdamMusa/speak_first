defmodule SpeakFirstAi.CoursesTest do
  use SpeakFirstAi.DataCase

  alias SpeakFirstAi.Courses

  describe "courses" do
    alias SpeakFirstAi.Courses.Course

    import SpeakFirstAi.AccountsFixtures, only: [user_scope_fixture: 0]
    import SpeakFirstAi.CoursesFixtures

    @invalid_attrs %{title: nil, descriptions: nil, content: nil}

    test "list_courses/1 returns all scoped courses" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      course = course_fixture(scope)
      other_course = course_fixture(other_scope)
      assert Courses.list_courses(scope) == [course]
      assert Courses.list_courses(other_scope) == [other_course]
    end

    test "get_course!/2 returns the course with given id" do
      scope = user_scope_fixture()
      course = course_fixture(scope)
      other_scope = user_scope_fixture()
      assert Courses.get_course!(scope, course.id) == course
      assert_raise Ecto.NoResultsError, fn -> Courses.get_course!(other_scope, course.id) end
    end

    test "create_course/2 with valid data creates a course" do
      valid_attrs = %{title: "some title", descriptions: "some descriptions", content: "some content"}
      scope = user_scope_fixture()

      assert {:ok, %Course{} = course} = Courses.create_course(scope, valid_attrs)
      assert course.title == "some title"
      assert course.descriptions == "some descriptions"
      assert course.content == "some content"
      assert course.user_id == scope.user.id
    end

    test "create_course/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Courses.create_course(scope, @invalid_attrs)
    end

    test "update_course/3 with valid data updates the course" do
      scope = user_scope_fixture()
      course = course_fixture(scope)
      update_attrs = %{title: "some updated title", descriptions: "some updated descriptions", content: "some updated content"}

      assert {:ok, %Course{} = course} = Courses.update_course(scope, course, update_attrs)
      assert course.title == "some updated title"
      assert course.descriptions == "some updated descriptions"
      assert course.content == "some updated content"
    end

    test "update_course/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      course = course_fixture(scope)

      assert_raise MatchError, fn ->
        Courses.update_course(other_scope, course, %{})
      end
    end

    test "update_course/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      course = course_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Courses.update_course(scope, course, @invalid_attrs)
      assert course == Courses.get_course!(scope, course.id)
    end

    test "delete_course/2 deletes the course" do
      scope = user_scope_fixture()
      course = course_fixture(scope)
      assert {:ok, %Course{}} = Courses.delete_course(scope, course)
      assert_raise Ecto.NoResultsError, fn -> Courses.get_course!(scope, course.id) end
    end

    test "delete_course/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      course = course_fixture(scope)
      assert_raise MatchError, fn -> Courses.delete_course(other_scope, course) end
    end

    test "change_course/2 returns a course changeset" do
      scope = user_scope_fixture()
      course = course_fixture(scope)
      assert %Ecto.Changeset{} = Courses.change_course(scope, course)
    end
  end
end
