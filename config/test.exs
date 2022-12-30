import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :docker_phoenix_tailwind, DockerPhoenixTailwindWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "SzR8Yh/1K9Xes8aVa25LuF6vo55SHjxEwoVFoxZgetVUPIadH5UTijvFEwDcL3Ng",
  server: false

# In test we don't send emails.
config :docker_phoenix_tailwind, DockerPhoenixTailwind.Mailer,
  adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
