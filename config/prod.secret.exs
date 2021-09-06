# In this file, we load production configuration and secrets
# from environment variables. You can also hardcode secrets,
# although such is generally not recommended and you have to
# remember to add this file to your .gitignore.
use Mix.Config

database_url =
  System.get_env("DATABASE_URL") ||
    System.get_env("COMPILE_PHASE") ||
    raise """
    environment variable DATABASE_URL is missing.
    For example: ecto://USER@HOST/DATABASE
    """

database_pass =
  System.get_env("DATABASE_PASS") ||
    System.get_env("COMPILE_PHASE")

config :uro, Uro.Repo,
  ssl: true,
  url: database_url,
  password: database_pass,
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")

secret_key_base =
  System.get_env("SECRET_KEY_BASE") ||
    System.get_env("COMPILE_PHASE") ||
    raise """
    environment variable SECRET_KEY_BASE is missing.
    You can generate one by calling: mix phx.gen.secret
    """

config :uro, UroWeb.Endpoint,
  server: true,
  http: [
    port: String.to_integer(System.get_env("PORT") || "4000"),
    transport_options: [socket_opts: [:inet6]]
  ],
  secret_key_base: secret_key_base
