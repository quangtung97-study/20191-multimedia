use Mix.Config

config :multimedia,
  ecto_repos: [Multimedia.Repo]

config :multimedia, MultimediaWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "VylV2VJhytHRhJuCMuOGJU/pIUddHn6g1sMFutwxCPVtwbbKrzeLCPsjBUvdV4dv",
  render_errors: [view: MultimediaWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Multimedia.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [
    signing_salt: "Y19Aqm5Em557c397zGdGSO/cUY0sz9SC"
  ]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

import_config "#{Mix.env()}.exs"
