defmodule PlugCheckup.Check do
  @moduledoc """
  Defines the structure of a check.
  Executes a check updating its result and execution time. Also, it transforms any exception into a tuple {:error, reason}
  """

  @type t :: %PlugCheckup.Check{
    name: String.t(),
    module: module(),
    function: atom(),
    result: atom(),
    time: pos_integer()
  }

  defstruct [:name, :module, :function, :result, :time]

  @spec execute(PlugCheckup.Check.t) :: PlugCheckup.Check.t
  def execute(check) do
    {time, result} = :timer.tc(&safe_execute/1, [check])
    %{check | result: result, time: time}
  end

  @spec safe_execute(PlugCheckup.Check.t) :: :ok | {:error, any}
  def safe_execute(check) do
    apply(check.module, check.function, [])
  rescue
    e -> {:error, Exception.message(e)}
  end
end
