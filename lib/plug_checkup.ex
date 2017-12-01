defmodule PlugCheckup do
  @moduledoc """
  Documentation for PlugCheckup.
  """

  defmodule Check do
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
      try do
        apply(check.module, check.function, [])
      rescue
        e -> {:error, e.message}
      end
    end
  end

  defmodule Check.Formatter do
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

  defmodule Check.Runner do
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

  import Plug.Conn

  defmodule Options do
    defstruct path: "/", timeout: :timer.seconds(1), checks: []
  end

  def init(options = %Options{}) do
    options
  end

  def call(conn, opts) do
    results = Check.Runner.async_run(opts.checks, opts.timeout)

    conn
    |> put_resp_content_type("application/json")
    |> send_response(results)
  end

  def send_response(conn, {success, results}) do
    status =
      case success do
        :ok -> 200
        :error -> 500
      end

    response = results |> Check.Formatter.format() |> Poison.encode!
    send_resp(conn, status, response)
  end
end
