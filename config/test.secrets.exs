use Mix.Config
# configure your database
config :papelito, Papelito.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "papelito",
  password: "papelito",
  database: "papelito_dev",
  hostname: "localhost",
  pool_size: 10
