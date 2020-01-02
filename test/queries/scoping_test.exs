defmodule Queries.ScopingTest do
  use ExUnit.Case

  import ExCypher

  describe "scopings" do
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

    test "can access an external variable content in WHERE statements" do
      expected = ~S[MATCH (p:Person) WHERE p.name = "sarah" RETURN p]

      name = "sarah"

      query =
        cypher do
          match(node(:p, [:Person]))
          where(p.name = name)
          return(:p)
        end

      assert expected == query
    end
  end
end
