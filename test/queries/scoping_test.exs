defmodule Queries.ScopingTest do
  use ExUnit.Case

  import ExCypher

  describe "scopings" do
    test "can access an external variable content" do
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
