defmodule ExCypher.Statements.Generic.Association do
  @moduledoc """
    Parses the nodes and relationships associations in the AST
  """

  @associations [:--, :->, :<-]

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
