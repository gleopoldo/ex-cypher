defmodule Queries.WhereTest do
  use ExUnit.Case

  import ExCypher

  describe "WHERE clauses" do
    test "returns correct query when matching for equality" do
      query =
        cypher do
          match(node(:a, [:Node]))
          where(a.name == "bob")
        end

      assert "MATCH (a:Node) WHERE a.name = \"bob\"" = query
    end

    test "accepts conditions merged by an AND operator" do
      query =
        cypher do
          match(node(:a, [:Node]))
          where(a.name == "bob" and a.age == 10)
        end

      assert "MATCH (a:Node) WHERE a.name = \"bob\" AND a.age = 10" = query
    end

    test "accepts conditions merged by an OR operator" do
      query =
        cypher do
          match(node(:a, [:Node]))
          where(a.name == "bob" or a.age == 10)
        end

      assert "MATCH (a:Node) WHERE a.name = \"bob\" OR a.age = 10" = query
    end
  end

  describe "WHERE statements with external variables" do
    test "can use binaries and strings in matches" do
      expected = ~S[MATCH (p:Person) WHERE p.name = "sarah" RETURN p]

      name = "sarah"

      query =
        cypher do
          match(node(:p, [:Person]))
          where(p.name == name)
          return(:p)
        end

      assert expected == query
    end

    test "can use integers in matches" do
      expected = ~S[MATCH (p:Person) WHERE p.age = 34 RETURN p]

      age = 34

      query =
        cypher do
          match(node(:p, [:Person]))
          where(p.age == age)
          return(:p)
        end

      assert expected == query
    end

    test "can use booleans in matches" do
      expected = ~S[MATCH (p:Person) WHERE p.dev = true RETURN p]

      is_dev = true

      query =
        cypher do
          match(node(:p, [:Person]))
          where(p.dev == is_dev)
          return(:p)
        end

      assert expected == query
    end
  end
end
