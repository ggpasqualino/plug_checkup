defmodule PlugCheckup.Options do
  defstruct timeout: :timer.seconds(1), checks: []
end
