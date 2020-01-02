defmodule ExCypher.Graph.Node do
  @moduledoc """
  Builds nodes using cypher syntax

  It can be used in order to build more complex queries involving your
  graph nodes.
  """

  import ExCypher.Graph.Props, only: [escape_node: 3]

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
  def node(props = %{}), do: node(nil, nil, props)

  @spec node(
          name :: String.t(),
          labels :: list(),
          props :: map()
        ) :: String.t()
  def node(name, labels \\ [], props \\ %{}) do
    escape_node(name, labels, props)
    |> Enum.join("")
    |> to_node()
  end

  defp to_node(inner) when is_binary(inner) do
    inner = String.trim(inner)
    "(#{inner})"
  end
end
