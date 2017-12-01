defmodule PlugCheckup.Check.Runner do
  alias PlugCheckup.Check

  def async_run(checks, timeout) do
    results =
      checks
      |> execute_all(timeout)
      |> Enum.zip(checks)
      |> Enum.map(&task_to_result/1)

    if Enum.all?(results, fn (r) -> r.result == :ok end) do
      {:ok, results}
    else
      {:error, results}
    end
  end

  def execute_all(checks, timeout) do
    Task.async_stream(checks, &Check.execute/1, timeout: timeout, on_timeout: :kill_task)
  end

  def task_to_result({{:ok, result}, _check}) do
    result
  end
  def task_to_result({{:exit, reason}, check}) do
    %{check | result: {:error, reason}}
  end
end
