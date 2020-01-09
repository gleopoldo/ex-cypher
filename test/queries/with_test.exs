defmodule Queries.WithTest do
  use ExUnit.Case

  import ExCypher

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
          pipe_with(fragment("rand()"))
        end

      assert "MATCH (n) WITH rand()" = query
    end

    test "with more elements" do
      query =
        cypher do
          match(node(:n))
          pipe_with(fragment("rand()"), :n)
        end

      assert "MATCH (n) WITH rand(), n" = query
    end

    test "with aliasing" do
      query =
        cypher do
          match(node(:n))
          pipe_with({:n, as: :p})
        end

      assert "MATCH (n) WITH n AS p" = query
    end

    test "with mixed list of aliased and non-aliased variables" do
      query =
        cypher do
          match(node(:n), node(:c))
          pipe_with({:n, as: :p}, :c)
        end

      assert "MATCH (n), (c) WITH n AS p, c" = query
    end

    test "with mixed list of aliased variables and fragments" do
      query =
        cypher do
          match(node(:n))
          pipe_with({fragment("rand()"), as: :r}, :n)
        end

      assert "MATCH (n) WITH rand() AS r, n" = query
    end
  end
end
