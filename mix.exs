defmodule LiveTracingRoot.MixProject do
  use Mix.Project

  def project do
    [
      app: :live_tracing_root,
      version: "0.1.0",
      elixir: "~> 1.17",
      apps_path: "apps",
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      applications: [opentelemetry: :temporary],
      releases: [
        live_tracing: [
          version: "0.1.0",
          applications: [
            opentelemetry_exporter: :permanent,
            opentelemetry: :temporary,
            live_tracing: :permanent
          ]
        ]
      ],
      deps: deps()
    ]
  end

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.7.14"},
      {:phoenix_ecto, "~> 4.5"},
      {:ecto_sql, "~> 3.10"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 4.1"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      # TODO bump on release to {:phoenix_live_view, "~> 1.0.0"},
      {:phoenix_live_view, "~> 1.0.0-rc.1", override: true},
      {:floki, ">= 0.30.0", only: :test},
      {:phoenix_live_dashboard, "~> 0.8.3"},
      {:esbuild, "~> 0.8", runtime: Mix.env() == :dev},
      {:tailwind, "~> 0.2", runtime: Mix.env() == :dev},
      {:heroicons,
       github: "tailwindlabs/heroicons",
       tag: "v2.1.1",
       sparse: "optimized",
       app: false,
       compile: false,
       depth: 1},
      {:swoosh, "~> 1.5"},
      {:finch, "~> 0.13"},
      {:telemetry_metrics, "~> 1.0"},
      {:telemetry_poller, "~> 1.0"},
      {:gettext, "~> 0.20"},
      {:jason, "~> 1.2"},
      {:dns_cluster, "~> 0.1.1"},
      {:recon, "~> 2.5"},
      {:opentelemetry, "~> 1.5"},
      {:opentelemetry_bandit, "~> 0.2.0-rc.1"},
      {:opentelemetry_ecto, "~> 1.2"},
      {:opentelemetry_exporter, "~> 1.8"},
      {:opentelemetry_phoenix, "~> 2.0.0-rc.1"},
      {:opentelemetry_telemetry, "~> 1.0"},
      {:bandit, "~> 1.5"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "assets.setup", "assets.build"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.setup": ["tailwind.install --if-missing", "esbuild.install --if-missing"],
      "assets.build": ["tailwind live_tracing", "esbuild live_tracing"],
      "assets.deploy": [
        "tailwind live_tracing --minify",
        "esbuild live_tracing --minify",
        "phx.digest"
      ]
    ]
  end
end
