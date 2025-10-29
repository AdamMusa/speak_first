defmodule SpeakFirstAi.Coaching do
  @moduledoc """
  The Coaching context.
  """

  import Ecto.Query, warn: false
  alias SpeakFirstAi.Repo

  alias SpeakFirstAi.Coaching.CoachingPersona
  alias SpeakFirstAi.Accounts.Scope

  @doc """
  Subscribes to scoped notifications about any coaching_persona changes.

  The broadcasted messages match the pattern:

    * {:created, %CoachingPersona{}}
    * {:updated, %CoachingPersona{}}
    * {:deleted, %CoachingPersona{}}

  """
  def subscribe_coaching_personas(%Scope{} = scope) do
    key = scope.user.id

    Phoenix.PubSub.subscribe(SpeakFirstAi.PubSub, "user:#{key}:coaching_personas")
  end

  defp broadcast_coaching_persona(%Scope{} = scope, message) do
    key = scope.user.id

    Phoenix.PubSub.broadcast(SpeakFirstAi.PubSub, "user:#{key}:coaching_personas", message)
  end

  @doc """
  Returns the list of coaching_personas.

  ## Examples

      iex> list_coaching_personas(scope)
      [%CoachingPersona{}, ...]

  """
  def list_coaching_personas(%Scope{} = scope) do
    from(c in CoachingPersona,
      where: c.user_id == ^scope.user.id,
      order_by: [desc: c.inserted_at]
    )
    |> Repo.all()
  end

  @doc """
  Gets a single coaching_persona.

  Raises `Ecto.NoResultsError` if the Coaching persona does not exist.

  ## Examples

      iex> get_coaching_persona!(scope, 123)
      %CoachingPersona{}

      iex> get_coaching_persona!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_coaching_persona!(%Scope{} = scope, id) do
    Repo.get_by!(CoachingPersona, id: id, user_id: scope.user.id)
  end

  @doc """
  Creates a coaching_persona.

  ## Examples

      iex> create_coaching_persona(scope, %{field: value})
      {:ok, %CoachingPersona{}}

      iex> create_coaching_persona(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_coaching_persona(%Scope{} = scope, attrs) do
    with {:ok, coaching_persona = %CoachingPersona{}} <-
           %CoachingPersona{}
           |> CoachingPersona.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast_coaching_persona(scope, {:created, coaching_persona})
      {:ok, coaching_persona}
    end
  end

  @doc """
  Updates a coaching_persona.

  ## Examples

      iex> update_coaching_persona(scope, coaching_persona, %{field: new_value})
      {:ok, %CoachingPersona{}}

      iex> update_coaching_persona(scope, coaching_persona, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_coaching_persona(%Scope{} = scope, %CoachingPersona{} = coaching_persona, attrs) do
    true = coaching_persona.user_id == scope.user.id

    with {:ok, coaching_persona = %CoachingPersona{}} <-
           coaching_persona
           |> CoachingPersona.changeset(attrs, scope)
           |> Repo.update() do
      broadcast_coaching_persona(scope, {:updated, coaching_persona})
      {:ok, coaching_persona}
    end
  end

  @doc """
  Deletes a coaching_persona.

  ## Examples

      iex> delete_coaching_persona(scope, coaching_persona)
      {:ok, %CoachingPersona{}}

      iex> delete_coaching_persona(scope, coaching_persona)
      {:error, %Ecto.Changeset{}}

  """
  def delete_coaching_persona(%Scope{} = scope, %CoachingPersona{} = coaching_persona) do
    true = coaching_persona.user_id == scope.user.id

    with {:ok, coaching_persona = %CoachingPersona{}} <-
           Repo.delete(coaching_persona) do
      broadcast_coaching_persona(scope, {:deleted, coaching_persona})
      {:ok, coaching_persona}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking coaching_persona changes.

  ## Examples

      iex> change_coaching_persona(scope, coaching_persona)
      %Ecto.Changeset{data: %CoachingPersona{}}

  """
  def change_coaching_persona(%Scope{} = scope, %CoachingPersona{} = coaching_persona, attrs \\ %{}) do
    true = coaching_persona.user_id == scope.user.id

    CoachingPersona.changeset(coaching_persona, attrs, scope)
  end
end
