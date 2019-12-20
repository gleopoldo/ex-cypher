defmodule ExCypher.Statement do
  @moduledoc """
  Grouped functions to help converting statements
  """

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
      |> Enum.map(fn {name, value} -> ~s["#{name}":"#{value}"] end)
      |> Enum.join(",")

    " {#{args}}"
  end

  def stringify(str), do: str
end
