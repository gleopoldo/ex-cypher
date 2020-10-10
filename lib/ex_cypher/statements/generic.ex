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
    expr = Expression.new(ast, env)

    case expr.type do
      :property ->
        [first, last] = expr.args

        if is_var?(first, env) do
          escape(ast)
        else
          {term, _, _} = first
          "#{Atom.to_string(term)}.#{parse(last)}"
        end

      :fragment ->
        expr.args
        |> Enum.map(&parse/1)
        |> Enum.map(&String.replace(&1, "\"", ""))
        |> Enum.join(", ")

      :node ->
        args =
          expr.args
          |> Enum.map(fn
            {:%{}, _ctx, args} -> Enum.into(args, %{})
            term -> term
          end)

        apply(Node, :node, args)

      :relationship ->
        args =
          expr.args
          |> Enum.map(fn
            {:%{}, _ctx, args} -> Enum.into(args, %{})
            term -> term
          end)

        apply(Relationship, :rel, args)

      :association ->
        [association, {from, to}] = expr.args

        from = {type(:from, from), parse(from)}
        to = {type(:to, to), parse(to)}

        apply(Relationship, :assoc, [association, {from, to}])

      :null ->
        "NULL"

      :alias ->
        Atom.to_string(expr.args)

      :list ->
        expr.args
        |> Enum.map(&parse/1)
        |> Enum.intersperse(",")

      :var ->
        escape(expr.args)

      _ ->
        Macro.to_string(expr.args)
    end
  end

  # We cannot rely on string manipulation in order to identify whether a given
  # node represents a node or a relationship as was being made before, 'cause it
  # can lead to problems when unquoting bound variables.
  #
  # It's better to rely on the AST structure itself instead
  @associations [:--, :->, :<-]
  def type(side, ast_node) do
    case {side, ast_node} do
      {_side, {:node, _ctx, _args}} ->
        :node

      {_side, {:rel, _ctx, _args}} ->
        :relationship

      {:from, {assoc, _ctx, [_from, to | _]}} when assoc in @associations ->
        type(:from, to)

      {:to, {assoc, _ctx, [from | _]}} when assoc in @associations ->
        type(:to, from)

      {side, {other, _ctx, _args}} ->
        type(side, other)

      {side, [term | _rest]} ->
        type(side, term)
    end
  end

  defp is_var?({var_name, _ctx, nil}, env) do
    if env do
      env
      |> Macro.Env.vars()
      |> Keyword.keys()
      |> Enum.find(&(&1 == var_name))
    else
      false
    end
  end

  defp escape(term) do
    quote bind_quoted: [term: term] do
      if is_binary(term) do
        "\"#{term}\""
      else
        term
      end
    end
  end
end
