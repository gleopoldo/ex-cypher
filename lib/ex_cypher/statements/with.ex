defmodule ExCypher.Statements.With do
  @moduledoc false

  # Parses WITH statements

  alias ExCypher.Statements.Generic

  @doc false
  # Parses aliasing
  def parse({term, [as: bind]}, env) do
    [parse(term, env), "AS", Atom.to_string(bind)]
  end

  def parse(list, env) when is_list(list) do
    list
    |> Enum.map(&parse(&1, env))
    |> Enum.intersperse(",")
  end

  def parse(ast, env) do
    Generic.parse(ast, env)
  end
end
