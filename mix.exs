defmodule PlugCheckup.Mixfile do
  use Mix.Project

  @source_url "https://github.com/ggpasqualino/plug_checkup"
  @version "0.6.0"

  def project do
    [
      app: :plug_checkup,
      version: @version,
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      package: package(),
      deps: deps(),
      docs: docs(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      name: "PlugCheckup",
    ]
  end

  def application do
    []
  end

  defp elixirc_paths(:test), do: elixirc_paths() ++ ["test/support"]
  defp elixirc_paths(_), do: elixirc_paths()
  defp elixirc_paths(), do: ["lib"]

  def package do
    [
      description: "PlugCheckup provides a Plug for adding simple health checks to your app.",
      files: ["lib", "priv", "mix.exs", "README.md", "LICENSE"],
      maintainers: ["Guilherme Pasqualino"],
      licenses: ["MIT"],
      links: %{"GitHub" => @source_url}
    ]
  end

  defp deps do
    [
      {:plug, "~> 1.4"},
      {:jason, "~> 1.1", only: [:dev, :test]},
      {:excoveralls, "~> 0.12", only: [:dev, :test]},
      {:credo, ">= 0.0.0", only: [:dev, :test]},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:plug_cowboy, "~> 2.1", only: :dev},
      {:ex_json_schema, "~> 0.7", only: :test}
    ]
  end

  defp docs do
    [
      extras: [
        "LICENSE.md": [title: "License"],
        "README.md": [title: "Overview"]
      ],
      main: "readme",
      source_url: @source_url,
      source_ref: "v#{@version}",
      formatters: ["html"]
    ]
  end
end
