defmodule PlugCheckup.Check.Formatter do
  @moduledoc """
  Format the given checks into a list of maps which respects the following JSON schema
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
  """

  @spec format([PlugCheckup.Check.t]) :: [map()]
  def format(checks) when is_list(checks) do
    Enum.map(checks, &format/1)
  end

  @spec format(PlugCheckup.Check.t) :: map()
  def format(check) do
      %{
        "name" => check.name,
        "time" => check.time,
        "healthy" => check.result == :ok,
        "error" =>
          case check.result do
            :ok -> nil
            {:error, reason} -> reason
          end
      }
  end
end
