defmodule PlugCheckupTest do
  use ExUnit.Case, async: true
  use Plug.Test

  alias PlugCheckup.Check
  alias PlugCheckup.Options
  alias Plug.Conn.Query

  defp execute_plug(check, query_params \\ %{})

  defp execute_plug(:healthy, query_params) do
    check = %Check{name: "1", module: MyChecks, function: :execute_successfuly}
    execute_plug(check, query_params)
  end

  defp execute_plug(:not_healthy, query_params) do
    check = %Check{name: "1", module: MyChecks, function: :execute_with_error}
    execute_plug(check, query_params)
  end

  defp execute_plug(check = %Check{}, query_params) do
    execute_plug([check], query_params)
  end

  defp execute_plug(checks, query_params) when is_list(checks) do
    options = PlugCheckup.init(Options.new(json_encoder: Jason, checks: checks))
    request = conn(:get, "/?" <> Query.encode(query_params))

    PlugCheckup.call(request, options)
  end

  describe "status" do
    test "it is 200 when healthy" do
      response = execute_plug(:healthy)
      assert response.status == 200
    end

    test "filters checks by selector" do
      response =
        execute_plug(
          [
            %Check{name: "1", module: MyChecks, function: :execute_successfuly},
            %Check{name: "2", module: MyChecks, function: :execute_with_error}
          ],
          %{"check_name_selector" => "1"}
        )

      assert response.status == 200
    end

    test "it is 500 when not healthy" do
      response = execute_plug(:not_healthy)
      assert response.status == 500
    end
  end

  describe "content-type" do
    test "it is 'application/json' when healthy" do
      response = execute_plug(:healthy)
      assert get_resp_header(response, "content-type") == ["application/json; charset=utf-8"]
    end

    test "it is 'application/json' when not healthy" do
      response = execute_plug(:not_healthy)
      assert get_resp_header(response, "content-type") == ["application/json; charset=utf-8"]
    end
  end

  describe "body" do
    test "it is a valid json when healthy" do
      response = execute_plug(:healthy)
      formatted_response = Jason.decode!(response.resp_body)

      assert [
               %{
                 "name" => "1",
                 "time" => time,
                 "healthy" => true,
                 "error" => nil
               }
             ] = formatted_response

      assert is_integer(time)
    end

    test "it is a valid json when not healthy" do
      response = execute_plug(:not_healthy)
      formatted_response = Jason.decode!(response.resp_body)

      assert [
               %{
                 "name" => "1",
                 "time" => time,
                 "healthy" => false,
                 "error" => "Error"
               }
             ] = formatted_response

      assert is_integer(time)
    end
  end
end
