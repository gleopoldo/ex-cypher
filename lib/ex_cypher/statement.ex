defmodule ExCypher.Statement do
  alias ExCypher.Statements.{Generic, Order, Where}

  @moduledoc """
    Cypher syntax varies depending on the statement being used. For example,
    the `WHERE` statement's syntax can vary a lot when compared to simpler
    `RETURN` statements.

    This way, there's no point on creating an extense library with several
    pattern matching conditions when some of them shouldn't be applied to
    statements like `RETURN` or `LIMIT`.

    This module splits the syntax parsing into submodules, making it easier to
    check, maintain and improve the support to the Cypher language in this
    library.
  """

  @type command_name :: atom

  @spec parse(name :: command_name(), ast :: term(), str :: String.t()) ::
          String.t()
  def parse(:where, ast, str) do
    Where.parse(ast, str)
  end

  def parse(:order, ast, str) do
    Order.parse(ast, str)
  end

  def parse(_, ast, str) do
    Generic.parse(ast, str)
  end
end
