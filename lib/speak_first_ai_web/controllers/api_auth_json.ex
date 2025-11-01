defmodule SpeakFirstAiWeb.ApiAuthJSON do
  @moduledoc """
  JSON rendering for API authentication endpoints.
  """

  def render("register.json", %{user: user, access_token: access_token, refresh_token: refresh_token}) do
    %{
      user: %{
        id: user.id,
        email: user.email
      },
      access_token: access_token,
      refresh_token: refresh_token
    }
  end

  def render("login.json", %{user: user, access_token: access_token, refresh_token: refresh_token}) do
    %{
      user: %{
        id: user.id,
        email: user.email
      },
      access_token: access_token,
      refresh_token: refresh_token
    }
  end

  def render("refresh.json", %{access_token: access_token, refresh_token: refresh_token}) do
    %{
      access_token: access_token,
      refresh_token: refresh_token
    }
  end

  def render("error.json", %{changeset: changeset}) do
    %{
      errors: translate_errors(changeset)
    }
  end

  defp translate_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, &translate_error/1)
  end

  defp translate_error({msg, opts}) do
    Enum.reduce(opts, msg, fn {key, value}, acc ->
      String.replace(acc, "%{#{key}}", to_string(value))
    end)
  end
end
