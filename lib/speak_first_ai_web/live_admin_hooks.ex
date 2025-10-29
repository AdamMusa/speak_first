defmodule SpeakFirstAiWeb.LiveAdminHooks do
  @moduledoc """
  LiveView hooks for admin panel functionality.
  """
  def on_mount(:assign_current_path, _params, _session, socket) do
    path = get_path_from_socket(socket)
    {:cont, Phoenix.Component.assign(socket, :current_path, path)}
  end

  @doc """
  Callback to be used in handle_params to update current_path on navigation
  """
  def update_current_path(%{uri: uri} = socket) do
    Phoenix.Component.assign(socket, :current_path, uri.path)
  end

  def update_current_path(socket) do
    path = get_path_from_socket(socket)
    Phoenix.Component.assign(socket, :current_path, path)
  end

  defp get_path_from_socket(socket) do
    cond do
      # Use uri from socket (most reliable)
      Map.has_key?(socket, :uri) && socket.uri.path ->
        socket.uri.path
      # Use assigns uri if available
      socket.assigns[:uri] && socket.assigns.uri.path ->
        socket.assigns.uri.path
      # Fallback to host_uri parsing
      socket.assigns[:host_uri] ->
        uri = URI.parse(socket.assigns.host_uri)
        uri.path || "/"
      # Final fallback
      true ->
        "/"
    end
  end
end
