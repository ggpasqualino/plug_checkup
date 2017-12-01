alias PlugCheckup.Check
alias PlugCheckup.Options

defmodule Health.RandomCheck do
  def call do
    probability = :rand.uniform
    cond do
      probability < 0.5 -> :ok
      probability < 0.7  -> {:error, "Error"}
      probability < 0.9 -> raise(RuntimeError, message: "Exception")
      true -> :timer.sleep(2000)
    end
  end
end

defmodule MyRouter do
  use Plug.Router

  plug :match
  plug :dispatch

  self_checks = [
    %Check{name: "random1", module: Health.RandomCheck, function: :call},
    %Check{name: "random2", module: Health.RandomCheck, function: :call},
  ]
  deps_checks = [
    %Check{name: "random1", module: Health.RandomCheck, function: :call},
    %Check{name: "random2", module: Health.RandomCheck, function: :call},
  ]

  forward "/selfhealth", to: PlugCheckup, init_opts: %Options{checks: self_checks, timeout: 1000}
  forward "/dependencyhealth", to: PlugCheckup, init_opts: %Options{checks: deps_checks, timeout: 1000}

  match _ do
    send_resp(conn, 404, "oops")
  end
end

{:ok, _} = Plug.Adapters.Cowboy.http(MyRouter, [])
