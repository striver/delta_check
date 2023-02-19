import Config

config :delta_check, DeltaCheck.TestRepo,
  database: System.get_env("PGDATABASE"),
  hostname: System.get_env("PGHOST"),
  password: System.get_env("PGPASSWORD"),
  pool: Ecto.Adapters.SQL.Sandbox,
  username: System.get_env("PGUSER")

config :delta_check, :repo, DeltaCheck.TestRepo

config :logger, level: :warn
