defmodule ExCypher.Node do
  @moduledoc """
  CYPHER node statements

  It can be used in order to build more complex queries involving your
  graph nodes.
  """

  import ExCypher.Statement, only: [stringify: 1]

  @doc """
  Returns the CYPHER's syntax to a node element.

  ### Example:


  * Building an empty node:
    iex> node()
    "()"

  * Building an node with only props:
    iex> node(%{name: "bob"})
    "({\"name\": \"bob\"})"

  * Building a labeled node:
    iex> node(:a, [:Node])
    "(a:Node)"

  * Building a more complex node (with props and labels):
    iex> node(:a, [:Node], %{name: "mark", age: 27})
    "(a:Node {\"name\": \"mark\", \"age\": 27)"
  """
  @spec node() :: String.t()
  def node, do: to_node("")

  @spec node(props :: map()) :: String.t()
  def node(props = %{}), do: props |> stringify() |> to_node()

  @spec node(
          name :: String.t(),
          labels :: list(),
          props :: map()
        ) :: String.t()
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
