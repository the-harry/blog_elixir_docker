mix deps.update --all

mix ecto.drop
mix ecto.setup

exec mix phx.server
