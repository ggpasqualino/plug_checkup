defmodule PlugCheckup.Options do
  defstruct path: "/", timeout: :timer.seconds(1), checks: []
end
