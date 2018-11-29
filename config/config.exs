# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :papelito,
  ecto_repos: [Papelito.Repo]

# Configures the endpoint
config :papelito, PapelitoWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "nYkAQ4maUZFRcnGdZRgaTWay5qZj5nIi3Dq73sDzLmznxUWCT1U0kg3asog+yvFg",
  render_errors: [view: PapelitoWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Papelito.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :phoenix, :template_engines, drab: Drab.Live.Engine

config :drab, PapelitoWeb.Endpoint,
  otp_app: :papelito,
  js_socket_constructor: "window.__socket"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config("#{Mix.env()}.exs")
import_config "team_names.exs"
