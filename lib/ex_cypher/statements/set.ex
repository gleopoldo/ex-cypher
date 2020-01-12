defmodule ExCypher.Statements.Set do
  @moduledoc false

  alias ExCypher.Statements.Generic
  alias ExCypher.Graph.Component

  def parse({:=, _ctx, [first, last | []]}, env) do
    [parse(first, env), "=", parse(last, env)]
  end

  def parse({:%{}, _, [{:|, _, [node_name, args | []]}]}, env) do
    [parse(node_name, env), "+=", parse_properties(args)]
  end

  def parse({:%{}, _ctx, args}, _env) do
    parse_properties(args)
  end

  def parse({:label, _ctx, [node_name, labels | []]}, env) do
    statement = [parse(node_name, env), ":", Enum.intersperse(labels, ":")]

    quote do
      unquote(statement)
      |> List.flatten()
      |> Enum.join()
      |> String.trim()
    end
  end

  def parse({atom, _ctx, nil}, _env) when is_atom(atom), do: Atom.to_string(atom)

  def parse(list, env) when is_list(list) do
    list
    |> Enum.map(&parse(&1, env))
    |> Enum.intersperse(",")
  end

  def parse(ast, env) do
    Generic.parse(ast, env)
  end

  defp parse_properties(props) do
    properties =
      props
      |> IO.inspect()
      |> Enum.into(%{})
      |> Component.escape_properties()

    quote do
      unquote(properties)
      |> List.flatten()
      |> Enum.join()
      |> String.trim()
    end
  end
end
