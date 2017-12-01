defmodule PlugCheckup.Check.Formatter do
  def format(checks) when is_list(checks) do
    Enum.map(checks, &format/1)
  end
  def format(check) do
      %{
        "name" => check.name,
        "time" => check.time,
        "healthy" => check.result == :ok,
        "error" =>
          if check.result == :ok do
            nil
          else
            {:error, reason} = check.result
            reason
          end
      }
  end
end
