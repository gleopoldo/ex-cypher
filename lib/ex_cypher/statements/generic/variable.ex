defmodule ExCypher.Statements.Generic.Variable do
  @moduledoc """
    Matches a bound variable coming in the AST, using Generic.Expression
    interface
  """

  def bound_variable?({ast, env}) do
    case {ast, env} do
      {_, nil} ->
        nil

      # matches 'var.prop' syntax
      {{{:., _, [first, _last | []]}, _, _}, env} ->
        bound_variable?({first, env})

      {{var_name, _ctx, nil}, env} ->
        exists?(var_name, env)

      _ ->
        false
    end
  end

  defp exists?(var_name, env) do
    env
    |> Macro.Env.vars()
    |> Keyword.keys()
    |> Enum.find(&(&1 == var_name))
  end
end
