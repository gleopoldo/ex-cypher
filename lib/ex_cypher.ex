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

    iex> cypher do
    ...>   merge node(:p, [:Player], %{nick: "like4boss"})
    ...>   merge node(:p2, [:Player], %{nick: "marioboss"})
    ...>   merge (node(:p) -- rel([:IN_LOBBY]) -> node(:p2))
    ...>   return p.name
    ...> end
    ~S|MERGE (p:Player {"nick":"like4boss"}) MERGE (p2:Player {"nick":"marioboss"}) MERGE (p)-[:IN_LOBBY]->(p2) RETURN p.name|

  ```

  """

  alias ExCypher.{Buffer, Statement}

  @supported_statements [:match, :create, :merge, :return, :where, :pipe_with, :order, :limit]

  @doc """
    Wraps contents of a Cypher query and returns the query string.
  """
  defmacro cypher(do: block) do
    quote do
      {:ok, var!(buffer, ExCypher)} = Buffer.new_query()

      unquote(Macro.prewalk(block, &parse/1))

      query = Buffer.generate_query(var!(buffer, ExCypher))
      Buffer.stop_buffer(var!(buffer, ExCypher))

      query
    end
  end

  @doc """
    Saves a query line into the query buffer (where the other query lines)
    are being kept isolated.

    Since those query lines break with elixir's language syntax, we cannot
    call `unquote` on them, thus making the macro approach necessary.

    Also, `buffer` pid is on another scope, and cannot be accessed directly
    by the `parse` function.
  """
  defmacro command(args) do
    quote do
      Buffer.put_buffer(var!(buffer, ExCypher), unquote(args))
    end
  end

  @doc """
    Parses each command-line from the `cypher` macro's block
  """
  def parse({command, _ctx, args}) when command in @supported_statements do
    params = Statement.parse(command, args)

    quote do
      command(unquote(params))
    end
  end

  def parse(stmt), do: stmt
end
