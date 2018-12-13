defmodule PlugCheckup.OptionsTest do
  use ExUnit.Case, async: true

  alias PlugCheckup.Options

  describe "default values" do
    test "it has default timeout" do
      options = new_options()
      assert options.timeout == :timer.seconds(1)
    end

    test "it has default checks" do
      options = new_options()
      assert options.checks == []
    end

    test "it has default pretty" do
      options = new_options()
      assert options.pretty == true
    end

    test "it has default time_uit" do
      options = new_options()
      assert options.time_unit == :microsecond
    end
  end

  describe "setting timeout" do
    test "timeout is set for positive integers" do
      options = new_options(timeout: 12)
      assert options.timeout == 12
    end

    test "it raises exception when timeout is zero" do
      assert_raise(ArgumentError, "timeout should be a positive integer", fn ->
        new_options(timeout: 0)
      end)
    end

    test "it raises exception when timeout is negative" do
      assert_raise(ArgumentError, "timeout should be a positive integer", fn ->
        new_options(timeout: -1)
      end)
    end

    test "it raises exception when timeout is not integer" do
      assert_raise(ArgumentError, "timeout should be a positive integer", fn ->
        new_options(timeout: :atom)
      end)
    end
  end

  describe "setting checks" do
    test "checks is set for a list of PlugCheckup.Check" do
      check = %PlugCheckup.Check{name: "check 1"}
      options = new_options(checks: [check])
      assert options.checks == [check]
    end

    test "it raises exception when checks is not a list of PlugCheckup.Check" do
      assert_raise(ArgumentError, "checks should be a list of PlugCheckup.Check", fn ->
        check = %{}
        new_options(checks: [check])
      end)
    end
  end

  describe "setting pretty" do
    test "pretty is set for a boolean" do
      options = new_options(pretty: false)
      assert options.pretty == false
    end

    test "it raises exception when pretty is not a boolean" do
      assert_raise(ArgumentError, "pretty should be a boolean", fn ->
        new_options(pretty: :not_a_boolean)
      end)
    end
  end

  describe "setting time_unit" do
    test "time_unit is a valid value" do
      options = new_options(time_unit: :second)
      assert options.time_unit == :second
    end

    test "it raises exception when time_unit is not a valid value" do
      assert_raise(
        ArgumentError,
        "time_unit should be one of [:second, :millisecond, :microsecond]",
        fn ->
          new_options(time_unit: :foo)
        end
      )
    end
  end

  describe "setting json_encoder" do
    test "json_encoder is required" do
      assert_raise(ArgumentError, "PlugCheckup expects a :json_encoder configuration", fn ->
        Options.new()
      end)
    end

    test "it raises exception when json_encoder module is not loaded" do
      assert_raise(
        ArgumentError,
        "invalid :json_encoder option. The module Poison is not loaded and could not be found",
        fn ->
          new_options(json_encoder: Poison)
        end
      )
    end

    test "it raises exception when json_encoder module does't expose encode!/2 function" do
      assert_raise(
        ArgumentError,
        "invalid :json_encoder option. The module PlugCheckup must implement encode!/2",
        fn ->
          new_options(json_encoder: PlugCheckup)
        end
      )
    end

    test "json_encoder is a valid value" do
      options = new_options(json_encoder: Jason)
      assert options.json_encoder == Jason
    end
  end

  defp new_options(opts \\ []) do
    [json_encoder: Jason]
    |> Keyword.merge(opts)
    |> Options.new()
  end
end
