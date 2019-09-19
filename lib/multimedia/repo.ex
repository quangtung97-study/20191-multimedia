defmodule Multimedia.Repo do
  use Ecto.Repo,
    otp_app: :multimedia,
    adapter: Ecto.Adapters.Postgres
end
