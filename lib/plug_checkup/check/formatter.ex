defmodule PlugCheckup.Check.Formatter do
  @external_resource "priv/schemas/health_check_response.json"
  @schema File.read!("priv/schemas/health_check_response.json")
  @moduledoc """
  Format the given checks into a list of maps which respects the following JSON schema
  ```json
  #{@schema}
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
