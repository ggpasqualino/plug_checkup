defmodule PlugCheckup.CheckTest do
  use ExUnit.Case, async: true

  alias PlugCheckup.Check

  describe "safe_execute/1" do
    test "it converts exceptions to errors" do
      check = %Check{module: MyChecks, function: :raise_exception}
      assert Check.safe_execute(check) == {:error, "Exception"}
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

  describe "with_time/2" do
    test "it calculates the exection time" do
      {time, result} = Check.with_time(&MyChecks.execute_long_time/0, [])
      assert time >= 1_000_000 #microseconds
      assert result == :ok
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
