defmodule PlugCheckup.Check do
  @moduledoc """
  Defines the structure of a check.
  Executes a check updating its result and execution time. Also, it transforms any exception into a tuple {:error, reason}
  """

  defstruct [:name, :module, :function, :result, :time]

  def execute(check) do
    {time, result} = with_time(&safe_execute/1, [check])
    %{check | result: result, time: time}
  end

  def with_time(fun, args) do
    time_before = System.monotonic_time
    result = apply(fun, args)
    time_after = System.monotonic_time
    time = System.convert_time_unit(time_after - time_before, :native, :microsecond)

    {time, result}
  end

  defp safe_execute(check) do
    apply(check.module, check.function, [])
  rescue
    e -> {:error, e.message}
  end
end
