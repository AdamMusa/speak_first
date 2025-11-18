defmodule SpeakFirstAiWeb.UserSocket do
  use Phoenix.Socket
  require Logger

  ## Channels
  channel "live_session:*", SpeakFirstAiWeb.LiveSessionChannel

  @impl true
  def connect(%{"token" => token}, socket, _connect_info) do
    case verify_access_token(token) do
      {:ok, user} ->
        {:ok, assign(socket, :user, user)}

      {:error, reason} ->
        Logger.debug("SpeakFirstAiWeb.UserSocket connect/3 rejected token: #{inspect(reason)}")
        :error
    end
  end

  def connect(params, _socket, _connect_info) do
    Logger.debug("SpeakFirstAiWeb.UserSocket connect/3 missing or invalid params: #{inspect(params)}")
    :error
  end

  @impl true
  def id(socket), do: "user_socket:#{socket.assigns.user.id}"

  defp verify_access_token(encoded_token) do
    case Base.url_decode64(encoded_token, padding: false) do
      {:ok, token} ->
        case SpeakFirstAi.Accounts.get_user_by_access_token(token) do
          {user, _token_inserted_at} -> {:ok, user}
          nil ->
            Logger.debug("SpeakFirstAiWeb.UserSocket verify_access_token/1 rejected: :invalid_token")
            {:error, :invalid_token}
        end

      :error ->
        Logger.debug("SpeakFirstAiWeb.UserSocket verify_access_token/1 rejected: :invalid_encoding")
        {:error, :invalid_encoding}
    end
  end
end
