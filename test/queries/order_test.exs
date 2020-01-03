defmodule Queries.OrderTest do
  use ExUnit.Case

  import ExCypher

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
          order(n.name)
        end

      assert "MATCH (n) ORDER BY n.name" = query
    end

    test "with more elements" do
      query =
        cypher do
          match(node(:n))
          order(fragment("rand()"), :n)
        end

      assert "MATCH (n) ORDER BY rand(), n" = query
    end

    test "when ascending" do
      query =
        cypher do
          match(node(:n))
          order({:n, :asc})
        end

      assert "MATCH (n) ORDER BY n ASC" = query
    end

    test "when descending" do
      query =
        cypher do
          match(node(:n))
          order({:n, :desc})
        end

      assert "MATCH (n) ORDER BY n DESC" = query
    end
  end
end
