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

  describe "CREATE node properties with external variables" do
    test "with strings" do
      ip = "127.0.0.1"
      expected = ~s[CREATE (:Host {ip:"#{ip}"})]

      query =
        cypher do
          create(node([:Host], %{ip: ip}))
        end

      assert expected == query
    end

    test "with integers" do
      mem_size = 4096
      expected = ~s[CREATE (:Host {mem_size:4096})]

      query =
        cypher do
          create(node([:Host], %{mem_size: mem_size}))
        end

      assert expected == query
    end

    test "with booleans" do
      active = true
      expected = ~s[CREATE (:Host {active:true})]

      query =
        cypher do
          create(node([:Host], %{active: active}))
        end

      assert expected == query
    end
  end

  describe "CREATE relationship with external variables" do
    test "with strings" do
      role = "developer"
      expected = ~s[CREATE (:Person)-[:WORKS_IN {role:"#{role}"}\]-()]

      query =
        cypher do
          create(node([:Person]) -- rel([:WORKS_IN], %{role: role}) -- node())
        end

      assert expected == query
    end

    test "with integers" do
      since = 2004
      expected = ~s[CREATE (:Person)-[:WORKS_IN {since:#{since}}\]-()]

      query =
        cypher do
          create(node([:Person]) -- rel([:WORKS_IN], %{since: since}) -- node())
        end

      assert expected == query
    end

    test "with booleans" do
      current_job = false
      expected = ~s[CREATE (:Person)-[:WORKS_IN {current_job:#{current_job}}\]-()]

      query =
        cypher do
          create(node([:Person]) -- rel([:WORKS_IN], %{current_job: current_job}) -- node())
        end

      assert expected == query
    end

    test "with maps" do
      person = %{name: "bob", age: 12}
      expected = ~s[CREATE (:Person {age:#{person.age},name:\"#{person.name}\"})]

      query =
        cypher do
          create(node([:Person], %{name: person.name, age: person.age}))
        end

      assert expected == query
    end
  end
end
