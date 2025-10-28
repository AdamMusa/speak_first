defmodule SpeakFirstAiWeb.CoachingPersonaLiveTest do
  use SpeakFirstAiWeb.ConnCase

  import Phoenix.LiveViewTest
  import SpeakFirstAi.CoachingFixtures

  @create_attrs %{description: "some description", title: "some title"}
  @update_attrs %{description: "some updated description", title: "some updated title"}
  @invalid_attrs %{description: nil, title: nil}

  setup :register_and_log_in_user

  defp create_coaching_persona(%{scope: scope}) do
    coaching_persona = coaching_persona_fixture(scope)

    %{coaching_persona: coaching_persona}
  end

  describe "Index" do
    setup [:create_coaching_persona]

    test "lists all coaching_personas", %{conn: conn, coaching_persona: coaching_persona} do
      {:ok, _index_live, html} = live(conn, ~p"/coaching_personas")

      assert html =~ "Listing Coaching personas"
      assert html =~ coaching_persona.title
    end

    test "saves new coaching_persona", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/coaching_personas")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Coaching persona")
               |> render_click()
               |> follow_redirect(conn, ~p"/coaching_personas/new")

      assert render(form_live) =~ "New Coaching persona"

      assert form_live
             |> form("#coaching_persona-form", coaching_persona: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#coaching_persona-form", coaching_persona: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/coaching_personas")

      html = render(index_live)
      assert html =~ "Coaching persona created successfully"
      assert html =~ "some title"
    end

    test "updates coaching_persona in listing", %{conn: conn, coaching_persona: coaching_persona} do
      {:ok, index_live, _html} = live(conn, ~p"/coaching_personas")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#coaching_personas-#{coaching_persona.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/coaching_personas/#{coaching_persona}/edit")

      assert render(form_live) =~ "Edit Coaching persona"

      assert form_live
             |> form("#coaching_persona-form", coaching_persona: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#coaching_persona-form", coaching_persona: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/coaching_personas")

      html = render(index_live)
      assert html =~ "Coaching persona updated successfully"
      assert html =~ "some updated title"
    end

    test "deletes coaching_persona in listing", %{conn: conn, coaching_persona: coaching_persona} do
      {:ok, index_live, _html} = live(conn, ~p"/coaching_personas")

      assert index_live |> element("#coaching_personas-#{coaching_persona.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#coaching_personas-#{coaching_persona.id}")
    end
  end

  describe "Show" do
    setup [:create_coaching_persona]

    test "displays coaching_persona", %{conn: conn, coaching_persona: coaching_persona} do
      {:ok, _show_live, html} = live(conn, ~p"/coaching_personas/#{coaching_persona}")

      assert html =~ "Show Coaching persona"
      assert html =~ coaching_persona.title
    end

    test "updates coaching_persona and returns to show", %{conn: conn, coaching_persona: coaching_persona} do
      {:ok, show_live, _html} = live(conn, ~p"/coaching_personas/#{coaching_persona}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/coaching_personas/#{coaching_persona}/edit?return_to=show")

      assert render(form_live) =~ "Edit Coaching persona"

      assert form_live
             |> form("#coaching_persona-form", coaching_persona: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#coaching_persona-form", coaching_persona: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/coaching_personas/#{coaching_persona}")

      html = render(show_live)
      assert html =~ "Coaching persona updated successfully"
      assert html =~ "some updated title"
    end
  end
end
