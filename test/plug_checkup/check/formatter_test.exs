defmodule PlugCheckup.Check.FormatterTest do
  use ExUnit.Case, async: true

  alias PlugCheckup.Check
  alias PlugCheckup.Check.Formatter

  describe "format/2" do
    test "it formats successful check" do
      check =
        %Check{
          name: "check 1",
          module: Fake,
          function: :call,
          result: :ok,
          time: 1234
        }

      formatted = Formatter.format(check)
      assert formatted ==
        %{
          "name" => "check 1",
          "time" => 1234,
          "healthy" => true,
          "error" => nil
        }
    end

    test "it formats unsuccessful check" do
      check =
        %Check{
          name: "check 1",
          module: Fake,
          function: :call,
          result: {:error, "Error"},
          time: 1234
        }

      formatted = Formatter.format(check)
      assert formatted ==
        %{
          "name" => "check 1",
          "time" => 1234,
          "healthy" => false,
          "error" => "Error"
        }
    end

    test "it formats a list of checks" do
      checks =
        [%Check{
          name: "check 1",
          module: Fake,
          function: :call,
          result: :ok,
          time: 1234
        }]

      formatted = Formatter.format(checks)
      assert formatted ==
        [%{
          "name" => "check 1",
          "time" => 1234,
          "healthy" => true,
          "error" => nil
        }]
    end

    test "it formats the time" do
      check =
        %Check{
          name: "check 1",
          module: Fake,
          function: :call,
          result: :ok,
          time: 1234
        }

      formatted = Formatter.format(check, time_unit: :millisecond)
      assert formatted ==
        %{
          "name" => "check 1",
          "time" => 1,
          "healthy" => true,
          "error" => nil
        }
    end
  end
end
