defmodule RetroTaxi.Repo do
  use Ecto.Repo,
    otp_app: :retro_taxi,
    adapter: Ecto.Adapters.Postgres
end
