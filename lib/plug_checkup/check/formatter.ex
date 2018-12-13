defmodule PlugCheckup.Check.Formatter do
  @external_resource "priv/schemas/health_check_response.json"
  @schema File.read!("priv/schemas/health_check_response.json")
  @moduledoc """
  Format the given checks into a list of maps which respects the following JSON schema
  ```json
  #{@schema}
  ```
  """

  @spec format([PlugCheckup.Check.t()], keyword()) :: [map()]
  def format(checks, opts \\ [])

  def format(checks, opts) when is_list(checks) do
    Enum.map(checks, &format(&1, opts))
  end

  @spec format(PlugCheckup.Check.t(), keyword()) :: map()
  def format(check, opts) do
    %{
      "name" => check.name,
      "time" => time(check, opts),
      "healthy" => check.result == :ok,
      "error" =>
        case check.result do
          :ok -> nil
          {:error, reason} -> reason
        end
    }
  end

  defp time(check, opts) do
    time_unit = opts[:time_unit]

    if time_unit in ~w(nil microsecond)a do
      check.time
    else
      System.convert_time_unit(check.time, :microsecond, time_unit)
    end
  end
end
