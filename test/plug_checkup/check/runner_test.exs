defmodule PlugCheckup.Check.RunnerTest do
  use ExUnit.Case, async: true

  alias PlugCheckup.Check
  alias PlugCheckup.Check.Runner

  describe "task_to_result/1" do
    test "it keeps the result on success" do
      check = %Check{result: :ok}
      assert Runner.task_to_result({{:ok, check}, check}) == check
    end

    test "it updates result on timeout" do
      check = %Check{result: nil}
      expected = %{check | result: {:error, "Timeout"}}
      assert Runner.task_to_result({{:exit, "Timeout"}, check}) == expected
    end
  end

  describe "execute_all/2" do
    test "it executes all checks within the timeout" do
      checks = [
        %Check{name: "1", module: MyChecks, function: :raise_exception},
        %Check{name: "2", module: MyChecks, function: :execute_successfuly},
        %Check{name: "3", module: MyChecks, function: :execute_with_error},
        %Check{name: "4", module: MyChecks, function: :execute_long_time}
      ]

      assert [
        ok: %Check{name: "1", module: MyChecks, function: :raise_exception, result: {:error, "Exception"}, time: _},
        ok: %Check{name: "2", module: MyChecks, function: :execute_successfuly, result: :ok, time: _},
        ok: %Check{name: "3", module: MyChecks, function: :execute_with_error, result: {:error, "Error"}, time: _},
        exit: :timeout
      ] = checks |> Runner.execute_all(500) |> Enum.to_list
    end
  end

  describe "async_run/2" do
    test "it executes all checks and returns ok when all checks are successful" do
      checks = [
        %Check{name: "1", module: MyChecks, function: :execute_successfuly},
        %Check{name: "2", module: MyChecks, function: :execute_successfuly}
      ]

      assert {:ok,
        [
          %Check{name: "1", module: MyChecks, function: :execute_successfuly, result: :ok, time: _},
          %Check{name: "2", module: MyChecks, function: :execute_successfuly, result: :ok, time: _}
        ]
      } = Runner.async_run(checks, 500)
    end

    test "it executes all checks and returns error when any check is unsuccessful" do
      checks = [
        %Check{name: "1", module: MyChecks, function: :execute_with_error},
        %Check{name: "2", module: MyChecks, function: :execute_successfuly}
      ]

      assert {:error,
        [
          %Check{name: "1", module: MyChecks, function: :execute_with_error, result: {:error, "Error"}, time: _},
          %Check{name: "2", module: MyChecks, function: :execute_successfuly, result: :ok, time: _}
        ]
      } = Runner.async_run(checks, 500)
    end
  end
end
