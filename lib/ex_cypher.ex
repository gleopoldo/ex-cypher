defmodule ExCypher do
  @moduledoc """
  A DSL to make it easy to integrate other apps to Neo4J applications.

  This module provide a clean API to build queries using CYPHER query language,
  which is largely used by Neo4j
  """

  alias ExCypher.Query

  @root_commands [:match, :return]
  @helpers [:node, :--, :->, :<-]

  defmacro cypher(do: block) do
    quote do
      {:ok, var!(buffer, ExCypher)} = new_query()

      unquote(Macro.prewalk(block, &parse/1))

      query = generate_query(var!(buffer, ExCypher))
      stop_buffer(var!(buffer, ExCypher))

      query
    end
  end

  defmacro command(name, args \\ []) do
    quote do
      put_buffer(var!(buffer, ExCypher), {unquote(name), unquote(args)})
    end
  end

  def parse({name, _ctx, args}) when name in @root_commands do
    quote do
      command(unquote(name), unquote(args))
    end
  end

  def parse({name, _ctx, args}) when name in @helpers do
    quote do: Query.parse({unquote(name), unquote(args)})
  end

  def parse(stmt), do: stmt

  def put_buffer(buffer, elements) do
    Agent.update(buffer, &[elements | &1])
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
