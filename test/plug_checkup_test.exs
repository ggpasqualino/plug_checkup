defmodule PlugCheckupTest do
  use ExUnit.Case, async: true
  use Plug.Test

  defmodule MyChecks do
    def raise_exception do
      raise RuntimeError, message: "Exception"
    end

    def execute_successfuly do
      :ok
    end

    def execute_with_error do
      {:error, "Error"}
    end

    def execute_long_time do
      1 |> :timer.seconds() |> :timer.sleep()
      :ok
    end
  end

  alias PlugCheckup.Check
  alias PlugCheckup.Options
  alias Poison.Parser

  describe "status" do
    test "it is 200 when healthy" do
      request = conn(:get, "/")
      options = PlugCheckup.init(%Options{checks: [%Check{name: "1", module: MyChecks, function: :execute_successfuly}]})

      response = PlugCheckup.call(request, options)

      assert response.status == 200
    end

    test "it is 500 when not healthy" do
      request = conn(:get, "/")
      options = PlugCheckup.init(%Options{checks: [%Check{name: "1", module: MyChecks, function: :execute_with_error}]})

      response = PlugCheckup.call(request, options)

      assert response.status == 500
    end
  end

  describe "content-type" do
    test "it is 'application/json' when healthy" do
      request = conn(:get, "/")
      options = PlugCheckup.init(%Options{checks: [%Check{name: "1", module: MyChecks, function: :execute_successfuly}]})

      response = PlugCheckup.call(request, options)

      assert get_resp_header(response, "content-type") == ["application/json; charset=utf-8"]
    end

    test "it is 'application/json' when not healthy" do
      request = conn(:get, "/")
      options = PlugCheckup.init(%Options{checks: [%Check{name: "1", module: MyChecks, function: :execute_with_error}]})

      response = PlugCheckup.call(request, options)

      assert get_resp_header(response, "content-type") == ["application/json; charset=utf-8"]
    end
  end

  describe "body" do
    test "it is a valid json when healthy" do
      request = conn(:get, "/")
      options = PlugCheckup.init(%Options{checks: [%Check{name: "1", module: MyChecks, function: :execute_successfuly}]})

      response = PlugCheckup.call(request, options)
      formatted_response = Parser.parse!(response.resp_body)

      assert [%{
        "name" => "1",
        "time" => time,
        "healthy" => true,
        "error" => nil
      }] = formatted_response

      assert is_integer(time)
    end

    test "it is a valid json when not healthy" do
      request = conn(:get, "/")
      options = PlugCheckup.init(%Options{checks: [%Check{name: "1", module: MyChecks, function: :execute_with_error}]})

      response = PlugCheckup.call(request, options)
      formatted_response = Parser.parse!(response.resp_body)

      assert [%{
        "name" => "1",
        "time" => time,
        "healthy" => false,
        "error" => "Error"
      }] = formatted_response

      assert is_integer(time)
    end
  end
end
