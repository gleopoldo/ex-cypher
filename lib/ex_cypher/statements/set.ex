defmodule ExCypher.Statements.Set do
  @moduledoc false

  alias ExCypher.Statements.Generic
  alias ExCypher.Graph.Component

  def parse({:=, _ctx, [first, last |[]]}, env) do
    [parse(first, env), "=", parse(last, env)]
  end

  def parse({:%{}, _ctx, args}, env) do
    properties =
      args
      |> Enum.into(%{})
      |> Component.escape_properties()

    quote do
      unquote(properties)
      |> List.flatten()
      |> Enum.join()
      |> String.trim()
    end
  end

  def parse({atom, _ctx, nil}, _env) when is_atom(atom), do:
    Atom.to_string(atom)

  def parse(list, env) when is_list(list) do
    list
    |> Enum.map(&parse(&1, env))
    |> Enum.intersperse(",")
  end

  def parse(ast, env) do
    Generic.parse(ast, env)
  end
end
