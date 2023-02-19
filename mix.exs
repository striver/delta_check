defmodule DeltaCheck.MixProject do
  use Mix.Project

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  def project do
    [
      app: :delta_check,
      deps: deps(),
      description: "A testing toolkit for making assertions on database writes.",
      dialyzer: [
        plt_add_apps: [:ex_unit],
        plt_file: {:no_warn, "priv/plts/dialyzer.plt"}
      ],
      docs: [
        extras: [
          "LICENSE",
          "README.md"
        ],
        main: "readme"
      ],
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      homepage_url: "https://github.com/striver/delta_check",
      name: "DeltaCheck",
      package: [
        licenses: ["MIT"],
        links: %{
          "GitHub" => "https://github.com/striver/delta_check",
          "Striver" => "https://striver.se"
        },
        maintainers: ["Andreas Geffen Lundahl"]
      ],
      source_url: "https://github.com/striver/delta_check",
      start_permanent: Mix.env() == :prod,
      version: "0.1.0"
    ]
  end

  defp deps do
    [
      {:benchee, "~> 1.1", only: :test},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.2", only: [:dev, :test], runtime: false},
      {:ecto_sql, "~> 3.9", only: [:dev, :test]},
      {:ex_doc, "~> 0.29", only: :dev, runtime: false},
      {:jason, "~> 1.4", only: [:dev, :test]},
      {:postgrex, "~> 0.16", only: [:dev, :test]},
      {:stream_data, "~> 0.5", only: [:dev, :test]}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end
