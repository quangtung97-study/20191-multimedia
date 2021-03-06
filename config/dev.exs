use Mix.Config

config :multimedia, Multimedia.Repo,
  username: "postgres",
  password: "quangtung97",
  database: "multimedia_dev",
  hostname: "localhost",
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

config :multimedia, MultimediaWeb.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: [
    node: [
      "node_modules/webpack/bin/webpack.js",
      "--mode",
      "development",
      "--watch-stdin",
      cd: Path.expand("../assets", __DIR__)
    ]
  ],
  force_ssl: [hsts: true],
  https: [
    :inet6,
    port: 5000,
    cipher_suite: :strong,
    keyfile: Path.expand("../ssl/key.pem", __DIR__),
    certfile: Path.expand("../ssl/certificate.pem", __DIR__)
  ]

config :multimedia, MultimediaWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/multimedia_web/{live,views}/.*(ex)$",
      ~r"lib/multimedia_web/templates/.*(eex)$"
    ]
  ]

config :logger, :console, format: "[$level] $message\n"

config :phoenix, :stacktrace_depth, 20

config :phoenix, :plug_init_mode, :runtime
