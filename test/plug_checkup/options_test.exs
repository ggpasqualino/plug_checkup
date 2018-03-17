defmodule PlugCheckup.OptionsTest do
  use ExUnit.Case, async: true

  alias PlugCheckup.Options

  describe "default values" do
    test "it has default timeout" do
      options = Options.new()
      assert options.timeout == :timer.seconds(1)
    end

    test "it has default checks" do
      options = Options.new()
      assert options.checks == []
    end

    test "it has default pretty" do
      options = Options.new()
      assert options.pretty == true
    end

    test "it has default time_uit" do
      options = Options.new()
      assert options.time_unit == :microsecond
    end
  end

  describe "setting timeout" do
    test "timeout is set for positive integers" do
      options = Options.new(timeout: 12)
      assert options.timeout == 12
    end

    test "it raises exception when timeout is zero" do
      assert_raise(ArgumentError, "timeout should be a positive integer", fn ->
        Options.new(timeout: 0)
      end)
    end

    test "it raises exception when timeout is negative" do
      assert_raise(ArgumentError, "timeout should be a positive integer", fn ->
        Options.new(timeout: -1)
      end)
    end

    test "it raises exception when timeout is not integer" do
      assert_raise(ArgumentError, "timeout should be a positive integer", fn ->
        Options.new(timeout: :atom)
      end)
    end
  end

  describe "setting checks" do
    test "checks is set for a list of PlugCheckup.Check" do
      check = %PlugCheckup.Check{name: "check 1"}
      options = Options.new(checks: [check])
      assert options.checks == [check]
    end

    test "it raises exception when checks is not a list of PlugCheckup.Check" do
      assert_raise(ArgumentError, "checks should be a list of PlugCheckup.Check", fn ->
        check = %{}
        Options.new(checks: [check])
      end)
    end
  end

  describe "setting pretty" do
    test "pretty is set for a boolean" do
      options = Options.new(pretty: false)
      assert options.pretty == false
    end

    test "it raises exception when pretty is not a boolean" do
      assert_raise(ArgumentError, "pretty should be a boolean", fn ->
        Options.new(pretty: :not_a_boolean)
      end)
    end
  end

  describe "setting time_unit" do
    test "time_unit is a valid value" do
      options = Options.new(time_unit: :second)
      assert options.time_unit == :second
    end

    test "it raises exception when time_unit is not a valid value" do
      assert_raise(
        ArgumentError,
        "time_unit should be one of [:second, :millisecond, :microsecond]",
        fn ->
          Options.new(time_unit: :foo)
        end
      )
    end
  end
end
