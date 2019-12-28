defmodule ExCypher.Statements.Where do
  @moduledoc false

  # Parses WHERE statements into cypher compliant statements, avoiding some
  # changes made by elixir's compiler into the `where` statements

  alias ExCypher.Statements.Generic

  @logical_operators [:and, :or, :=]

  @doc false
  @spec parse(ast :: term()) :: String.t()
  def parse({op, _, [first, last | []]})
      when op in @logical_operators do
    operator_name =
      op
      |> Atom.to_string()
      |> String.upcase()

    "#{parse(first)} #{operator_name} #{parse(last)}"
  end

  def parse(list) when is_list(list) do
    list
    |> Enum.map(&parse/1)
    |> Enum.join(", ")
  end

  def parse(ast) do
    Generic.parse(ast)
  end
end
