defmodule ExCypher.Node do
  def node, do: to_node("")
  def node(props = %{}), do: props |> stringify() |> to_node()

  def node(name, labels \\ [], props \\ %{}) do
    [name, labels, props]
    |> Enum.map(&stringify/1)
    |> Enum.join("")
    |> to_node()
  end

  defp to_node(inner) when is_binary(inner) do
    inner = String.trim(inner)
    "(#{inner})"
  end

  defp stringify(element)
       when is_atom(element),
       do: Atom.to_string(element)

  defp stringify([]), do: ""

  defp stringify(props) when props == %{}, do: ""

  defp stringify(list)
       when is_list(list),
       do: ":#{Enum.join(list, ",")}"

  defp stringify(props = %{}) do
    args =
      props
      |> Enum.into([])
      |> Enum.map(fn {name, value} -> ~s["#{name}":"#{value}"] end)
      |> Enum.join(",")

    " {#{args}}"
  end
end
