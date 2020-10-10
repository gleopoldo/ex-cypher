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
  def parse(ast = {{:., _, [first, last | []]}, _, _}, env) do
    expr = Expression.new(ast, env)

    if expr.type == :property do
      [first, last] = expr.args

      if is_var?(first, env) do
        escape(ast)
      else
        {term, _, _} = first
        "#{Atom.to_string(term)}.#{parse(last)}"
      end
    end
  end

  # Injects raw cypher functions
  def parse(ast = {:fragment, _ctx, args}, env) do
    expr = Expression.new(ast, env)

    if expr.type == :fragment do
      expr.args
      |> Enum.map(&parse/1)
      |> Enum.map(&String.replace(&1, "\"", ""))
      |> Enum.join(", ")
    end
  end

  def parse(ast = {:node, _ctx, args}, env) do
    expr = Expression.new(ast, env)

    if expr.type == :node do
      args =
        expr.args
        |> Enum.map(fn
          {:%{}, _ctx, args} -> Enum.into(args, %{})
          term -> term
        end)

      apply(Node, :node, args)
    end
  end

  def parse(ast = {:rel, _ctx, args}, env) do
    expr = Expression.new(ast, env)

    if expr.type == :relationship do

      args =
        expr.args
        |> Enum.map(fn
          {:%{}, _ctx, args} -> Enum.into(args, %{})
          term -> term
        end)

      apply(Relationship, :rel, args)
    end
  end

  @associations [:--, :->, :<-]
  def parse(ast = {association, _ctx, [from, to]}, env)
      when association in @associations do

    expr = Expression.new(ast, env)

    if expr.type == :association do
      [association, {from, to}] = expr.args

      from = {type(:from, from), parse(from)}
      to = {type(:to, to), parse(to)}

      apply(Relationship, :assoc, [association, {from, to}])
    end
  end

  def parse(ast = nil, env) do
    expr = Expression.new(ast, env)

    if expr.type == :null do
      "NULL"
    end
  end

  def parse(term, env) when is_atom(term) do
    expr = Expression.new(term, env)

    if expr.type == :alias do
      Atom.to_string(expr.args)
    end
  end

  def parse(list, env) when is_list(list) do
    expr = Expression.new(list, env)

    if expr.type == :list do
      expr.args
      |> Enum.map(&parse/1)
      |> Enum.intersperse(",")
    end
  end

  def parse(term = {var_name, _ctx, nil}, _env) when is_atom(var_name) do
    escape(term)
  end

  def parse(term, _env), do: term |> Macro.to_string()

  # We cannot rely on string manipulation in order to identify whether a given
  # node represents a node or a relationship as was being made before, 'cause it
  # can lead to problems when unquoting bound variables.
  #
  # It's better to rely on the AST structure itself instead
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
