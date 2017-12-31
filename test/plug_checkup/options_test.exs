defmodule PlugCheckup.OptionsTest do
  use ExUnit.Case, async: true

  alias PlugCheckup.Options

  test "it has default timeout" do
    options = %Options{}
    assert options.timeout == :timer.seconds(1)
  end

  test "it has default checks" do
    options = %Options{}
    assert options.checks == []
  end

  test "it has default pretty" do
    options = %Options{}
    assert options.pretty
  end
end
