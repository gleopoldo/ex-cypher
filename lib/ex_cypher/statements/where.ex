defmodule ExCypher.Statements.Where do
  @moduledoc false

  # Parses WHERE statements into cypher compliant statements, avoiding some
  # changes made by elixir's compiler into the `where` statements

  alias ExCypher.Statements.Generic

  @logical_operators [:and, :or, :==, :!=, :>, :<, :>=, :<=]

  @doc false
  @spec parse(ast :: term()) :: String.t()
  def parse(term, env \\ nil)

  def parse({:==, _, [first, nil | []]}, _env),
    do: [parse(first), "IS NULL"]

  def parse({:!=, _, [first, nil | []]}, _env),
    do: [parse(first), "IS NOT NULL"]

  def parse({op, _, [first, last | []]}, env)
      when op in @logical_operators do
    operator_name = fetch_operator(op)

    [parse(first, env), operator_name, parse(last, env)]
  end

  def parse(list, env) when is_list(list) do
    Enum.map(list, &parse(&1, env))
  end

  def parse(ast, env) do
    Generic.parse(ast, env)
  end

  defp fetch_operator(operator) do
    # operators that have a different syntax in cypher
    operators_dict = %{
      :== => "=",
      :and => "AND",
      :or => "OR",
      :!= => "<>"
    }

    if string = Map.get(operators_dict, operator) do
      string
    else
      Atom.to_string(operator)
    end
  end
end
