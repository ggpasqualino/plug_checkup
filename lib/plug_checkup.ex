defmodule PlugCheckup do
  @moduledoc """
  PlugCheckup provides a Plug for adding simple health checks to your app.
  """

  alias PlugCheckup.Check.Formatter
  alias PlugCheckup.Check.Runner
  alias PlugCheckup.Options

  import Plug.Conn

  def init(options = %Options{}) do
    options
  end

  def call(conn, opts) do
    conn = fetch_query_params(conn)

    results =
      Runner.async_run(opts.checks, opts.timeout, conn.query_params["check_name_selector"])

    conn
    |> put_resp_content_type("application/json")
    |> send_response(results, opts)
  end

  defp send_response(conn, {success, results}, opts) do
    status =
      case success do
        :ok -> 200
        :error -> opts.error_code
      end

    response =
      results
      |> Formatter.format(time_unit: opts.time_unit)
      |> opts.json_encoder.encode!(pretty: opts.pretty)

    send_resp(conn, status, response)
  end
end
