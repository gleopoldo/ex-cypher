defmodule ExCypher.Statements.Order do
  @moduledoc """
    Parses ORDER statements and provides support
    for ASC and DESC ordering syntax.
  """
  alias ExCypher.Statements.Generic

  @doc """
    Provides support to `ASC` and `DESC` syntax in `ORDER BY`
    statements
  """
  @spec parse(ast :: term(), str :: String.t()) :: String.t()
  def parse({:{}, _ctx, [variable, ordering | []]}, _str) do
    direction =
      ordering
      |> Generic.parse()
      |> String.upcase()

    "#{Generic.parse(variable)} #{direction}"
  end

  def parse(ast, str), do: Generic.parse(ast, str)
end
