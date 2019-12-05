defmodule ExCypher.Query do
  def parse({:match, elements}), do: "MATCH #{Enum.join(elements, ", ")}"
  def parse({:return, elements}), do: "RETURN #{Enum.join(elements, ", ")}"
  def parse(statement), do: ""

  def node(name, labels), do: "(#{name}:#{Enum.join(labels, ", ")})"
end
