defmodule Queries.CreateTest do
  use ExUnit.Case

  import ExCypher

  describe "CREATE" do
    test "returns a create statement" do
      query =
        cypher do
          create(node([:Node], %{name: "prop"}))
        end

      assert ~S[CREATE (:Node {name:"prop"})] = query
    end

    test "accepts multiple elements" do
      query =
        cypher do
          create(node(:a), node(:b))
        end

      assert "CREATE (a), (b)" = query
    end

    test "accepts relationships" do
      query =
        cypher do
          create((node(:a) -- rel([:R]) -> node(:b)))
        end

      assert "CREATE (a)-[:R]->(b)" = query
    end
  end
end
