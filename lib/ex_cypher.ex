defmodule ExCypher do
  @moduledoc """
  A DSL to make it easy to integrate other apps to Neo4J applications.

  This module provide a clean API to build queries using CYPHER query language,
  which is largely used by Neo4j

  ## Usage:

  First of all, add `import ExCpyher` to the top of your module, so that
  `ExCypher.cypher/0` macro is available to your functions.

  After that, you can use cypher-friendly functions to build your queries:

      iex> cypher do: match(node(:n))
      "MATCH (n)"

      iex> cypher do: match(node(:p, [:Person]))
      "MATCH (p:Person)"

      iex> cypher do
      ...>   match(node(:p, [:Person], %{name: "bob"}))
      ...> end
      ~S[MATCH (p:Person {name:"bob"})]

  Also we support a familiar syntax to build nodes associations, by using either
  `:--`, `:->` or `:<-` to denote the nodes associations, as follows:

      iex> cypher do
      ...>   match node(:p, [:Person]) -- node(:c, [:Company])
      ...> end
      "MATCH (p:Person)--(c:Company)"

      iex> cypher do
      ...>   match node(:p, [:Person]) -- rel(:WORKS_IN) -- node(:c, [:Company])
      ...>   return :p
      ...> end
      "MATCH (p:Person)-[WORKS_IN]-(c:Company) RETURN p"

      iex> cypher do
      ...>   match (node(:p, [:Person]) -- rel(:WORKS_IN) -> node(:c, [:Company]))
      ...> end
      "MATCH (p:Person)-[WORKS_IN]->(c:Company)"

      iex> cypher do
      ...>   match (node(:c, [:Company]) <- rel(:WORKS_IN) -- node(:p, [:Person]))
      ...> end
      "MATCH (c:Company)<-[WORKS_IN]-(p:Person)"

  See `ExCypher.Node.node/0` and `ExCypher.Relationship.rel/0` for more
  information on how to build your nodes and relationships.

  If you need to order your returned nodes, you can use both `order` and `limit`:

      iex> cypher do
      ...>   match node(:s, [:Sharks])
      ...>   order s.name
      ...>   limit 10
      ...>   return s.name, s.population
      ...> end
      "MATCH (s:Sharks) ORDER BY s.name LIMIT 10 RETURN s.name, s.population"

  Also, you can choose the ordering direction of your matched nodes with a
  tuple syntax:

      iex> cypher do
      ...>   match node(:s, [:Sharks])
      ...>   order {s.name, :asc}, {s.age, :desc}
      ...>   return :s
      ...> end
      "MATCH (s:Sharks) ORDER BY s.name ASC, s.age DESC RETURN s"

  There're also support for `create` and `merge` statements from cypher
  language:

      iex> cypher do
      ...>   create node(:p, [:Player], %{nick: "like4boss", score: 100})
      ...>   return p.name
      ...> end
      ~S[CREATE (p:Player {nick:"like4boss",score:100}) RETURN p.name]

      iex> cypher do
      ...>   create (node(:c, [:Country], %{name: "Brazil"}) -- rel([:HAS_CITY]) -> node([:City], %{name: "São Paulo"}))
      ...>   return :c
      ...> end
      ~S|CREATE (c:Country {name:"Brazil"})-[:HAS_CITY]->(:City {name:"São Paulo"}) RETURN c|

      iex> cypher do
      ...>   merge node(:p, [:Player], %{nick: "like4boss"})
      ...>   merge node(:p2, [:Player], %{nick: "marioboss"})
      ...>   return p.name
      ...> end
      ~S|MERGE (p:Player {nick:"like4boss"}) MERGE (p2:Player {nick:"marioboss"}) RETURN p.name|

      iex> cypher do
      ...>   merge node(:p, [:Player], %{nick: "like4boss"})
      ...>   merge node(:p2, [:Player], %{nick: "marioboss"})
      ...>   merge (node(:p) -- rel([:IN_LOBBY]) -> node(:p2))
      ...>   return p.name
      ...> end
      ~S|MERGE (p:Player {nick:"like4boss"}) MERGE (p2:Player {nick:"marioboss"}) MERGE (p)-[:IN_LOBBY]->(p2) RETURN p.name|

  ## Caveats with complex relationships

  Each of the presented elements above are independent functions that work
  together to build complex cypher queries under the hood. When building complex
  association between nodes and relationships, you must be aware that in some
  cases you may end fighting agaisnt elixir compiler when using the `:->`
  operator, which is reserved to functions and pattern matching.

  This can be solved with a simple caveat specifying a little better the scope
  of your association. Before diving into this, consider this example:

      iex> cypher do
      ...>   create node(:p, [:Player], %{name: "mario"}),
      ...>          node(:p2, [:Player], %{name: "luigi"})
      ...> end
      ~S|CREATE (p:Player {name:"mario"}), (p2:Player {name:"luigi"})|

  Each node defined in this query act as an argument to a bigger function.
  If you want to use an association in this query, you may try the following:

  ```
    cypher do
      create node(:p, [:Player], %{name: "mario"}),
             node(:p2, [:Player], %{name: "luigi"}),
             node(:p) -- rel([:IS_FRIEND]) -> node(:p2)
    end
  ```

  But this will result in a compilation error. Instead, let's take care about
  the operator precedence here and wrap the entire association in parenthesis,
  this way resolving any conflict made by the compiler:

      iex>  cypher do
      ...>    create node(:p, [:Player], %{name: "mario"}),
      ...>           node(:p2, [:Player], %{name: "luigi"}),
      ...>           (node(:p) -- rel([:IS_FRIEND]) -> node(:p2))
      ...>  end
      ~S|CREATE (p:Player {name:"mario"}), (p2:Player {name:"luigi"}), (p)-[:IS_FRIEND]->(p2)|

  """

  alias ExCypher.{Buffer, Clause, Statement}
  import ExCypher.Clause, only: [is_supported: 1]

  @doc """
    Wraps contents of a Cypher query and returns the query string.
  """
  defmacro cypher(do: block) do
    cypher_query(block, __CALLER__)
  end

  defp cypher_query(block, env) do
    {:ok, pid} = Buffer.new_query()

    Macro.postwalk(block, fn
      term = {command, _ctx, _args} when is_supported(command) ->
        parse_term(pid, term, env)

      term ->
        term
    end)

    query = Buffer.generate_query(pid)

    Buffer.stop_buffer(pid)

    quote do
      unquote(query)
      |> Enum.reverse()
      |> List.flatten()
      |> Enum.join(" ")
      |> String.replace(" , ", ", ")
    end
  end

  defp parse_term(pid, term, env) do
    params =
      term
      |> Clause.new(env)
      |> Statement.parse()

    Buffer.put_buffer(pid, params)
  end
end
