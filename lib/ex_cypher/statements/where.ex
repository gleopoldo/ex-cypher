defmodule ExCypher.Statements.Where do
  @moduledoc false

  # Parses WHERE statements into cypher compliant statements, avoiding some
  # changes made by elixir's compiler into the `where` statements

  alias ExCypher.Statements.Generic

  @logical_operators [:and, :or, :==, :!=, :>, :<, :>=, :<=]

  @doc false
  @spec parse(ast :: term()) :: String.t()
  def parse({op, _, [first, last | []]})
      when op in @logical_operators do
    operator_name = fetch_operator(op)

    [parse(first), operator_name, parse(last)]
  end

  def parse(list) when is_list(list) do
    Enum.map(list, &parse/1)
  end

  def parse(ast) do
    Generic.parse(ast)
  end

  defp fetch_operator(operator) do
    # operators that have a different syntax in cypher
    operators_dict = %{
      :== => "=",
      :and => "AND",
      :or => "OR",
      :!= => "<>",
    }

    if (string = Map.get(operators_dict, operator)) do
      string
    else
      Atom.to_string(operator)
    end
  end
end
