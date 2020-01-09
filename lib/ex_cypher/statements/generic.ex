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

  alias ExCypher.Binding
  alias ExCypher.Graph.{Node, Relationship}

  @spec parse(ast :: term()) :: String.t()

  def parse(ast, env \\ nil)

  # Injects raw cypher functions
  def parse({:fragment, _ctx, args}, _env) do
    args
    |> Enum.map(&parse/1)
    |> Enum.map(&String.replace(&1, "\"", ""))
    |> Enum.join(", ")
  end

  def parse({:node, _ctx, args}, _env) do
    args =
      args
      |> Enum.map(fn
        {:%{}, _ctx, args} -> Enum.into(args, %{})
        term -> term
      end)

    apply(Node, :node, args)
  end

  def parse({:rel, _ctx, args}, _env) do
    args =
      args
      |> Enum.map(fn
        {:%{}, _ctx, args} -> Enum.into(args, %{})
        term -> term
      end)

    apply(Relationship, :rel, args)
  end

  @associations [:--, :->, :<-]
  def parse({association, _ctx, [from, to]}, _env)
      when association in @associations do
    from = {type(:from, from), parse(from)}
    to = {type(:to, to), parse(to)}

    apply(Relationship, :assoc, [association, {from, to}])
  end

  def parse(nil, _env), do: "NULL"

  def parse(list, env) when is_list(list) do
    list
    |> Enum.map(&parse(&1, env))
    |> Enum.intersperse(",")
  end

  def parse(term, env) do
    Binding.escape(term, env)
  end

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
end
