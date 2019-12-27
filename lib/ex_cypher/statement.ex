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

  @spec parse(name :: command_name(), ast :: term()) ::
          String.t()
  def parse(:where, ast) do
    "WHERE #{Where.parse(ast)}"
  end

  def parse(:order, ast) do
    "ORDER BY #{Order.parse(ast)}"
  end

  def parse(:pipe_with, ast) do
    "WITH #{Generic.parse(ast)}"
  end

  def parse(term, ast) do
    command_name =
      term
      |> Atom.to_string()
      |> String.upcase()

    "#{command_name} #{Generic.parse(ast)}"
  end
end
