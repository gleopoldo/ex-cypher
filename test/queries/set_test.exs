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
        set p.name = nil
        return p.name
      end

      expected = "MATCH (p:Person {name:\"Andy\"}) " <> \
                 "SET p.name = NULL " <> \
                 "RETURN p.name"

      assert ^expected = query
    end

    test "allows fragments inside queries" do
      query = cypher do
        match(node(:p, [:Person], %{name: "Andy"}))
        set p.age = fragment("toString(p.age)")
        return p.name
      end

      expected = "MATCH (p:Person {name:\"Andy\"}) " <> \
                 "SET p.age = toString(p.age) " <> \
                 "RETURN p.name"

      assert ^expected = query
    end

    test "allows copying attributes from other nodes" do
      query = cypher do
        match(node(:p1, [:Person], %{name: "Andy"}),
              node(:p2, [:Person], %{name: "Bob"}))
        set p1 = p2
        return p.name
      end

      expected = "MATCH (p1:Person {name:\"Andy\"}), (p2:Person {name:\"Bob\"}) " <> \
                 "SET p1 = p2 " <> \
                 "RETURN p.name"

      assert ^expected = query
    end

    test "allows using a map to set multiple properties at once" do
      query = cypher do
        match(node(:p, [:Person], %{name: "Andy"}))
        set p = %{name: "Bob", age: 35}
        return p.name
      end

      expected = "MATCH (p:Person {name:\"Andy\"}) " <> \
                 "SET p = {age:35,name:\"Bob\"} " <> \
                 "RETURN p.name"

      assert ^expected = query
    end

    test "allows removing all properties with an empty map" do
      query = cypher do
        match(node(:p, [:Person], %{name: "Andy"}))
        set p = %{}
        return p.name
      end

      expected = "MATCH (p:Person {name:\"Andy\"}) " <> \
                 "SET p = {} " <> \
                 "RETURN p.name"

      assert ^expected = query
    end

    test "allows multiple properties using a comma separator" do
      query = cypher do
        match(node(:p, [:Person], %{name: "Andy"}))
        set p.name = "bob", p.age = 23
        return p.name
      end

      expected = "MATCH (p:Person {name:\"Andy\"}) " <> \
                 "SET p.name = \"bob\", p.age = 23 " <> \
                 "RETURN p.name"

      assert ^expected = query
    end
  end
end
