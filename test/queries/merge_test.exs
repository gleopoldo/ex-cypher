defmodule Queries.MergeTest do
  use ExUnit.Case

  import ExCypher

  describe "MERGE" do
    test "returns a MERGE statement" do
      query =
        cypher do
          merge(node([:Node], %{name: "prop"}))
        end

      assert ~S[MERGE (:Node {name:"prop"})] = query
    end

    test "accepts multiple elements" do
      query =
        cypher do
          merge(node(:a), node(:b))
        end

      assert "MERGE (a), (b)" = query
    end

    test "accepts relationships" do
      query =
        cypher do
          merge((node(:a) -- rel([:R]) -> node(:b)))
        end

      assert "MERGE (a)-[:R]->(b)" = query
    end
  end
end
