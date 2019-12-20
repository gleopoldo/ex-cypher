defmodule ExCypher.Where do
  @moduledoc """
    Parses WHERE statements into cypher compliant statements, avoiding some
    changes made by elixir's compiler into the `where` statements
  """
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

  # Removing parenthesis from statements that elixir
  # attempts to resolve a name as a function.
  defp parse_operator(ast = {{:., _, [_first, _last | []]}, _, _}, _str) do
    parse_operator(ast)
  end

  defp parse_operator({op, _, [first, last | []]}, _str)
       when op in @logical_operators do
    operator_name =
      op
      |> Atom.to_string()
      |> String.upcase()

    "#{parse_operator(first)} #{operator_name} #{parse_operator(last)}"
  end

  defp parse_operator(_ast, str), do: str

  defp parse_operator({{:., _, [first, last | []]}, _, _}) do
    "#{parse_operator(first)}.#{parse_operator(last)}"
  end

  defp parse_operator(term) when is_atom(term), do: Atom.to_string(term)

  defp parse_operator(term), do: term |> Macro.to_string()
end
