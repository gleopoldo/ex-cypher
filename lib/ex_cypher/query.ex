defmodule ExCypher.Query do
  alias ExCypher.Node

  def parse({:match, elements}), do: "MATCH #{Enum.join(elements, ", ")}"

  def parse({:return, elements}), do: "RETURN #{Enum.join(elements, ", ")}"

  def parse({:node, args}) do
    apply(Node, :node, args)
  end

  def parse({:--, [from, to | []]}), do: "#{from}--#{to}"

  def parse({:->, [from, to | []]}), do: "#{from}-->#{to}"

  def parse({:<-, [from, to | []]}), do: "#{from}<--#{to}"

  def parse(_statement), do: ""
end
