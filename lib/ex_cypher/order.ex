defmodule ExCypher.Order do
  @moduledoc """
    Parses ORDER statements and provides support
    for ASC and DESC ordering syntax.
  """
  alias ExCypher.Statement

  @doc """
    Provides support to `ASC` and `DESC` syntax in `ORDER BY`
    statements
  """
  @spec parse(ast :: term(), str :: String.t()) :: String.t()
  def parse({:{}, _ctx, [variable, ordering | []]}, _str) do
    direction =
      ordering
      |> Statement.parse()
      |> String.upcase()

    "#{Statement.parse(variable)} #{direction}"
  end

  def parse(ast, str), do: Statement.parse(ast, str)
end
