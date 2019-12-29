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
  end
end
