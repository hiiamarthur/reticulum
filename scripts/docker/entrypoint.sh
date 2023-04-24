#!/bin/bash

DB_USER=${DATABASE_USER:-postgres}

while ! pg_isready -h db -p 5432 -U postgres
do
#   pg_isready --help
  rm -rf /var/lib/postgresql/data/pg_stat_tmp/global.stat
  echo "$(date) - waiting for database to start"
  sleep 2
done

# bin="/app/bin/ret"
#eval "$bin eval \"Ret.Release.migrate\""   
bash -ic "source ~/kerl/24.3/activate; mix local.hex --force; mix local.rebar --force; mix deps.update --all mix deps.get;mix deps.clean mime --build;rm -rf _build && mix compile; mix ecto.create;"
bash -ic "source ~/kerl/24.3/activate; mix local.hex --force; mix local.rebar --force; mix deps.update --all mix deps.get;mix ecto.drop; mix ecto.create;"
bash -ic "source ~/kerl/24.3/activate && iex -S mix phx.server"
# start the elixir application
# exec "$bin" "start"