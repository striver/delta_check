defmodule DeltaCheck.MixProject do
  use Mix.Project

  def project do
    [
      app: :delta_check,
      deps: deps(),
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      version: "0.1.0"
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:benchee, "~> 1.1", only: :test},
      {:credo, "~> 1.6", only: :test, runtime: false},
      {:ecto_sql, "~> 3.9", only: :test},
      {:jason, "~> 1.4", only: :test},
      {:postgrex, "~> 0.16", only: :test},
      {:stream_data, "~> 0.5", only: :test}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end
