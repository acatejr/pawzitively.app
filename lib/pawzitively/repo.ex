defmodule Pawzitively.Repo do
  use Ecto.Repo,
    otp_app: :pawzitively,
    adapter: Ecto.Adapters.Postgres
end
