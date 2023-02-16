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
      docs: [
        extras: [
          "GUIDE.md",
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
        maintainers: ["Andreas Geffen Lundahl"],
        licenses: ["MIT"],
        links: %{
          "GitHub" => "https://github.com/striver/delta_check",
          "Striver" => "https://striver.se"
        }
      ],
      source_url: "https://github.com/striver/delta_check",
      start_permanent: Mix.env() == :prod,
      version: "0.1.0"
    ]
  end

  defp deps do
    [
      {:benchee, "~> 1.1", only: :test},
      {:credo, "~> 1.6", only: :dev, runtime: false},
      {:dialyxir, "~> 1.2", only: :dev, runtime: false},
      {:ex_doc, "~> 0.29", only: :dev, runtime: false},
      {:ecto_sql, "~> 3.9", only: [:dev, :test]},
      {:jason, "~> 1.4", only: [:dev, :test]},
      {:postgrex, "~> 0.16", only: [:dev, :test]},
      {:stream_data, "~> 0.5", only: [:dev, :test]}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end
