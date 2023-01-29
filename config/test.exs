import Config

config :delta_check, DeltaCheck.TestRepo,
  database: System.fetch_env!("PGDATABASE#{System.get_env("MIX_TEST_PARTITION")}"),
  hostname: System.fetch_env!("PGHOST"),
  password: System.fetch_env!("PGPASSWORD"),
  pool: Ecto.Adapters.SQL.Sandbox,
  username: System.fetch_env!("PGUSER")

config :delta_check, :repo, DeltaCheck.TestRepo

config :logger, level: :warn
