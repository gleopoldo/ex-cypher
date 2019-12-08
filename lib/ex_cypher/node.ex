defmodule ExCypher.Node do
  import ExCypher.Statement, only: [stringify: 1]

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
end
