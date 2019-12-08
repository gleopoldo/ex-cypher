defmodule ExCypher.Query do
  alias ExCypher.Node
  alias ExCypher.Relationship

  def parse({:match, elements}), do: "MATCH #{Enum.join(elements, ", ")}"

  def parse({:return, elements}), do: "RETURN #{Enum.join(elements, ", ")}"

  def parse({:pipe_with, elements}), do: "WITH #{Enum.join(elements, ", ")}"

  def parse({:order, elements}) do
    params =
      elements
      |> Enum.map(fn
        str when is_binary(str) or is_atom(str) -> str
        {str, :asc} -> "#{str} ASC"
        {str, :desc} -> "#{str} DESC"
      end)
      |> Enum.join(", ")

    "ORDER BY #{params}"
  end

  def parse({:node, args}), do: apply(Node, :node, args)

  def parse({:rel, args}),
    do: apply(Relationship, :rel, args)

  def parse({:--, [from, to]}),
    do: apply(Relationship, :assoc, [:--, {from, to}])

  def parse({:->, [from, to | []]}),
    do: apply(Relationship, :assoc, [:->, {from, to}])

  def parse({:<-, [from, to | []]}),
    do: apply(Relationship, :assoc, [:<-, {from, to}])

  def parse(_statement), do: ""
end
