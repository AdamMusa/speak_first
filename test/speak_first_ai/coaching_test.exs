defmodule SpeakFirstAi.CoachingTest do
  use SpeakFirstAi.DataCase

  alias SpeakFirstAi.Coaching

  describe "coaching_personas" do
    alias SpeakFirstAi.Coaching.CoachingPersona

    import SpeakFirstAi.AccountsFixtures, only: [user_scope_fixture: 0]
    import SpeakFirstAi.CoachingFixtures

    @invalid_attrs %{description: nil, title: nil}

    test "list_coaching_personas/1 returns all scoped coaching_personas" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      coaching_persona = coaching_persona_fixture(scope)
      other_coaching_persona = coaching_persona_fixture(other_scope)
      assert Coaching.list_coaching_personas(scope) == [coaching_persona]
      assert Coaching.list_coaching_personas(other_scope) == [other_coaching_persona]
    end

    test "get_coaching_persona!/2 returns the coaching_persona with given id" do
      scope = user_scope_fixture()
      coaching_persona = coaching_persona_fixture(scope)
      other_scope = user_scope_fixture()
      assert Coaching.get_coaching_persona!(scope, coaching_persona.id) == coaching_persona
      assert_raise Ecto.NoResultsError, fn -> Coaching.get_coaching_persona!(other_scope, coaching_persona.id) end
    end

    test "create_coaching_persona/2 with valid data creates a coaching_persona" do
      valid_attrs = %{description: "some description", title: "some title"}
      scope = user_scope_fixture()

      assert {:ok, %CoachingPersona{} = coaching_persona} = Coaching.create_coaching_persona(scope, valid_attrs)
      assert coaching_persona.description == "some description"
      assert coaching_persona.title == "some title"
      assert coaching_persona.user_id == scope.user.id
    end

    test "create_coaching_persona/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Coaching.create_coaching_persona(scope, @invalid_attrs)
    end

    test "update_coaching_persona/3 with valid data updates the coaching_persona" do
      scope = user_scope_fixture()
      coaching_persona = coaching_persona_fixture(scope)
      update_attrs = %{description: "some updated description", title: "some updated title"}

      assert {:ok, %CoachingPersona{} = coaching_persona} = Coaching.update_coaching_persona(scope, coaching_persona, update_attrs)
      assert coaching_persona.description == "some updated description"
      assert coaching_persona.title == "some updated title"
    end

    test "update_coaching_persona/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      coaching_persona = coaching_persona_fixture(scope)

      assert_raise MatchError, fn ->
        Coaching.update_coaching_persona(other_scope, coaching_persona, %{})
      end
    end

    test "update_coaching_persona/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      coaching_persona = coaching_persona_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Coaching.update_coaching_persona(scope, coaching_persona, @invalid_attrs)
      assert coaching_persona == Coaching.get_coaching_persona!(scope, coaching_persona.id)
    end

    test "delete_coaching_persona/2 deletes the coaching_persona" do
      scope = user_scope_fixture()
      coaching_persona = coaching_persona_fixture(scope)
      assert {:ok, %CoachingPersona{}} = Coaching.delete_coaching_persona(scope, coaching_persona)
      assert_raise Ecto.NoResultsError, fn -> Coaching.get_coaching_persona!(scope, coaching_persona.id) end
    end

    test "delete_coaching_persona/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      coaching_persona = coaching_persona_fixture(scope)
      assert_raise MatchError, fn -> Coaching.delete_coaching_persona(other_scope, coaching_persona) end
    end

    test "change_coaching_persona/2 returns a coaching_persona changeset" do
      scope = user_scope_fixture()
      coaching_persona = coaching_persona_fixture(scope)
      assert %Ecto.Changeset{} = Coaching.change_coaching_persona(scope, coaching_persona)
    end
  end
end
