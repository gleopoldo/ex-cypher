defmodule ExCypher do
  @moduledoc """
  A DSL to make it easy to integrate other apps to Neo4J applications.

  This module provide a clean API to build queries using CYPHER query language,
  which is largely used by Neo4j

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

  We already support associations too:

  ```
    iex> cypher do
    ...>   match node(:p, [:Person]) -- node(:c, [:Company])
    ...> end
    "MATCH (p:Person)--(c:Company)"

    iex> cypher do
    ...>   match node(:p, [:Person]) -- rel(:WORKS_IN) -- node(:c, [:Company])
    ...>   return :p
    ...> end
    "MATCH (p:Person)-[WORKS_IN]-(c:Company) RETURN p"

  ```

  Can use arrow-syntax to represent directed associations, but must use
  parenthesis arround the `match` arguments so that elixir correctly
  builds the AST with the correct precedence structure

  ```
    iex> cypher do
    ...>   match (node(:p, [:Person]) -- rel(:WORKS_IN) -> node(:c, [:Company]))
    ...> end
    "MATCH (p:Person)-[WORKS_IN]->(c:Company)"

    iex> cypher do
    ...>   match (node(:c, [:Company]) <- rel(:WORKS_IN) -- node(:p, [:Person]))
    ...> end
    "MATCH (c:Company)<-[WORKS_IN]-(p:Person)"

  ```

  ##### ORDERing and LIMITing queries:

  You can order and/or limit your query results with `order` and `limit`
  commands:

  ```
    iex> cypher do
    ...>   match node(:s, [:Sharks])
    ...>   order s.name
    ...>   limit 10
    ...>   return s.name, s.population
    ...> end
    "MATCH (s:Sharks) ORDER BY s.name LIMIT 10 RETURN s.name, s.population"

  ```

  Also, you can choose the ordering direction of your matched nodes with a
  tuple syntax:

  ```
    iex> cypher do
    ...>   match node(:s, [:Sharks])
    ...>   order {s.name, :asc}, {s.age, :desc}
    ...>   return :s
    ...> end
    "MATCH (s:Sharks) ORDER BY s.name ASC, s.age DESC RETURN s"

  ```

  ##### CREATE and MERGE stuff

  In order to create new nodes into your database, you can use the
  following syntax:

  ```
    iex> cypher do
    ...>   create node(:p, [:Player], %{nick: "like4boss", score: "100"})
    ...>   return p.name
    ...> end
    ~S[CREATE (p:Player {"nick":"like4boss","score":"100"}) RETURN p.name]

  ```

  However, if you want to match pre-existing nodes instead of creating new
  ones, you can use merge, as follows:

  ```
    iex> cypher do
    ...>   merge node(:p, [:Player], %{nick: "like4boss"})
    ...>   merge node(:p2, [:Player], %{nick: "marioboss"})
    ...>   return p.name
    ...> end
    ~S|MERGE (p:Player {"nick":"like4boss"}) MERGE (p2:Player {"nick":"marioboss"}) RETURN p.name|

  ```

  """

  alias ExCypher.Query
  alias ExCypher.Statement

  @supported_statements [:match, :create, :merge, :return, :where, :pipe_with, :order, :limit]

  @doc """
  Wraps contents of a Cypher query and returns the query string.
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

  def parse({command, _ctx, args}) when command in @supported_statements do
    params =
      Enum.map(args, fn ast_node ->
        Macro.to_string(ast_node, &Statement.parse(command, &1, &2))
      end)

    quote do
      command(unquote(command), unquote(params))
    end
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
