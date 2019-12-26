defmodule ExCypher.Statements.Where do
  @moduledoc """
    Parses WHERE statements into cypher compliant statements, avoiding some
    changes made by elixir's compiler into the `where` statements
  """
  alias ExCypher.Statements.Generic

  @logical_operators [:and, :or]

  @doc """
    Designed to work directly with `Macro.to_string/2`, in which it receives
    two arguments:

      1. The AST node being parsed
      2. The original elixir representation for that AST node
  """
  @spec parse(ast :: term(), str :: String.t()) :: String.t()
  def parse(ast, str) do
    parse_operator(ast, str)
  end

  # Parses the WHERE logical operators
  defp parse_operator({op, _, [first, last | []]}, _str)
       when op in @logical_operators do
    operator_name =
      op
      |> Atom.to_string()
      |> String.upcase()

    "#{Generic.parse(first)} #{operator_name} #{Generic.parse(last)}"
  end

  defp parse_operator(ast, str), do: Generic.parse(ast, str)
end
