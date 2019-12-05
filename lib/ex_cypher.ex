defmodule ExCypher do
  @moduledoc """
  A DSL to make it easy to integrate other apps to Neo4J applications.

  This module provide a clean API to build queries using CYPHER query language,
  which is largely used by Neo4j
  """

  alias ExCypher.Query

  defmacro cypher(do: block) do
    quote do
      {:ok, var!(buffer, ExCypher)} = new_query()
      unquote(block)

      query = generate_query(var!(buffer, ExCypher))
      stop_buffer(var!(buffer, ExCypher))

      query
    end
  end

  def node(name, labels), do: "(#{name}:#{Enum.join(labels, ", ")})"

  defmacro command(name, args \\ []) do
    quote do
      put_buffer(var!(buffer, ExCypher), {unquote(name), unquote(args)})
    end
  end

  def put_buffer(buffer, elements) do
    Agent.update(buffer, & [ elements | &1 ])
  end

  def generate_query(buffer) do
    buffer
    |> Agent.get(fn query -> query end)
    |> Enum.reverse()
    |> Enum.map(&Query.parse/1)
    |> Enum.join(" ")
  end

  def stop_buffer(buffer), do: Agent.stop(buffer)

  def new_query, do: Agent.start_link(fn -> [] end)
end
