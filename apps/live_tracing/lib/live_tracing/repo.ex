defmodule LiveTracing.Repo do
  use Ecto.Repo,
    otp_app: :live_tracing,
    adapter: Ecto.Adapters.Postgres
end
