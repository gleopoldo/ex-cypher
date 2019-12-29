defmodule Queries.WhereTest do
  use ExUnit.Case

  import ExCypher

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
end
