defmodule ExCypher.Node do
  @moduledoc """
  Builds nodes using cypher syntax

  It can be used in order to build more complex queries involving your
  graph nodes.
  """

  import ExCypher.Props, only: [stringify: 1]

  @doc """
  Returns the CYPHER's syntax to a node element.

  ### Examples:

      iex> node()
      "()"

      iex> node(%{name: "bob"})
      "({\"name\": \"bob\"})"

      iex> node([:Person])
      "(:Person)"

      iex> node([:Person], %{name: "Amelia"})
      "(:Person {name: \"Amelia\"})"

      iex> node(:a, [:Node])
      "(a:Node)"

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
