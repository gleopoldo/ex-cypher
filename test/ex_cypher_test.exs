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
