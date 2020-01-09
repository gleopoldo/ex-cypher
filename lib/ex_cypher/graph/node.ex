defmodule ExCypher.Graph.Node do
  @moduledoc """
  Builds nodes using cypher syntax

  It can be used in order to build more complex queries involving your
  graph nodes.
  """

  alias ExCypher.Graph.Component

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
  def node, do: node(nil, nil, nil)

  @spec node(props :: map()) :: String.t()
  def node(props = %{}), do: node(nil, nil, props)

  @spec node(node_name :: Strint.t() | atom(),
             props :: map()) :: String.t()
  def node(node_name, props = %{})
      when is_binary(node_name) or is_atom(node_name),
      do: node(node_name, [], props)

  @spec node(labels_list :: [atom()], props :: map()) :: String.t()
  def node(labels_list, props = %{})
      when is_list(labels_list),
      do: node("", labels_list, props)

  @spec node(
          name :: String.t(),
          labels :: list(),
          props :: map()
        ) :: String.t()
  def node(name, labels \\ [], props \\ %{}) do
    Component.escape_node(name, labels, props) |> to_node()
  end

  defp to_node(inner) do
    quote do
      unquote(inner)
      |> List.flatten()
      |> Enum.join()
      |> String.trim()
      |> Component.wrap(:node)
    end
  end
end
