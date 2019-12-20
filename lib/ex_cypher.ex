defmodule ExCypher do
  @moduledoc """
  A DSL to make it easy to integrate other apps to Neo4J applications.

  This module provide a clean API to build queries using CYPHER query language,
  which is largely used by Neo4j
  """

  alias ExCypher.Query
  alias ExCypher.Where

  @root_commands [:match, :return, :pipe_with, :order, :limit, :create, :merge, :where]

  @helpers [:node, :--, :->, :<-, :rel]

  @doc """
  Wraps contents of a Cypher query and returns the query string.

  ### Usage:

  First of all, add `import ExCpyher` to the top of your module, so that
  `cypher` macro is available to your functions, then you can run it to generate
  you cypher queries.

  ### Examples:

  ##### MATCH statements:

  1. Matching nodes without returning a specific property

  ```
    iex> cypher do: match(node(:n))
    "MATCH (n)"

    iex> cypher do: match(node(:p, [:Person]))
    "MATCH (p:Person)"

    iex> cypher do
    ...>   match(node(:p, [:Person], %{name: "bob"}))
    ...> end
    ~S[MATCH (p:Person {"name":"bob"})]

  ```

  """
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

  def parse({:where, _ctx, args}) do
    params =
      Enum.map(args, fn ast_node ->
        Macro.to_string(ast_node, &Where.parse/2)
      end)

    quote do
      command(:where, unquote(params))
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
