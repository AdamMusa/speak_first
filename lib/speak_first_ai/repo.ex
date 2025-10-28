defmodule SpeakFirstAi.Repo do
  use Ecto.Repo,
    otp_app: :speak_first_ai,
    adapter: Ecto.Adapters.Postgres
end
