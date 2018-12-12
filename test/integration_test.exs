defmodule IntegrationTest do
  use ExUnit.Case, async: true
  use Plug.Test

  defmodule Health.RandomCheck do
    def call do
      probability = :rand.uniform()

      cond do
        probability < 0.5 -> :ok
        probability < 0.7 -> {:error, "Error"}
        probability < 0.9 -> raise(RuntimeError, message: "Exception")
        true -> :timer.sleep(2000)
      end
    end
  end

  defmodule MyRouter do
    use Plug.Router

    alias Health.RandomCheck
    alias PlugCheckup, as: PC

    plug(:match)
    plug(:dispatch)

    checks = [
      %PC.Check{name: "random1", module: RandomCheck, function: :call}
    ]

    forward(
      "/health",
      to: PC,
      init_opts: PC.Options.new(checks: checks, timeout: 1000)
    )

    match _ do
      send_resp(conn, 404, "oops")
    end
  end

  @number_of_requests 100
  for i <- 1..@number_of_requests do
    test "response conforms to json schema - request number #{i}" do
      response = :get |> conn("/health") |> request()

      assert response.state == :sent
      assert response.status in [200, 500]
      assert_body_is_valid(response)
    end
  end

  def request(conn) do
    MyRouter.call(conn, MyRouter.init([]))
  end

  @external_resource "priv/schemas/health_check_response.json"
  @schema "priv/schemas/health_check_response.json" |> File.read!() |> Jason.decode!()
  def assert_body_is_valid(conn) do
    json_response = Jason.decode!(conn.resp_body)
    assert ExJsonSchema.Validator.validate(@schema, json_response) == :ok
  end
end
