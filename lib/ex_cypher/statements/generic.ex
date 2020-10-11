defmodule ExCypher.Statements.Generic do
  @moduledoc false

  # This module will provide the most generic AST conversion
  # functions that'll be shared between different commands.

  # Of course, such abstraction won't be possible to match
  # all kinds of statements, because some cypher commands
  # like the `WHERE` statement, have a unique syntax that is
  # very different from simpler ones, like the `RETURN`
  # statement.

  # The intent, in this way, is to combine functions in a
  # specialization way. Outer modules attempt to filter and
  # process their specific syntaxes and, whenever they can't,
  # use this module as a last attempt to convert those AST
  # nodes.

  # This way the core logic, which can include the caveat arround
  # elixir's function identification on unknown names, for example,
  # can be shared with other modules

  alias ExCypher.Graph.{Node, Relationship}
  alias ExCypher.Statements.Generic.Expression

  @spec parse(ast :: term()) :: String.t()

  def parse(ast, env \\ nil)

  # Removing parenthesis from statements that elixir
  # attempts to resolve a name as a function.
  def parse(ast, env) do
    parse_expression(Expression.new(ast, env))
  end

  defp parse_expression(expr = %Expression{type: :property}) do
    [first, last] = expr.args

    "#{parse(first, expr.env)}.#{parse(last, expr.env)}"
  end

  defp parse_expression(expr = %Expression{type: :fragment}) do
    expr.args
    |> Enum.map(&parse(&1, expr.env))
    |> Enum.map(&String.replace(&1, "\"", ""))
    |> Enum.join(", ")
  end

  defp parse_expression(expr = %Expression{type: :node}),
    do: apply(Node, :node, expr.args)

  defp parse_expression(expr = %Expression{type: :relationship}),
    do: apply(Relationship, :rel, expr.args)

  defp parse_expression(expr = %Expression{type: :association}) do
    [association, {from_type, from}, {to_type, to}] = expr.args

    apply(Relationship, :assoc, [
      association,
      {
        {from_type, parse(from, expr.env)},
        {to_type, parse(to, expr.env)}
      }
    ])
  end

  defp parse_expression(%Expression{type: :null}),
    do: "NULL"

  defp parse_expression(expr = %Expression{type: :alias}),
    do: Atom.to_string(expr.args)

  defp parse_expression(expr = %Expression{type: :list}) do
    expr.args
    |> Enum.map(&parse(&1, expr.env))
    |> Enum.intersperse(",")
  end

  defp parse_expression(expr = %Expression{type: :var}) do
    term = expr.args

    quote bind_quoted: [term: term] do
      if is_binary(term) do
        "\"#{term}\""
      else
        term
      end
    end
  end

  defp parse_expression(%Expression{args: args}), do: Macro.to_string(args)
end
