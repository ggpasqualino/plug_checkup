[![Build Status](https://github.com/ggpasqualino/plug_checkup/workflows/Elixir%20CI/badge.svg?branch=master)](https://github.com/ggpasqualino/plug_checkup/actions?query=branch%3Amaster)
[![Coverage Status](https://coveralls.io/repos/github/ggpasqualino/plug_checkup/badge.svg?branch=master)](https://coveralls.io/github/ggpasqualino/plug_checkup?branch=master)
||
[![Hex version](https://img.shields.io/hexpm/v/plug_checkup.svg)](https://hex.pm/packages/plug_checkup)
[![Hex downloads](https://img.shields.io/hexpm/dt/plug_checkup.svg)](https://hex.pm/packages/plug_checkup)

# PlugCheckup

PlugCheckup provides a Plug for adding simple health checks to your app. The [JSON output](#response) is similar to the one provided by the [MiniCheck](https://github.com/workshare/mini-check) Ruby library. It was started to provide [solarisBank](https://www.solarisbank.de/en/) an easy way of monitoring Plug based applications.

## Usage

- Add the package to "mix.exs"
```elixir
defp deps do
  [
    {:plug_checkup, "~> 0.3.0"}
  ]
end
```

- Create your [checks](#the-checks)
```elixir
defmodule MyHealthChecks do
  def check_db do
    :ok
  end

  def check_redis do
    :ok
  end
end
```

- Forward your health path to PlugCheckup in your Plug Router
```elixir
checks = [
  %PlugCheckup.Check{name: "DB", module: MyHealthChecks, function: :check_db},
  %PlugCheckup.Check{name: "Redis", module: MyHealthChecks, function: :check_redis}
]

forward(
  "/health",
  to: PlugCheckup,
  init_opts: PlugCheckup.Options.new(json_encoder: Jason, checks: checks)
)
```

If you're working with Phoenix, you need to change the syntax slightly to
accomodate `Phoenix.Router.forward/4`:

```elixir
checks = [
  %PlugCheckup.Check{name: "DB", module: MyHealthChecks, function: :check_db},
  %PlugCheckup.Check{name: "Redis", module: MyHealthChecks, function: :check_redis}
]

forward("/health", PlugCheckup, PlugCheckup.Options.new(json_encoder: Jason, checks: checks))
```

## The Checks
A check is a function with arity zero, which should return either :ok or {:error, term}. In case the check raises an exception or times out, that will be mapped to an {:error, reason} result.

## Response

PlugCheckup should return either 200 or 500 statuses, Content-Type header "application/json", and the body should respect [this](priv/schemas/health_check_response.json) JSON schema

If you configure the `error_code` option when initializing the plug, the specified value will be used when an error occurs instead of the 500 status.

## Demo

Check [.iex.exs](.iex.exs) for a demo of plug_checkup in a Plug.Router. The demo can be run as following.
```sh
git clone https://github.com/ggpasqualino/plug_checkup
cd plug_checkup
mix deps.get
iex -S mix
```
Open your browse either on http://localhost:4000/selfhealth or http://localhost:4000/dependencyhealth
