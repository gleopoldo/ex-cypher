defmodule ExCypher.Statements.Order do
  @moduledoc false

  # Parses ORDER statements and provides support
  # for ASC and DESC ordering syntax.

  alias ExCypher.Statements.Generic

  @spec parse(ast :: term()) :: String.t()
  def parse(term, env \\ nil)

  def parse({term, ordering}, _env) when ordering in [:asc, :desc] do
    direction =
      ordering
      |> Generic.parse()
      |> String.upcase()

    [Generic.parse(term), direction]
  end

  def parse(list, _env) when is_list(list) do
    list
    |> Enum.map(&parse/1)
    |> Enum.intersperse(",")
  end

  def parse(ast, _env), do: Generic.parse(ast)
end
