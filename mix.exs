defmodule PlugCheckup.Mixfile do
  use Mix.Project

  def project do
    [
      app: :plug_checkup,
      version: "0.5.0",
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      name: "PlugCheckup",
      source_url: "https://github.com/ggpasqualino/plug_checkup"
    ]
  end

  def application do
    []
  end

  defp elixirc_paths(:test), do: elixirc_paths() ++ ["test/support"]
  defp elixirc_paths(_), do: elixirc_paths()
  defp elixirc_paths(), do: ["lib"]

  def description do
    "PlugCheckup provides a Plug for adding simple health checks to your app."
  end

  def package do
    [
      files: ["lib", "priv", "mix.exs", "README.md", "LICENSE"],
      maintainers: ["Guilherme Pasqualino"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/ggpasqualino/plug_checkup"}
    ]
  end

  defp deps do
    [
      {:plug, "~> 1.4"},
      {:jason, "~> 1.1", only: [:dev, :test]},
      {:excoveralls, "~> 0.12", only: [:dev, :test]},
      {:credo, ">= 0.0.0", only: [:dev, :test]},
      {:ex_doc, ">= 0.0.0", only: :dev},
      {:plug_cowboy, "~> 2.1", only: :dev},
      {:ex_json_schema, "~> 0.7", only: :test}
    ]
  end
end
