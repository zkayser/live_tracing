defmodule LiveTracing.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    OpentelemetryBandit.setup()
    OpentelemetryPhoenix.setup(adapter: :bandit)
    OpentelemetryEcto.setup([:live_tracing, :repo], db_statement: :enabled)

    children = [
      LiveTracingWeb.Telemetry,
      LiveTracing.Repo,
      {DNSCluster, query: Application.get_env(:live_tracing, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: LiveTracing.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: LiveTracing.Finch},
      # Start a worker by calling: LiveTracing.Worker.start_link(arg)
      # {LiveTracing.Worker, arg},
      # Start to serve requests, typically the last entry
      LiveTracingWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: LiveTracing.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    LiveTracingWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
