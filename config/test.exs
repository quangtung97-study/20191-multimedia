use Mix.Config

config :multimedia, Multimedia.Repo,
  username: "postgres",
  password: "quangtung97",
  database: "multimedia_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :multimedia, MultimediaWeb.Endpoint,
  http: [port: 4002],
  server: false

config :logger, level: :warn
