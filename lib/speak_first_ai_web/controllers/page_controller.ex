defmodule SpeakFirstAiWeb.PageController do
  use SpeakFirstAiWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
