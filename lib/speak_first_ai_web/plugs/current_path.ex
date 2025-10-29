defmodule SpeakFirstAiWeb.Plugs.CurrentPath do
  @moduledoc """
  Assigns the current request path for use in root layouts and components.
  """
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    assign(conn, :current_path, conn.request_path)
  end
end
