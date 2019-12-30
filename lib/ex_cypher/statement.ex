defmodule ExCypher.Statement do
  @moduledoc false

  alias ExCypher.Clause
  alias ExCypher.Statements.{Generic, Order, Where}

  # Cypher syntax varies depending on the statement being used. For example,
  # the `WHERE` statement's syntax can vary a lot when compared to simpler
  # `RETURN` statements.

  # This way, there's no point on creating an extense library with several
  # pattern matching conditions when some of them shouldn't be applied to
  # statements like `RETURN` or `LIMIT`.

  # This module splits the syntax parsing into submodules, making it easier to
  # check, maintain and improve the support to the Cypher language in this
  # library.

  @type command_name :: atom

  @spec parse(clause :: Clause.t()) :: String.t()
  def parse(%Clause{name: :where, args: ast}) do
    "WHERE #{Where.parse(ast)}"
  end

  def parse(%Clause{name: :order, args: ast}) do
    "ORDER BY #{Order.parse(ast)}"
  end

  def parse(%Clause{name: :pipe_with, args: ast}) do
    "WITH #{Generic.parse(ast)}"
  end

  def parse(clause = %Clause{}) do
    command_name =
      clause.name
      |> Atom.to_string()
      |> String.upcase()

    "#{command_name} #{Generic.parse(clause.args)}"
  end
end
