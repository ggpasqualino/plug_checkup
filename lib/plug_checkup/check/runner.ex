defmodule PlugCheckup.Check.Runner do
  @moduledoc """
  Executes the given checks asynchronously respecting the given timeout for each of the checks,
  and decides whether the execution was successful or not.
  """
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
    async_options = [timeout: timeout, on_timeout: :kill_task]
    Task.async_stream(checks, &Check.execute/1, async_options)
  end

  def task_to_result({{:ok, result}, _check}) do
    result
  end
  def task_to_result({{:exit, reason}, check}) do
    %{check | result: {:error, reason}}
  end
end
