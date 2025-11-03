defmodule SpeakFirstAi.Courses do
  @moduledoc """
  The Courses context.
  """

  import Ecto.Query, warn: false
  alias SpeakFirstAi.Repo

  alias SpeakFirstAi.Courses.Course
  alias SpeakFirstAi.Accounts.Scope

  @doc """
  Subscribes to scoped notifications about any course changes.

  The broadcasted messages match the pattern:

    * {:created, %Course{}}
    * {:updated, %Course{}}
    * {:deleted, %Course{}}

  """
  def subscribe_courses(%Scope{} = scope) do
    key = scope.user.id

    Phoenix.PubSub.subscribe(SpeakFirstAi.PubSub, "user:#{key}:courses")
  end

  defp broadcast_course(%Scope{} = scope, message) do
    key = scope.user.id

    Phoenix.PubSub.broadcast(SpeakFirstAi.PubSub, "user:#{key}:courses", message)
  end

  @doc """
  Returns the list of courses.

  ## Examples

      iex> list_courses(scope)
      [%Course{}, ...]

  """
  def list_courses(%Scope{} = scope) do
    from(c in Course, where: c.user_id == ^scope.user.id)
    |> Repo.all()
  end

  @doc """
  Gets a single course.

  Raises `Ecto.NoResultsError` if the Course does not exist.

  ## Examples

      iex> get_course!(scope, 123)
      %Course{}

      iex> get_course!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_course!(%Scope{} = scope, id) do
    Repo.get_by!(Course, id: id, user_id: scope.user.id)
  end

  @doc """
  Creates a course.

  ## Examples

      iex> create_course(scope, %{field: value})
      {:ok, %Course{}}

      iex> create_course(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_course(%Scope{} = scope, attrs) do
    with {:ok, course = %Course{}} <-
           %Course{}
           |> Course.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast_course(scope, {:created, course})
      {:ok, course}
    end
  end

  @doc """
  Updates a course.

  ## Examples

      iex> update_course(scope, course, %{field: new_value})
      {:ok, %Course{}}

      iex> update_course(scope, course, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_course(%Scope{} = scope, %Course{} = course, attrs) do
    true = course.user_id == scope.user.id

    with {:ok, course = %Course{}} <-
           course
           |> Course.changeset(attrs, scope)
           |> Repo.update() do
      broadcast_course(scope, {:updated, course})
      {:ok, course}
    end
  end

  @doc """
  Deletes a course.

  ## Examples

      iex> delete_course(scope, course)
      {:ok, %Course{}}

      iex> delete_course(scope, course)
      {:error, %Ecto.Changeset{}}

  """
  def delete_course(%Scope{} = scope, %Course{} = course) do
    true = course.user_id == scope.user.id

    with {:ok, course = %Course{}} <-
           Repo.delete(course) do
      broadcast_course(scope, {:deleted, course})
      {:ok, course}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking course changes.

  ## Examples

      iex> change_course(scope, course)
      %Ecto.Changeset{data: %Course{}}

  """
  def change_course(%Scope{} = scope, %Course{} = course, attrs \\ %{}) do
    true = course.user_id == scope.user.id

    Course.changeset(course, attrs, scope)
  end
end
