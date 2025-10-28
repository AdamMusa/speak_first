defmodule SpeakFirstAi.LessonsTest do
  use SpeakFirstAi.DataCase

  alias SpeakFirstAi.Lessons

  describe "lessons" do
    alias SpeakFirstAi.Lessons.Lesson

    import SpeakFirstAi.AccountsFixtures, only: [user_scope_fixture: 0]
    import SpeakFirstAi.LessonsFixtures

    @invalid_attrs %{description: nil, title: nil, lesson_type: nil, lesson_difficulty: nil, estimated_minutes: nil, key_vocabulary: nil, is_active: nil}

    test "list_lessons/1 returns all scoped lessons" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      lesson = lesson_fixture(scope)
      other_lesson = lesson_fixture(other_scope)
      assert Lessons.list_lessons(scope) == [lesson]
      assert Lessons.list_lessons(other_scope) == [other_lesson]
    end

    test "get_lesson!/2 returns the lesson with given id" do
      scope = user_scope_fixture()
      lesson = lesson_fixture(scope)
      other_scope = user_scope_fixture()
      assert Lessons.get_lesson!(scope, lesson.id) == lesson
      assert_raise Ecto.NoResultsError, fn -> Lessons.get_lesson!(other_scope, lesson.id) end
    end

    test "create_lesson/2 with valid data creates a lesson" do
      valid_attrs = %{description: "some description", title: "some title", lesson_type: "some lesson_type", lesson_difficulty: "some lesson_difficulty", estimated_minutes: 42, key_vocabulary: %{}, is_active: true}
      scope = user_scope_fixture()

      assert {:ok, %Lesson{} = lesson} = Lessons.create_lesson(scope, valid_attrs)
      assert lesson.description == "some description"
      assert lesson.title == "some title"
      assert lesson.lesson_type == "some lesson_type"
      assert lesson.lesson_difficulty == "some lesson_difficulty"
      assert lesson.estimated_minutes == 42
      assert lesson.key_vocabulary == %{}
      assert lesson.is_active == true
      assert lesson.user_id == scope.user.id
    end

    test "create_lesson/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Lessons.create_lesson(scope, @invalid_attrs)
    end

    test "update_lesson/3 with valid data updates the lesson" do
      scope = user_scope_fixture()
      lesson = lesson_fixture(scope)
      update_attrs = %{description: "some updated description", title: "some updated title", lesson_type: "some updated lesson_type", lesson_difficulty: "some updated lesson_difficulty", estimated_minutes: 43, key_vocabulary: %{}, is_active: false}

      assert {:ok, %Lesson{} = lesson} = Lessons.update_lesson(scope, lesson, update_attrs)
      assert lesson.description == "some updated description"
      assert lesson.title == "some updated title"
      assert lesson.lesson_type == "some updated lesson_type"
      assert lesson.lesson_difficulty == "some updated lesson_difficulty"
      assert lesson.estimated_minutes == 43
      assert lesson.key_vocabulary == %{}
      assert lesson.is_active == false
    end

    test "update_lesson/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      lesson = lesson_fixture(scope)

      assert_raise MatchError, fn ->
        Lessons.update_lesson(other_scope, lesson, %{})
      end
    end

    test "update_lesson/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      lesson = lesson_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Lessons.update_lesson(scope, lesson, @invalid_attrs)
      assert lesson == Lessons.get_lesson!(scope, lesson.id)
    end

    test "delete_lesson/2 deletes the lesson" do
      scope = user_scope_fixture()
      lesson = lesson_fixture(scope)
      assert {:ok, %Lesson{}} = Lessons.delete_lesson(scope, lesson)
      assert_raise Ecto.NoResultsError, fn -> Lessons.get_lesson!(scope, lesson.id) end
    end

    test "delete_lesson/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      lesson = lesson_fixture(scope)
      assert_raise MatchError, fn -> Lessons.delete_lesson(other_scope, lesson) end
    end

    test "change_lesson/2 returns a lesson changeset" do
      scope = user_scope_fixture()
      lesson = lesson_fixture(scope)
      assert %Ecto.Changeset{} = Lessons.change_lesson(scope, lesson)
    end
  end
end
