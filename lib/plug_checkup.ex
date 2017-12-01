defmodule PlugCheckup do
  @moduledoc """
  Documentation for PlugCheckup.
  """

  alias PlugCheckup.Check.Formatter
  alias PlugCheckup.Check.Runner
  alias PlugCheckup.Options

  import Plug.Conn

  def init(options = %Options{}) do
    options
  end

  def call(conn, opts) do
    results = Runner.async_run(opts.checks, opts.timeout)

    conn
    |> put_resp_content_type("application/json")
    |> send_response(results)
  end

  def send_response(conn, {success, results}) do
    status =
      case success do
        :ok -> 200
        :error -> 500
      end

    response = results |> Formatter.format() |> Poison.encode!
    send_resp(conn, status, response)
  end
end
