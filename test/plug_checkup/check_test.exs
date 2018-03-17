defmodule PlugCheckup.CheckTest do
  use ExUnit.Case, async: true

  alias PlugCheckup.Check

  describe "safe_execute/1" do
    test "it converts exceptions to errors" do
      check = %Check{module: MyChecks, function: :raise_exception}
      assert Check.safe_execute(check) == {:error, "Exception"}
    end

    test "it converts exceptions without message field to errors" do
      check = %Check{module: MyChecks, function: :non_existent_function}

      assert Check.safe_execute(check) ==
               {:error, "function MyChecks.non_existent_function/0 is undefined or private"}
    end

    test "it converts exit values" do
      check = %Check{module: MyChecks, function: :exit}
      assert Check.safe_execute(check) == {:error, "Caught exit with value: :boom"}
    end

    test "it converts thrown values" do
      check = %Check{module: MyChecks, function: :throw}
      assert Check.safe_execute(check) == {:error, "Caught throw with value: :ball"}
    end

    test "it doesn't change error results" do
      check = %Check{module: MyChecks, function: :execute_with_error}
      assert Check.safe_execute(check) == {:error, "Error"}
    end

    test "it doesn't change succes results" do
      check = %Check{module: MyChecks, function: :execute_successfuly}
      assert Check.safe_execute(check) == :ok
    end
  end

  describe "execute/1" do
    test "executes check safely and update result" do
      check = %Check{module: MyChecks, function: :raise_exception}
      %Check{result: result} = Check.execute(check)
      assert {:error, "Exception"} == result
    end

    test "updates execution time" do
      check = %Check{module: MyChecks, function: :raise_exception}
      %Check{time: time} = Check.execute(check)
      assert is_integer(time)
      assert time > 0
    end
  end
end
