defmodule ExCypher do
  @moduledoc """
  A DSL to build Cypher queries using elixir syntax

  Use a simple macro to build your queries without any kind of string
  interpolation.

  ### Example

  Import `ExCypher` into your module, as follows, and feel free to build
  your queries.

      iex> defmodule SomeQuery do
      ...>   import ExCypher
      ...>
      ...>   def get_all_spaceships do
      ...>     cypher do
      ...>       match node(:s, [:Spaceship])
      ...>       return :s
      ...>     end
      ...>   end
      ...> end
      ...> SomeQuery.get_all_spaceships
      "MATCH (s:Spaceship) RETURN s"

  This library only generates string queries. In order to execute them,
  please consider using `ex-cypher` along with
  [Bolt Sips](https://github.com/florinpatrascu/bolt_sips).

  ### Querying

  When querying nodes in your graph database, the most common command is `MATCH`.
  As you can see in the rest of this doc, the library kept the syntax the closest
  as possible from the cypher's one, making the learning curve much smaller.

  So, in order to query nodes, you can use the `match` function, along with
  `ExCypher.Graph.Node.node/0` function to represent your nodes:

      iex> cypher do: match(node(:n))
      "MATCH (n)"

      iex> cypher do: match(node(:p, [:Person]))
      "MATCH (p:Person)"

      iex> cypher do
      ...>   match(node(:p, [:Person], %{name: "bob"}))
      ...> end
      ~S[MATCH (p:Person {name:"bob"})]

  Note that you can combine the `ExCypher.Graph.Node.node/3` arguments in your
  wish, with the node name, labels and properties.

  Although having nodes in the database is essential, they alone won't make the
  database useful. We must have access to their relationships. Thus, you can use
  the `ExCypher.Graph.Relationship.rel/0` function to represent relationships
  between nodes.

  As is made by cypher, you can use an arrow syntax to visually identify
  the relationships direction, as you can see in there examples:

      iex> cypher do
      ...>   match node(:p, [:Person]) -- node(:c, [:Company])
      ...> end
      "MATCH (p:Person)--(c:Company)"

      iex> cypher do
      ...>   match node(:p, [:Person]) -- node(:c, [:Company]) -- node()
      ...> end
      "MATCH (p:Person)--(c:Company)--()"

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

  In the same way as nodes, `ExCypher.Graph.Relationship.rel/3` also allows you
  to specify the relationship's name, labels and properties in different ways.
  I strongly recommend you to take a look at these functions docummentations to
  get more working examples.

  ### Limiting, filtering and ordering results

  Matching entire databases is not cool... Cypher allows you to filter the
  returned nodes in several ways. Maybe the most trivial way to start with this
  would be to attempt to order or limit your queries using, respectively,
  `order` and `limit` functions:

      iex> cypher do
      ...>   match node(:s, [:Sharks])
      ...>   order s.name
      ...>   limit 10
      ...>   return s.name, s.population
      ...> end
      "MATCH (s:Sharks) ORDER BY s.name LIMIT 10 RETURN s.name, s.population"

  `ExCypher` allows you to sort the returned nodes by default in ascending order.
  If you like to have more control on this, use the following tuple syntax:

      iex> cypher do
      ...>   match node(:s, [:Sharks])
      ...>   order {s.name, :asc}, {s.age, :desc}
      ...>   return :s
      ...> end
      "MATCH (s:Sharks) ORDER BY s.name ASC, s.age DESC RETURN s"

  In addition to ordering and limiting the returned nodes, it's also essential
  to a query language to have filtering support. In this case, the `where`
  function allows you to specify conditions that must be satisfied by each
  returned node:

      iex> cypher do
      ...>   match node(:c, [:Creature])
      ...>   where c.type == "cursed" or c.poisonous == true and c.population > 1000
      ...>   return :c
      ...> end
      ~S|MATCH (c:Creature) WHERE c.type = "cursed" OR c.poisonous = true AND c.population > 1000 RETURN c|

  We currently have support to all comparison operators used in cypher. You
  can feel free to use `<`, `>`, `<=`, `>=`, `!=` and `==`.

  ### Creating

  Cypher allows the creation of nodes in a database via `CREATE` statement.
  You can generate those queries in the same way with `create` function:

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

  Note that `create` also accepts the arrow-based relationship building syntax.

  Another important tip: `create`, as is done in cypher, will always create a
  new node, even if that node already exists. If you want to provide a
  `CREATE UNIQUE` behavior, you must use `merge` instead:

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

  The `merge` command in cypher attempts to pattern match the provided graph in
  the database and, whenever this pattern is not matched, it'll insert the entire
  pattern in the database.

  ### WITH statement

  Cypher also allows a query piping behavior using `WITH` statements. However,
  `with` is one of the elixir's reserved keywords, and cannot be overridden,
  even using a macro.

  Thus, you must use `pipe_with` instead:

      iex> cypher do
      ...>   match node(:c, [:Wizard], %{speciality: "healing"})
      ...>   pipe_with {c.name, as: :name}, {c.age, as: :age}
      ...>   return :name, :age
      ...> end
      ~S|MATCH (c:Wizard {speciality:"healing"}) WITH c.name AS name, c.age AS age RETURN name, age|

  ### Updating nodes

  By default, we must rely on `set` function in order to update the nodes
  labels and relationships. Here are a few running examples that'll show you
  the `set` function syntax:

      iex> # Setting a single property to a node
      ...> cypher do
      ...>   match(node(:p, [:Person], %{name: "Andy"}))
      ...>   set(p.name = "Bob")
      ...>   return(p.name)
      ...> end
      ~S|MATCH (p:Person {name:"Andy"}) SET p.name = "Bob" RETURN p.name|

      iex> # Setting several properties to a node
      ...> cypher do
      ...>   match(node(:p, [:Person], %{name: "Andy"}))
      ...>   set(p.name = "Bob", p.age = 34)
      ...>   return(p.name)
      ...> end
      ~S|MATCH (p:Person {name:"Andy"}) SET p.name = "Bob", p.age = 34 RETURN p.name|

      iex> # Setting several properties to a node at once
      ...> cypher do
      ...>   match(node(:p, [:Person], %{name: "Andy"}))
      ...>   set(p = %{name: "Bob", age: 34})
      ...>   return(p.name)
      ...> end
      ~S|MATCH (p:Person {name:"Andy"}) SET p = {age:34,name:"Bob"} RETURN p.name|

  ### Removing properties

  You can remove some properties from a node setting them to NULL, or to an
  empty map:

      iex> # Removing a node property
      ...> cypher do
      ...>   match(node(:p, [:Person], %{name: "Andy"}))
      ...>   set(p.name = nil)
      ...>   return(p.name)
      ...> end
      ~S|MATCH (p:Person {name:"Andy"}) SET p.name = NULL RETURN p.name|

      iex> # Removing several properties from a node
      ...> cypher do
      ...>   match(node(:p, [:Person], %{name: "Andy"}))
      ...>   set(p.name = %{})
      ...>   return(p.name)
      ...> end
      ~S|MATCH (p:Person {name:"Andy"}) SET p.name = {} RETURN p.name|

  ### Upserting properties

  You can also upsert properties on a node. If they don't exist, it'll
  create them. If they exist, it won't. The syntax will look very familiar
  to what you may know from elixir:

      iex> cypher do
      ...>   match(node(:p, [:Person], %{name: "Andy"}))
      ...>   set(%{p | age: 40, role: "ship captain"})
      ...>   return(p.name)
      ...> end
      ~S|MATCH (p:Person {name:"Andy"}) SET p += {age:40,role:"ship captain"} RETURN p.name|

  ### Using raw cypher functions

  It's possible to use raw cypher functions in your queries too. Similarly to
  `Ecto` library, use the `fragment` function:

      iex> cypher do
      ...>   match node(:random_winner, [:Person])
      ...>   pipe_with {fragment("rand()"), as: :rand}, :random_winner
      ...>   return :random_winner
      ...>   limit 1
      ...>   order :rand
      ...> end
      ~S|MATCH (random_winner:Person) WITH rand() AS rand, random_winner RETURN random_winner LIMIT 1 ORDER BY rand|

  ## Caveats with complex relationships

  When building more complex associations, you must be aware about scopes and
  how they'll affect the query building process. Whenever you run this:

      iex> cypher do
      ...>   create node(:p, [:Player], %{name: "mario"}),
      ...>          node(:p2, [:Player], %{name: "luigi"})
      ...> end
      ~S|CREATE (p:Player {name:"mario"}), (p2:Player {name:"luigi"})|

  You're actually calling the `create` function along with two arguments.
  However, when building more complex associations, operator precedence may
  break the query building process. The following, for example, won't work.

  ```
    cypher do
      create node(:p, [:Player], %{name: "mario"}),
             node(:p2, [:Player], %{name: "luigi"}),
             node(:p) -- rel([:IS_FRIEND]) -> node(:p2)
    end
  ```

  This will result in a compilation error. Instead, let's take care about
  the operator precedence here and wrap the entire association in parenthesis,
  creating a new scope. Then we can take advantages of the full power of
  macro in favor of us:

      iex>  cypher do
      ...>    create node(:p, [:Player], %{name: "mario"}),
      ...>           node(:p2, [:Player], %{name: "luigi"}),
      ...>           (node(:p) -- rel([:IS_FRIEND]) -> node(:p2))
      ...>  end
      ~S|CREATE (p:Player {name:"mario"}), (p2:Player {name:"luigi"}), (p)-[:IS_FRIEND]->(p2)|

  """

  alias ExCypher.{Buffer, Statement}
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
      {command, _ctx, args} when is_supported(command) ->
        params = Statement.parse(command, args, env)
        Buffer.put_buffer(pid, params)

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
end
