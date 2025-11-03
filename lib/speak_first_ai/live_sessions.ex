defmodule SpeakFirstAi.LiveSessions do
  @moduledoc """
  The LiveSessions context.
  """

  import Ecto.Query, warn: false
  alias SpeakFirstAi.Repo

  alias SpeakFirstAi.LiveSessions.LiveSession
  alias SpeakFirstAi.LiveSessions.LiveSessionMessage

  @doc """
  Returns the list of live_sessions for a user.

  ## Examples

      iex> list_live_sessions(user_id)
      [%LiveSession{}, ...]

  """
  def list_live_sessions(user_id) when is_integer(user_id) do
    from(ls in LiveSession, where: ls.user_id == ^user_id, order_by: [desc: ls.inserted_at])
    |> Repo.all()
  end

  @doc """
  Gets a single live_session.

  Raises `Ecto.NoResultsError` if the Live session does not exist.

  ## Examples

      iex> get_live_session!(123)
      %LiveSession{}

      iex> get_live_session!(456)
      ** (Ecto.NoResultsError)

  """
  def get_live_session!(id), do: Repo.get!(LiveSession, id)

  @doc """
  Gets a single live_session for a specific user.

  Raises `Ecto.NoResultsError` if the Live session does not exist or doesn't belong to the user.

  ## Examples

      iex> get_live_session_for_user!(123, user_id)
      %LiveSession{}

      iex> get_live_session_for_user!(456, user_id)
      ** (Ecto.NoResultsError)

  """
  def get_live_session_for_user!(id, user_id) do
    Repo.get_by!(LiveSession, id: id, user_id: user_id)
  end

  @doc """
  Gets an active live_session for a user and lesson, if one exists.

  ## Examples

      iex> get_active_session(user_id, lesson_id)
      %LiveSession{} | nil

  """
  def get_active_session(user_id, lesson_id) do
    from(ls in LiveSession,
      where: ls.user_id == ^user_id and ls.lesson_id == ^lesson_id and ls.status == :active,
      order_by: [desc: ls.inserted_at],
      limit: 1
    )
    |> Repo.one()
    |> case do
      nil -> nil
      session -> update_elapsed_time(session) |> check_and_end_if_duration_reached() |> elem(1)
    end
  end

  @doc """
  Creates a live_session.

  ## Examples

      iex> create_live_session(%{field: value})
      {:ok, %LiveSession{}}

      iex> create_live_session(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_live_session(attrs \\ %{}) do
    %LiveSession{}
    |> LiveSession.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a live_session.

  ## Examples

      iex> update_live_session(live_session, %{field: new_value})
      {:ok, %LiveSession{}}

      iex> update_live_session(live_session, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_live_session(%LiveSession{} = live_session, attrs) do
    live_session
    |> LiveSession.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a live_session.

  ## Examples

      iex> delete_live_session(live_session)
      {:ok, %LiveSession{}}

      iex> delete_live_session(live_session)
      {:error, %Ecto.Changeset{}}

  """
  def delete_live_session(%LiveSession{} = live_session) do
    Repo.delete(live_session)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking live_session changes.

  ## Examples

      iex> change_live_session(live_session)
      %Ecto.Changeset{data: %LiveSession{}}

  """
  def change_live_session(%LiveSession{} = live_session, attrs \\ %{}) do
    LiveSession.changeset(live_session, attrs)
  end

  @doc """
  Starts a new live session for a user and lesson.
  If a paused session exists for this user/lesson, it will resume that session instead.

  ## Examples

      iex> start_session(user_id, lesson_id)
      {:ok, %LiveSession{}}

  """
  def start_session(user_id, lesson_id) do
    # Check if there's a paused session to resume
    case get_paused_session(user_id, lesson_id) do
      nil ->
        # No paused session, create a new one
        # Get lesson directly from repo (bypass scope requirement)
        lesson = Repo.get!(SpeakFirstAi.Lessons.Lesson, lesson_id)

        create_live_session(%{
          user_id: user_id,
          lesson_id: lesson_id,
          started_at: DateTime.utc_now(),
          status: :active,
          total_elapsed_seconds: 0,
          target_duration_minutes: lesson.estimated_minutes
        })

      paused_session ->
        # Resume the paused session
        resume_session(paused_session)
    end
  end

  @doc """
  Gets a paused session for a user and lesson, if one exists.

  ## Examples

      iex> get_paused_session(user_id, lesson_id)
      %LiveSession{} | nil

  """
  def get_paused_session(user_id, lesson_id) do
    from(ls in LiveSession,
      where: ls.user_id == ^user_id and ls.lesson_id == ^lesson_id and ls.status == :paused,
      order_by: [desc: ls.inserted_at],
      limit: 1
    )
    |> Repo.one()
  end

  @doc """
  Ends a live session.
  If the session is paused, it will mark it as completed.
  If the session is active and duration has been reached, it marks as completed.
  Otherwise, it pauses the session if duration hasn't been reached.

  ## Examples

      iex> end_session(live_session)
      {:ok, %LiveSession{}}

  """
  def end_session(%LiveSession{} = live_session) do
    # First, update and save elapsed time if active
    live_session =
      if live_session.status == :active do
        updated = update_elapsed_time(live_session)
        # Save elapsed time to DB
        {:ok, saved} = update_live_session(live_session, %{
          total_elapsed_seconds: updated.total_elapsed_seconds
        })
        saved
      else
        live_session
      end

    case live_session.status do
      :paused ->
        # Already paused, just mark as completed
        update_live_session(live_session, %{
          ended_at: DateTime.utc_now(),
          status: :completed
        })

      :active ->
        # Check if duration has been reached
        if duration_reached?(live_session) do
          # Duration reached, mark as completed
          update_live_session(live_session, %{
            ended_at: DateTime.utc_now(),
            status: :completed
          })
        else
          # Duration not reached, pause the session
          pause_session(live_session)
        end

      _ ->
        # Already ended or cancelled, return as is
        {:ok, live_session}
    end
  end

  @doc """
  Pauses a live session and updates elapsed time.

  ## Examples

      iex> pause_session(live_session)
      {:ok, %LiveSession{}}

  """
  def pause_session(%LiveSession{} = live_session) do
    # Update elapsed time before pausing
    live_session = update_elapsed_time(live_session)
    elapsed_seconds = live_session.total_elapsed_seconds || 0

    update_live_session(live_session, %{
      paused_at: DateTime.utc_now(),
      status: :paused,
      total_elapsed_seconds: elapsed_seconds
    })
  end

  @doc """
  Resumes a paused live session.
  Continues from where it left off until target duration is reached.

  ## Examples

      iex> resume_session(live_session)
      {:ok, %LiveSession{}}

  """
  def resume_session(%LiveSession{} = live_session) do
    # Clear paused_at and set status to active
    # The elapsed time was already stored when paused
    # We'll update started_at to now so elapsed time calculation continues from zero
    # But we keep total_elapsed_seconds to track cumulative time

    # Update started_at to account for the elapsed time
    # When resumed, we want to continue tracking until target duration
    # So we adjust started_at backwards by elapsed time
    elapsed_seconds = live_session.total_elapsed_seconds || 0
    new_started_at = DateTime.add(DateTime.utc_now(), -elapsed_seconds, :second)

    update_live_session(live_session, %{
      paused_at: nil,
      status: :active,
      started_at: new_started_at
    })
  end

  @doc """
  Updates the elapsed time for an active session.
  This should be called periodically to track time.
  Returns the updated live_session struct (not from DB).

  ## Examples

      iex> update_elapsed_time(live_session)
      %LiveSession{}

  """
  def update_elapsed_time(%LiveSession{} = live_session) do
    case live_session.status do
      :active ->
        # Calculate elapsed time from started_at
        # When resumed, started_at is adjusted backwards by elapsed time,
        # so now - started_at gives us the total elapsed time
        now = DateTime.utc_now()
        elapsed_seconds = DateTime.diff(now, live_session.started_at, :second)

        # Update the struct (but don't save to DB - this is just for calculation)
        %{live_session | total_elapsed_seconds: elapsed_seconds}

      :paused ->
        # When paused, elapsed time is already stored in total_elapsed_seconds
        live_session

      _ ->
        live_session
    end
  end

  @doc """
  Checks if the session duration has been reached.
  Automatically ends the session if duration is reached.

  ## Examples

      iex> check_and_end_if_duration_reached(live_session)
      {:ok, %LiveSession{}}

  """
  def check_and_end_if_duration_reached(%LiveSession{} = live_session) do
    live_session = update_elapsed_time(live_session)

    if duration_reached?(live_session) && live_session.status == :active do
      update_live_session(live_session, %{
        ended_at: DateTime.utc_now(),
        status: :completed
      })
    else
      {:ok, live_session}
    end
  end

  @doc """
  Checks if the target duration has been reached.

  ## Examples

      iex> duration_reached?(live_session)
      true

  """
  def duration_reached?(%LiveSession{} = live_session) do
    case {live_session.target_duration_minutes, live_session.total_elapsed_seconds} do
      {nil, _} -> false
      {target_minutes, elapsed_seconds} when is_integer(target_minutes) and target_minutes > 0 ->
        elapsed_minutes = div(elapsed_seconds, 60)
        elapsed_minutes >= target_minutes
      _ -> false
    end
  end

  @doc """
  Cancels a live session.

  ## Examples

      iex> cancel_session(live_session)
      {:ok, %LiveSession{}}

  """
  def cancel_session(%LiveSession{} = live_session) do
    update_live_session(live_session, %{
      ended_at: DateTime.utc_now(),
      status: :cancelled
    })
  end

  @doc """
  Returns the list of messages for a live_session.

  ## Examples

      iex> list_messages(live_session_id)
      [%LiveSessionMessage{}, ...]

  """
  def list_messages(live_session_id) do
    from(m in LiveSessionMessage,
      where: m.live_session_id == ^live_session_id,
      order_by: [asc: m.inserted_at]
    )
    |> Repo.all()
  end

  @doc """
  Gets a single message.

  Raises `Ecto.NoResultsError` if the Message does not exist.

  ## Examples

      iex> get_message!(123)
      %LiveSessionMessage{}

      iex> get_message!(456)
      ** (Ecto.NoResultsError)

  """
  def get_message!(id), do: Repo.get!(LiveSessionMessage, id)

  @doc """
  Creates a message.

  ## Examples

      iex> create_message(%{field: value})
      {:ok, %LiveSessionMessage{}}

      iex> create_message(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_message(attrs \\ %{}) do
    %LiveSessionMessage{}
    |> LiveSessionMessage.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a message.

  ## Examples

      iex> update_message(message, %{field: new_value})
      {:ok, %LiveSessionMessage{}}

      iex> update_message(message, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_message(%LiveSessionMessage{} = message, attrs) do
    message
    |> LiveSessionMessage.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a message.

  ## Examples

      iex> delete_message(message)
      {:ok, %LiveSessionMessage{}}

      iex> delete_message(message)
      {:error, %Ecto.Changeset{}}

  """
  def delete_message(%LiveSessionMessage{} = message) do
    Repo.delete(message)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking message changes.

  ## Examples

      iex> change_message(message)
      %Ecto.Changeset{data: %LiveSessionMessage{}}

  """
  def change_message(%LiveSessionMessage{} = message, attrs \\ %{}) do
    LiveSessionMessage.changeset(message, attrs)
  end
end
