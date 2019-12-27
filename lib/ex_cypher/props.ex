defmodule ExCypher.Props do
  @moduledoc """
  Maps and lists doesn't implement the String.Chars protocol,
  and they'll need also some parsing so that they're compliant
  with the cypher syntax.

  This module provides a way to help converting those contents
  into a cypher-compliant strings that can be used to build
  both nodes and relationships arguments.
  """

  def stringify(nil), do: ""

  def stringify(element)
      when is_atom(element),
      do: Atom.to_string(element)

  def stringify([]), do: ""

  def stringify(props) when props == %{}, do: ""

  def stringify(list)
      when is_list(list),
      do: ":#{Enum.join(list, ",")}"

  def stringify(props = %{}) do
    args =
      props
      |> Enum.into([])
      |> Enum.map(fn
        {name, value} when is_binary(value) -> ~s["#{name}":"#{value}"]
        {name, value} -> ~s["#{name}":#{value}]
      end)
      |> Enum.join(",")

    " {#{args}}"
  end

  def stringify(str), do: str
end
