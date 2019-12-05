defmodule ExCypherTest do
  use ExUnit.Case
  doctest ExCypher

  import ExCypher

  describe "match queries" do
    test "builds a simple match query" do
      expected = ~S[MATCH (n:Node) RETURN n]

      query = cypher do
        match node(:n, [:Node])
        return :n
      end

      assert expected == query
    end
  end
end
