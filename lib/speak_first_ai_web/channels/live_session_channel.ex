defmodule SpeakFirstAiWeb.LiveSessionChannel do
  use Phoenix.Channel

  alias SpeakFirstAi.LiveSessions
  alias SpeakFirstAi.LiveSessions.{LiveSession, LiveSessionMessage}

  @impl true
  def join("live_session:" <> session_ref, payload, socket) do
    case String.trim(session_ref) do
      "" -> handle_new_session_join(payload, socket)
      "new" -> handle_new_session_join(payload, socket)
      ref -> handle_existing_session_join(ref, socket)
    end
  end

  def join("live_session", payload, socket) do
    handle_new_session_join(payload, socket)
  end

  def join(_topic, _payload, _socket) do
    {:error, %{reason: "invalid_topic"}}
  end

  defp handle_existing_session_join(ref, socket) do
    case Integer.parse(ref) do
      {id, ""} when id > 0 ->
        case establish_session_join(id, socket) do
          {:ok, updated_socket} -> {:ok, updated_socket}
          {:error, reason} -> {:error, reason}
        end

      _ ->
        {:error, %{reason: "invalid_session_id"}}
    end
  end

  defp handle_new_session_join(payload, socket) do
    user = socket.assigns.user

    case LiveSessions.ensure_active_session_for_user(user, payload) do
      {:ok, session} ->
        response = %{
          "topic" => "live_session:#{session.id}",
          "session" => format_session(session)
        }

        Process.send_after(self(), :close_handshake_channel, 0)
        {:ok, response, socket}

      {:error, {:invalid_lesson, changeset}} ->
        {:error, %{reason: format_errors(changeset)}}

      {:error, {:invalid_session, changeset}} ->
        {:error, %{reason: format_errors(changeset)}}

      {:error, {:invalid_integer, key}} ->
        {:error, %{reason: "invalid_#{key}"}}

      {:error, reason} ->
        {:error, %{reason: to_string(reason)}}
    end
  end

  defp establish_session_join(id, socket) do
    user = socket.assigns.user

    case LiveSessions.get_live_session_for_user!(id, user.id) do
      session ->
        {:ok, updated_session} = LiveSessions.check_and_end_if_duration_reached(session)

        Phoenix.PubSub.subscribe(SpeakFirstAi.PubSub, "live_session:#{id}")
        send(self(), {:after_join_session, id, updated_session})

        {:ok,
         socket
         |> assign(:session_id, id)
         |> assign(:pending_initial_session, updated_session)}
    end
  rescue
    Ecto.NoResultsError ->
      {:error, %{reason: "session_not_found"}}
  end

  @impl true
  def handle_in("start_session", %{"lesson_id" => lesson_id}, socket) do
    user = socket.assigns.user
    lesson_id = parse_integer(lesson_id)

    case LiveSessions.start_session(user.id, lesson_id) do
      {:ok, session} ->
        # Subscribe to this session's updates
        Phoenix.PubSub.subscribe(SpeakFirstAi.PubSub, "live_session:#{session.id}")

        # Broadcast session started
        broadcast_session_update(session, "session_started")

        {:reply, {:ok, format_session(session)}, assign(socket, :session_id, session.id)}

      {:error, changeset} ->
        {:reply, {:error, format_errors(changeset)}, socket}
    end
  end

  def handle_in("start_session", _payload, socket) do
    {:reply, {:error, %{reason: "lesson_id_required"}}, socket}
  end

  def handle_in("pause_session", _payload, socket) do
    case get_session(socket) do
      nil ->
        {:reply, {:error, %{reason: "no_active_session"}}, socket}

      session ->
        case LiveSessions.pause_session(session) do
          {:ok, updated_session} ->
            broadcast_session_update(updated_session, "session_paused")
            {:reply, {:ok, format_session(updated_session)}, socket}

          {:error, changeset} ->
            {:reply, {:error, format_errors(changeset)}, socket}
        end
    end
  end

  def handle_in("resume_session", _payload, socket) do
    case get_session(socket) do
      nil ->
        {:reply, {:error, %{reason: "no_active_session"}}, socket}

      session ->
        case LiveSessions.resume_session(session) do
          {:ok, updated_session} ->
            broadcast_session_update(updated_session, "session_resumed")
            {:reply, {:ok, format_session(updated_session)}, socket}

          {:error, changeset} ->
            {:reply, {:error, format_errors(changeset)}, socket}
        end
    end
  end

  def handle_in("end_session", _payload, socket) do
    case get_session(socket) do
      nil ->
        {:reply, {:error, %{reason: "no_active_session"}}, socket}

      session ->
        case LiveSessions.end_session(session) do
          {:ok, updated_session} ->
            broadcast_session_update(updated_session, "session_ended")
            {:reply, {:ok, format_session(updated_session)}, socket}

          {:error, changeset} ->
            {:reply, {:error, format_errors(changeset)}, socket}
        end
    end
  end

  def handle_in("send_message", %{"content" => content, "sender" => sender} = payload, socket)
      when is_binary(sender) do
    case get_session(socket) do
      nil ->
        {:reply, {:error, %{reason: "no_active_session"}}, socket}

      session ->
        # Verify sender is valid
        sender_atom = String.to_existing_atom(sender)

        if sender_atom not in [:ai, :user] do
          {:reply, {:error, %{reason: "invalid_sender"}}, socket}
        else
          attrs = %{
            "live_session_id" => session.id,
            "content" => content,
            "sender" => sender_atom,
            "recording_url" => payload["recording_url"]
          }

          case LiveSessions.create_message(attrs) do
            {:ok, message} ->
              # Create message asynchronously (no real-time broadcast)
              {:reply, {:ok, format_message(message)}, socket}

            {:error, changeset} ->
              {:reply, {:error, format_errors(changeset)}, socket}
          end
        end
    end
  rescue
    ArgumentError ->
      {:reply, {:error, %{reason: "invalid_sender"}}, socket}
  end

  def handle_in("get_session_state", _payload, socket) do
    case get_session(socket) do
      nil ->
        {:reply, {:error, %{reason: "no_active_session"}}, socket}

      session ->
        # Check and auto-end if duration reached
        {:ok, updated_session} = LiveSessions.check_and_end_if_duration_reached(session)
        {:reply, {:ok, format_session(updated_session)}, socket}
    end
  end

  def handle_in("get_messages", _payload, socket) do
    case get_session(socket) do
      nil ->
        {:reply, {:error, %{reason: "no_active_session"}}, socket}

      session ->
        messages = LiveSessions.list_messages(session.id)
        formatted_messages = Enum.map(messages, &format_message/1)
        {:reply, {:ok, %{messages: formatted_messages}}, socket}
    end
  end

  def handle_in("update_elapsed_time", _payload, socket) do
    case get_session(socket) do
      nil ->
        {:reply, {:error, %{reason: "no_active_session"}}, socket}

      session ->
        if session.status == :active do
          # Update elapsed time in DB
          updated = LiveSessions.update_elapsed_time(session)

          {:ok, saved} =
            LiveSessions.update_live_session(session, %{
              total_elapsed_seconds: updated.total_elapsed_seconds
            })

          # Check if duration reached and auto-end
          {:ok, final_session} = LiveSessions.check_and_end_if_duration_reached(saved)

          broadcast_session_update(final_session, "elapsed_time_updated")
          {:reply, {:ok, format_session(final_session)}, socket}
        else
          {:reply, {:ok, format_session(session)}, socket}
        end
    end
  end

  # Handle broadcasts from PubSub
  @impl true
  def handle_info(:close_handshake_channel, socket) do
    {:stop, :normal, socket}
  end

  def handle_info({:after_join_session, _id, session}, socket) do
    push(socket, "session_state", format_session(session))

    {:noreply, assign(socket, :pending_initial_session, nil)}
  end

  def handle_info({:session_updated, session}, socket) do
    push(socket, "session_update", format_session(session))
    {:noreply, socket}
  end

  # Helper functions

  defp get_session(socket) do
    case socket.assigns[:session_id] do
      nil -> nil
      session_id -> LiveSessions.get_live_session_for_user!(session_id, socket.assigns.user.id)
    end
  rescue
    Ecto.NoResultsError -> nil
  end

  defp broadcast_session_update(session, event_type) do
    Phoenix.PubSub.broadcast(
      SpeakFirstAi.PubSub,
      "live_session:#{session.id}",
      {:session_updated, session}
    )

    # Also push directly with event type
    SpeakFirstAiWeb.Endpoint.broadcast(
      "live_session:#{session.id}",
      event_type,
      format_session(session)
    )
  end

  defp format_session(%LiveSession{} = session) do
    %{
      id: session.id,
      user_id: session.user_id,
      lesson_id: session.lesson_id,
      started_at: session.started_at,
      ended_at: session.ended_at,
      paused_at: session.paused_at,
      duration_minutes: session.duration_minutes,
      total_elapsed_seconds: session.total_elapsed_seconds || 0,
      target_duration_minutes: session.target_duration_minutes,
      status: to_string(session.status),
      notes: session.notes,
      inserted_at: session.inserted_at,
      updated_at: session.updated_at
    }
  end

  defp format_message(%LiveSessionMessage{} = message) do
    %{
      id: message.id,
      live_session_id: message.live_session_id,
      sender: to_string(message.sender),
      content: message.content,
      recording_url: message.recording_url,
      inserted_at: message.inserted_at,
      updated_at: message.updated_at
    }
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end

  defp parse_integer(value) when is_binary(value) do
    case Integer.parse(value) do
      {int, ""} -> int
      _ -> raise ArgumentError, "invalid integer: #{value}"
    end
  end

  defp parse_integer(value) when is_integer(value), do: value
end
