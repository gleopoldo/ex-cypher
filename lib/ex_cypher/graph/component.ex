defmodule ExCypher.Graph.Component do
  @moduledoc false

  alias ExCypher.Binding

  def wrap(str, :node), do: "(" <> str <> ")"

  def wrap(str, :relation), do: "[" <> str <> "]"

  # Maps and lists doesn't implement the String.Chars protocol,
  # and they'll need also some parsing so that they're compliant
  # with the cypher syntax.

  # This module provides a way to help converting those contents
  # into a cypher-compliant strings that can be used to build
  # both nodes and relationships arguments.
  def escape_node(node_name \\ "", node_labels \\ [], node_props \\ %{})

  def escape_node(node_name, node_labels, props) when props == %{} do
    [escape(node_name), escape(node_labels)]
  end

  def escape_node(node_name, node_labels, node_props) do
    [escape(node_name), escape(node_labels), escape(node_props)]
  end

  def escape_relation(rel_name \\ "", rel_labels \\ [], rel_props \\ %{})

  def escape_relation(rel_name, rel_labels, props) when props == %{} do
    [escape(rel_name), escape(rel_labels)]
  end

  def escape_relation(rel_name, rel_labels, rel_props) do
    [escape(rel_name), escape(rel_labels), escape(rel_props)]
  end

  def escape_properties(props = %{}) do
    [escape(props)]
  end

  def escape(nil), do: ""

  def escape(element)
      when is_atom(element),
      do: Atom.to_string(element)

  def escape([]), do: ""

  def escape(list)
      when is_list(list),
      do: [":" | Enum.intersperse(list, ",")]

  def escape(props = %{}) do
    args =
      props
      |> Enum.into([])
      |> Enum.map(fn {name, value} -> [name, ":", escape_var(value)] end)
      |> Enum.intersperse(",")

    [" {", args, "}"]
  end

  def escape(str), do: str

  defp escape_var(variable) do
    Binding.escape(variable)
  end
end
