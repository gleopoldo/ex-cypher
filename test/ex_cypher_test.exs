defmodule ExCypherTest do
  use ExUnit.Case
  doctest ExCypher

  import ExCypher

  describe "MATCH single nodes" do
    test "with an empty node" do
      assert "MATCH ()" = cypher(do: match(node()))
    end

    test "with only a name" do
      assert "MATCH (node)" = cypher(do: match(node(:node)))
    end

    test "with a name and a single label" do
      query =
        cypher do
          match(node(:n, [:Node]))
        end

      assert "MATCH (n:Node)" = query
    end

    test "with only labels" do
      query =
        cypher do
          match(node([:Node]))
        end

      assert "MATCH (:Node)" = query
    end

    test "with only labels and props" do
      query =
        cypher do
          match(node([:Node], %{name: "foo"}))
        end

      assert ~S[MATCH (:Node {"name":"foo"})] = query
    end

    test "with a name and a multiple labels" do
      query =
        cypher do
          match(node(:bob, [:Person, :Employee]))
        end

      assert "MATCH (bob:Person,Employee)" = query
    end

    test "with a name and one prop" do
      query =
        cypher do
          match(node(:bob, [], %{name: "Bob"}))
        end

      assert ~S[MATCH (bob {"name":"Bob"})] == query
    end

    test "with a name and lots of props" do
      query =
        cypher do
          match(node(:rick, [], %{name: "Rick", role: "scientist"}))
        end

      assert ~S[MATCH (rick {"name":"Rick","role":"scientist"})] == query
    end

    test "with only props" do
      query =
        cypher do
          match(node(%{name: "Rick", role: "scientist"}))
        end

      assert ~S[MATCH ({"name":"Rick","role":"scientist"})] == query
    end
  end

  describe "MATCH nodes and relationships" do
    test "with an undirected relationship" do
      expected = ~S[MATCH (n:Node)--(b:Node)]

      query =
        cypher do
          match(node(:n, [:Node]) -- node(:b, [:Node]))
        end

      assert expected == query
    end

    test "accepts a directed relationship pointing forward" do
      expected = ~S[MATCH (n:Node)-->(b:Node)]

      query =
        cypher do
          match((node(:n, [:Node]) -> node(:b, [:Node])))
        end

      assert expected == query
    end

    test "accepts a directed relationship pointing backward" do
      expected = ~S[MATCH (n:Node)<--(b:Node)]

      query =
        cypher do
          match(node(:n, [:Node]) <- node(:b, [:Node]))
        end

      assert expected == query
    end

    test "accepts complex relationships" do
      expected = ~S[MATCH (n:Node)<--()-->(b:Node)]

      query =
        cypher do
          match((node(:n, [:Node]) <- node() -> node(:b, [:Node])))
        end

      assert expected == query
    end
  end

  describe "MATCH multiple elements" do
    test "correctly matches on multiple elements" do
      expected = ~S[MATCH (a:Node), (b:Node)]

      query =
        cypher do
          match(
            node(:a, [:Node]),
            node(:b, [:Node])
          )
        end

      assert expected == query
    end

    test "correctly associates multiple matches and relationships" do
      expected = ~S[MATCH (a:Node), (c:Node), (c)<--(a)-->(b:Node)]

      query =
        cypher do
          match(
            node(:a, [:Node]),
            node(:c, [:Node]),
            (node(:c) <- node(:a) -> node(:b, [:Node]))
          )
        end

      assert expected == query
    end
  end

  describe "MATCH relationships with props" do
    test "accepts named relationships" do
      expected = ~S[MATCH (a)-[r\]-(b)]

      query =
        cypher do
          match(node(:a) -- rel(:r) -- node(:b))
        end

      assert expected == query
    end

    test "accepts labeled relationships" do
      expected = ~S[MATCH (a)-[:Rel\]-(b)]

      query =
        cypher do
          match(node(:a) -- rel([:Rel]) -- node(:b))
        end

      assert expected == query
    end

    test "accepts backwards named relationships" do
      expected = ~S[MATCH (a)<-[:Rel\]-(b)]

      query =
        cypher do
          match(node(:a) <- rel([:Rel]) -- node(:b))
        end

      assert expected == query
    end

    test "accepts towards named relationships" do
      expected = ~S[MATCH (a)-[:Rel\]->(b)]

      query =
        cypher do
          match((node(:a) -- rel([:Rel]) -> node(:b)))
        end

      assert expected == query
    end

    test "accepts properties in relationships" do
      expected = ~S[MATCH (a)-[:Rel {"name":"foo"}\]->(b)]

      query =
        cypher do
          match((node(:a) -- rel([:Rel], %{name: "foo"}) -> node(:b)))
        end

      assert expected == query
    end

    test "accepts properties in named and labeled relationships" do
      expected = ~S[MATCH (a)-[r:Rel {"name":"foo"}\]->(b)]

      query =
        cypher do
          match((node(:a) -- rel(:r, [:Rel], %{name: "foo"}) -> node(:b)))
        end

      assert expected == query
    end
  end

  describe "RETURN" do
    test "returns a single element" do
      assert "RETURN n" = cypher(do: return(:n))
    end

    test "returns multiple elements" do
      assert "RETURN m, n, o" = cypher(do: return(:m, :n, :o))
    end

    test "returns an element property" do
      assert "RETURN c.name" = cypher(do: return("c.name"))
    end
  end

  describe "WITH statements" do
    test "returns a single element" do
      query =
        cypher do
          match(node(:n))
          pipe_with(:n)
        end

      assert "MATCH (n) WITH n" = query
    end

    test "with custom functions" do
      query =
        cypher do
          match(node(:n))
          pipe_with("rand()")
        end

      assert "MATCH (n) WITH rand()" = query
    end

    test "with more elements" do
      query =
        cypher do
          match(node(:n))
          pipe_with("rand()", "n")
        end

      assert "MATCH (n) WITH rand(), n" = query
    end
  end

  describe "ORDER statements" do
    test "returns a single element" do
      query =
        cypher do
          match(node(:n))
          order(:n)
        end

      assert "MATCH (n) ORDER BY n" = query
    end

    test "with custom functions" do
      query =
        cypher do
          match(node(:n))
          order("n.name")
        end

      assert "MATCH (n) ORDER BY n.name" = query
    end

    test "with more elements" do
      query =
        cypher do
          match(node(:n))
          order("rand()", "n")
        end

      assert "MATCH (n) ORDER BY rand(), n" = query
    end

    test "when ascending" do
      query =
        cypher do
          match(node(:n))
          order({"n", :asc})
        end

      assert "MATCH (n) ORDER BY n ASC" = query
    end

    test "when descending" do
      query =
        cypher do
          match(node(:n))
          order({"n", :desc})
        end

      assert "MATCH (n) ORDER BY n DESC" = query
    end
  end

  describe "LIMIT" do
    test "adds a limit statement" do
      query =
        cypher do
          match(node([:Node]))
          limit(10)
        end

      assert "MATCH (:Node) LIMIT 10" = query
    end
  end

  describe "CREATE" do
    test "returns a create statement" do
      query =
        cypher do
          create(node([:Node], %{name: "prop"}))
        end

      assert ~S[CREATE (:Node {"name":"prop"})] = query
    end

    test "accepts multiple elements" do
      query =
        cypher do
          create(node(:a), node(:b))
        end

      assert "CREATE (a), (b)" = query
    end

    test "accepts relationships" do
      query =
        cypher do
          create((node(:a) -- rel([:R]) -> node(:b)))
        end

      assert "CREATE (a)-[:R]->(b)" = query
    end
  end

  describe "MERGE" do
    test "returns a MERGE statement" do
      query =
        cypher do
          merge(node([:Node], %{name: "prop"}))
        end

      assert ~S[MERGE (:Node {"name":"prop"})] = query
    end

    test "accepts multiple elements" do
      query =
        cypher do
          merge(node(:a), node(:b))
        end

      assert "MERGE (a), (b)" = query
    end

    test "accepts relationships" do
      query =
        cypher do
          merge((node(:a) -- rel([:R]) -> node(:b)))
        end

      assert "MERGE (a)-[:R]->(b)" = query
    end
  end

  describe "WHERE clauses" do
    test "returns correct query when matching for equality" do
      query =
        cypher do
          match(node(:a, [:Node]))
          where(a.name = "bob")
        end

      assert "MATCH (a:Node) WHERE a.name = \"bob\"" = query
    end

    test "accepts conditions merged by an AND operator" do
      query =
        cypher do
          match(node(:a, [:Node]))
          where(a.name = "bob" and a.age = 10)
        end

      assert "MATCH (a:Node) WHERE a.name = \"bob\" AND a.age = 10" = query
    end

    test "accepts conditions merged by an OR operator" do
      query =
        cypher do
          match(node(:a, [:Node]))
          where(a.name = "bob" or a.age = 10)
        end

      assert "MATCH (a:Node) WHERE a.name = \"bob\" OR a.age = 10" = query
    end
  end

  describe "queries with multiple statements" do
    test "builds a simple match query" do
      expected = ~S[MATCH (n:Node) RETURN n]

      query =
        cypher do
          match(node(:n, [:Node]))
          return(:n)
        end

      assert expected == query
    end
  end
end
