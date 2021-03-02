# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :retro_taxi,
  ecto_repos: [RetroTaxi.Repo]

# Configures the endpoint
config :retro_taxi, RetroTaxiWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "lJR6iKkkFdov7bxgL0xt/Y4ktme9cwVI5/1YgLb5eC1EZtHBMygzZk+UxQe0m4Rr",
  render_errors: [view: RetroTaxiWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: RetroTaxi.PubSub,
  live_view: [signing_salt: "VkgJkeK3"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
