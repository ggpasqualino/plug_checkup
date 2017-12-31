defmodule PlugCheckup.Options do
  @moduledoc """
  Defines the options which can be given to initialize PlugCheckup.
  """
  defstruct timeout: :timer.seconds(1), checks: [], pretty: true
end
