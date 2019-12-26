defmodule ExCypher.Statement do
  @moduledoc """
    This module will provide the most generic AST conversion
    functions that'll be shared between different commands.

    Of course, such abstraction won't be possible to match
    all kinds of statements, because some cypher commands
    like the `WHERE` statement, have a unique syntax that is
    very different from simpler ones, like the `RETURN`
    statement.

    The intent, in this way, is to combine functions in a
    specialization way. Outer modules attempt to filter and
    process their specific syntaxes and, whenever they can't,
    use this module as a last attempt to convert those AST
    nodes.

    This way the core logic, which can include the caveat arround
    elixir's function identification on unknown names, for example,
    can be shared with other modules
  """

  @spec parse(ast :: term(), str :: String.t()) :: String.t()

  # Removing parenthesis from statements that elixir
  # attempts to resolve a name as a function.
  def parse(ast = {{:., _, [_first, _last | []]}, _, _}, _str) do
    parse(ast)
  end

  # Injects raw cypher functions
  def parse({:fragment, _ctx, args}, _str) do
    args
    |> Enum.map(&parse/1)
    |> Enum.map(& String.replace(&1, "\"", ""))
    |> Enum.join(", ")
  end

  def parse(ast, _str) when is_atom(ast), do: Atom.to_string(ast)

  def parse(_ast, str), do: str

  @spec parse(ast :: term()) :: String.t()

  # Removing parenthesis from statements that elixir
  # attempts to resolve a name as a function.
  def parse({{:., _, [first, last | []]}, _, _}) do
    "#{parse(first)}.#{parse(last)}"
  end

  def parse(term) when is_atom(term),
      do: Atom.to_string(term)

  def parse(term), do: term |> Macro.to_string()
end
