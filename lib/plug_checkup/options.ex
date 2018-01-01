defmodule PlugCheckup.Options do
  @moduledoc """
  Defines the options which can be given to initialize PlugCheckup.
  """
  defstruct timeout: :timer.seconds(1), checks: [], pretty: true

  @type t ::  %__MODULE__{
    timeout: pos_integer(),
    checks: list(PlugCheckup.Check.t()),
    pretty: boolean()
  }

  @spec new(keyword()) :: __MODULE__.t()
  def new(opts \\ []) do
    default = %__MODULE__{}
    Map.merge(default, fields_to_change(opts))
  end

  defp fields_to_change(opts) do
    opts
    |> Keyword.take([:timeout, :checks, :pretty])
    |> Enum.into(Map.new)
    |> validate!()
  end

  defp validate!(fields) do
    validate_change(fields, :timeout, &validate_timeout!/1)
    validate_change(fields, :checks, &validate_checks!/1)
    validate_change(fields, :pretty, &validate_pretty!/1)

    fields
  end

  defp validate_change(fields, key, validator) do
    if Map.has_key?(fields, key) do
      value = fields[key]
      validator.(value)
    end
  end

  defp validate_timeout!(timeout) do
    if !is_integer(timeout) || timeout <= 0 do
      raise ArgumentError, message: "timeout should be a positive integer"
    end
  end

  defp validate_checks!(checks) do
    not_a_check? = &(!match?(%{__struct__: PlugCheckup.Check}, &1))
    if Enum.any?(checks, not_a_check?) do
      raise ArgumentError, message: "checks should be a list of PlugCheckup.Check"
    end
  end

  defp validate_pretty!(pretty) do
    if pretty not in [true, false] do
      raise ArgumentError, message: "pretty should be a boolean"
    end
  end
end
