defmodule PlugCheckup.Mixfile do
  use Mix.Project

  def project do
    [
      app: :plug_checkup,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      name: "PlugCheckup",
      source_url: "https://github.com/ggpasqualino/plug_checkup"
    ]
  end

  def application do
    []
  end

  def description do
    "PlugCheckup provides a Plug for adding simple health checks to your app."
  end

  def package do
    [
      files: ["lib", "mix.exs", "README.md"],
      maintainers: ["Guilherme Pasqualino"],
      licenses: [],
      links: %{"GitHub" => "https://github.com/ggpasqualino/plug_checkup"}
    ]
  end

  defp deps do
    [
      {:plug, "~> 1.4"},
      {:poison, "~> 3.1"},
      {:credo, ">= 0.0.0", only: :dev},
      {:ex_doc, ">= 0.0.0", only: :dev},
      {:cowboy, "~> 1.0", only: :dev},
    ]
  end
end
