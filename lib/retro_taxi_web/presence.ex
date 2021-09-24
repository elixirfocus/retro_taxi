defmodule RetroTaxiWeb.Presence do
  use Phoenix.Presence,
    otp_app: :retro_taxi,
    pubsub_server: RetroTaxi.PubSub
end
