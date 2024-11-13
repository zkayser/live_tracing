defmodule Analytics.MixProject do
  use Mix.Project

  def project do
    [
      app: :analytics,
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      version: "0.1.0",
      elixir: "~> 1.17",
      applications: [opentelemetry: :temporary],
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Analytics.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:otp_trace_tools, in_umbrella: true},
      {:opentelemetry, "~> 1.5"},
      {:opentelemetry_exporter, "~> 1.8"}
    ]
  end
end
