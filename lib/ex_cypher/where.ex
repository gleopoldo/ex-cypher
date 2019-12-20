defmodule ExCypher.Where do
  @logical_operators [:and, :or]

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
