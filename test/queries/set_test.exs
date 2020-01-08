defmodule Queries.SetTest do
  use ExUnit.Case
  import ExCypher

  describe "SET" do
    test "allows updating a single property" do
      query = cypher do
        match(node(:p, [:Person], %{name: "Andy"}))
        set p.name = "Bob"
        return p.name
      end

      expected = "MATCH (p:Person {name:\"Andy\"}) " <> \
                 "SET p.name = \"Bob\" " <> \
                 "RETURN p.name"

      assert ^expected = query
    end

    test "allows updating a single property to NULL" do
      query = cypher do
        match(node(:p, [:Person], %{name: "Andy"}))
        set p = nil
        return p.name
      end

      expected = "MATCH (p:Person {name:\"Andy\"}) " <> \
                 "SET p = NULL " <> \
                 "RETURN p.name"

      assert ^expected = query
    end
  end
end
