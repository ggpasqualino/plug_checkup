[![Build Status](https://travis-ci.org/ggpasqualino/plug_checkup.svg?branch=master)](https://travis-ci.org/ggpasqualino/plug_checkup)[![Coverage Status](https://coveralls.io/repos/github/ggpasqualino/plug_checkup/badge.svg?branch=master)](https://coveralls.io/github/ggpasqualino/plug_checkup?branch=master)

# PlugCheckup

PlugCheckup provides a Plug for adding simple health checks to your app. The [JSON output](#response) is similar to the one provided by the [MiniCheck](https://github.com/workshare/mini-check) Ruby library. It was started at [solarisBank](https://www.solarisbank.de/en/) as an easy way of providing monitoring to our Plug based applications.

## Usage

- Add the package to "mix.exs"
```elixir
defp deps do
  [
    {:plug_checkup, "~> 0.2.0"}
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
checks =
  [
    %PlugCheckup.Check{name: "DB", module: MyHealthChecks, function: :check_db},
    %PlugCheckup.Check{name: "Redis", module: MyHealthChecks, function: :check_redis}
  ]
forward "/health",
  to: PlugCheckup,
  init_opts: %PlugCheckup.Options{checks: checks}
```

## The Checks
A check is a function with arity zero, which should return either :ok or {:error, term}. In case the check raises an exception or times out, that will be mapped to an {:error, reason} result.

## Response

PlugCheckup should return either 200 or 500 statuses, Content-Type header "application/json", and the body should respect the following JSON schema
```json
{
  "$schema": "http://json-schema.org/draft-06/schema#",
  "title": "Health check list",
  "type": "array",
  "items": {
    "title": "Check",
    "type": "object",
    "properties": {
      "name": {
        "description": "The name of this check, for example: 'redis', or 'postgres'",
        "type": "string"
      },
      "healthy": {
        "description": "If the check was successful or not",
        "type" : "boolean"
      },
      "time": {
        "description": "How long the check took to run",
        "type": "integer"
      },
      "error": {
        "description": "The error reason in case the check fails",
        "type": "string"
      }
    }
  }
}
```
