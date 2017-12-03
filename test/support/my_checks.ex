defmodule MyChecks do
  @moduledoc """
  Mock for checks
  """

  def execute_successfuly do
    :ok
  end

  def execute_with_error do
    {:error, "Error"}
  end

  def raise_exception do
    raise RuntimeError, message: "Exception"
  end

  def execute_long_time do
    1 |> :timer.seconds() |> :timer.sleep()
    :ok
  end
end
