defmodule ExCypher.Statements.Order do
  @moduledoc false

  # Parses ORDER statements and provides support
  # for ASC and DESC ordering syntax.

  alias ExCypher.Statements.Generic

  @spec parse(ast :: term()) :: String.t()
  def parse({term, ordering}) when ordering in [:asc, :desc] do
    direction =
      ordering
      |> Generic.parse()
      |> String.upcase()

    "#{Generic.parse(term)} #{direction}"
  end

  def parse(list) when is_list(list) do
    list
    |> Enum.map(&parse/1)
    |> Enum.join(", ")
  end

  def parse(ast), do: Generic.parse(ast)
end
