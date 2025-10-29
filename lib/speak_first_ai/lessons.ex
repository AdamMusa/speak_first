defmodule SpeakFirstAi.Lessons do
  @moduledoc """
  The Lessons context.
  """

  import Ecto.Query, warn: false
  alias SpeakFirstAi.Repo

  alias SpeakFirstAi.Lessons.Lesson
  alias SpeakFirstAi.Accounts.Scope

  @doc """
  Subscribes to scoped notifications about any lesson changes.

  The broadcasted messages match the pattern:

    * {:created, %Lesson{}}
    * {:updated, %Lesson{}}
    * {:deleted, %Lesson{}}

  """
  def subscribe_lessons(%Scope{} = scope) do
    key = scope.user.id

    Phoenix.PubSub.subscribe(SpeakFirstAi.PubSub, "user:#{key}:lessons")
  end

  defp broadcast_lesson(%Scope{} = scope, message) do
    key = scope.user.id

    Phoenix.PubSub.broadcast(SpeakFirstAi.PubSub, "user:#{key}:lessons", message)
  end

  @doc """
  Returns the list of lessons.

  ## Examples

      iex> list_lessons(scope)
      [%Lesson{}, ...]

  """
  def list_lessons(%Scope{} = scope) do
    from(l in Lesson, where: l.user_id == ^scope.user.id)
    |> Repo.all()
  end

  @doc """
  Gets a single lesson.

  Raises `Ecto.NoResultsError` if the Lesson does not exist.

  ## Examples

      iex> get_lesson!(scope, 123)
      %Lesson{}

      iex> get_lesson!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_lesson!(%Scope{} = scope, id) do
    Repo.get_by!(Lesson, id: id, user_id: scope.user.id)
  end

  @doc """
  Creates a lesson.

  ## Examples

      iex> create_lesson(scope, %{field: value})
      {:ok, %Lesson{}}

      iex> create_lesson(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_lesson(%Scope{} = scope, attrs) do
    with {:ok, lesson = %Lesson{}} <-
           %Lesson{}
           |> Lesson.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast_lesson(scope, {:created, lesson})
      {:ok, lesson}
    end
  end

  @doc """
  Updates a lesson.

  ## Examples

      iex> update_lesson(scope, lesson, %{field: new_value})
      {:ok, %Lesson{}}

      iex> update_lesson(scope, lesson, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_lesson(%Scope{} = scope, %Lesson{} = lesson, attrs) do
    true = lesson.user_id == scope.user.id

    with {:ok, lesson = %Lesson{}} <-
           lesson
           |> Lesson.changeset(attrs, scope)
           |> Repo.update() do
      broadcast_lesson(scope, {:updated, lesson})
      {:ok, lesson}
    end
  end

  @doc """
  Deletes a lesson.

  ## Examples

      iex> delete_lesson(scope, lesson)
      {:ok, %Lesson{}}

      iex> delete_lesson(scope, lesson)
      {:error, %Ecto.Changeset{}}

  """
  def delete_lesson(%Scope{} = scope, %Lesson{} = lesson) do
    true = lesson.user_id == scope.user.id

    with {:ok, lesson = %Lesson{}} <-
           Repo.delete(lesson) do
      broadcast_lesson(scope, {:deleted, lesson})
      {:ok, lesson}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking lesson changes.

  ## Examples

      iex> change_lesson(scope, lesson)
      %Ecto.Changeset{data: %Lesson{}}

  """
  def change_lesson(%Scope{} = scope, %Lesson{} = lesson, attrs \\ %{}) do
    true = lesson.user_id == scope.user.id

    Lesson.changeset(lesson, attrs, scope)
  end
end
