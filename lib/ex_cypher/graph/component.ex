defmodule ExCypher.Graph.Props do
  @moduledoc false

  # Maps and lists doesn't implement the String.Chars protocol,
  # and they'll need also some parsing so that they're compliant
  # with the cypher syntax.

  # This module provides a way to help converting those contents
  # into a cypher-compliant strings that can be used to build
  # both nodes and relationships arguments.
  def escape_node(node_name \\ "", node_labels \\ [], node_props \\ %{}) do
    [escape(node_name), escape(node_labels), escape(node_props)]
  end

  def escape_relation(rel_name \\ "", rel_labels \\ [], rel_props \\ %{}) do
    [escape(rel_name), escape(rel_labels), escape(rel_props)]
  end

  def escape(nil), do: ""

  def escape(element)
      when is_atom(element),
      do: Atom.to_string(element)

  def escape([]), do: ""

  def escape(props) when props == %{}, do: ""

  def escape(list)
      when is_list(list),
      do: ":#{Enum.join(list, ",")}"

  def escape(props = %{}) do
    args =
      props
      |> Enum.into([])
      |> Enum.map(fn
        {name, value} when is_binary(value) -> ~s[#{name}:"#{value}"]
        {name, value} -> ~s[#{name}:#{value}]
      end)
      |> Enum.join(",")

    " {#{args}}"
  end

  def escape(str), do: str
end
