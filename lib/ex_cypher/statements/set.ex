defmodule ExCypher.Statements.Set do
  @moduledoc false

  alias ExCypher.Statements.Generic

  def parse({:=, _ctx, [first, last |[]]}, env) do
    [parse(first, env), "=", parse(last, env)]
  end

  def parse({atom, _ctx, nil}, _env) when is_atom(atom), do:
    Atom.to_string(atom)

  def parse(list, env) when is_list(list) do
    Enum.map(list, &parse(&1, env))
  end

  def parse(ast, env) do
    Generic.parse(ast, env)
  end
end
