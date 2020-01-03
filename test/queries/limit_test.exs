defmodule Queries.LimitTest do
  use ExUnit.Case
  import ExCypher

  describe "LIMIT" do
    test "adds a limit statement" do
      query =
        cypher do
          match(node([:Node]))
          limit(10)
        end

      assert "MATCH (:Node) LIMIT 10" = query
    end

    test "can use external variables in LIMIT statements" do
      per = 10
      expected = ~S[MATCH (p:Person) RETURN p LIMIT 10]

      query =
        cypher do
          match(node(:p, [:Person]))
          return(:p)
          limit(per)
        end

      assert expected == query
    end
  end
end
