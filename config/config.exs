# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :money,
  ecto_repos: [Money.Repo]

# Configures the endpoint
config :money, Money.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "2OdyMYQ/4RkY7b2UeLcLXVEgWCfVH9nV4K2a2BOHMGX5RGkUiX+kAN7jvjuHEfEc",
  render_errors: [view: Money.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Money.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
