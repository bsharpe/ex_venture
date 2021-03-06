use Mix.Config

config :ex_venture, Data.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "ex_venture",
  hostname: "localhost",
  pool_size: 10

config :ex_venture, Web.Endpoint,
  http: [port: 4000],
  url: [host: {:system, "HOST"}, port: 4000],
  server: true,
  cache_static_manifest: "priv/static/cache_manifest.json"

config :ex_venture, :networking,
  host: {:system, "HOST"},
  port: 5555,
  ssl_port: {:system, "SSL_PORT"},
  server: true,
  socket_module: Networking.Protocol

config :ex_venture, :game,
  npc: Game.NPC,
  room: Game.Room,
  shop: Game.Shop,
  zone: Game.Zone,
  continue_wait: 500

config :logger, level: :info

config :logger,
  backends: [
    {LoggerFileBackend, :global},
    {LoggerFileBackend, :phoenix},
    {LoggerFileBackend, :commands}
  ]

config :logger, :global, path: "/var/log/ex_venture/global.log"

config :logger, :phoenix,
  path: "/var/log/ex_venture/phoenix.log",
  level: :info,
  metadata_filter: [type: :phoenix]

config :logger, :commands,
  path: "/var/log/ex_venture/commands.log",
  level: :info,
  metadata_filter: [type: :command]
