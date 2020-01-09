defmodule ExCypher.Binding do
  @moduledoc false

  def escape(variable) do
    quote bind_quoted: [variable: variable] do
      if is_binary(variable) do
        ~s["#{variable}"]
      else
        variable
      end
    end
  end

  def escape(variable, env) do
    if is_var?(variable, env) do
      escape(variable)
    else
      raw_string(variable)
    end
  end

  def is_var?({{:., _, [first, _last | []]}, _ctx, _}, env),
    do: is_var?(first, env)

  def is_var?({var_name, _ctx, nil}, env),
    do: is_var?(var_name, env)

  def is_var?(literal, env) do
    if env do
      env
      |> Macro.Env.vars()
      |> Keyword.keys()
      |> Enum.find(&(&1 == literal))
    else
      false
    end
  end

  defp raw_string({{:., _, [first, last | []]}, _, _}) do
    "#{raw_string(first)}.#{raw_string(last)}"
  end

  defp raw_string({name, _, _}), do: raw_string(name)

  defp raw_string(atom) when is_atom(atom), do: Atom.to_string(atom)

  defp raw_string(term), do: Macro.to_string(term)
end
