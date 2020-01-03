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

  describe "MERGE node properties with external variables" do
    test "with strings" do
      ip = "127.0.0.1"
      expected = ~s[MERGE (:Host {ip:"#{ip}"})]

      query =
        cypher do
          merge(node([:Host], %{ip: ip}))
        end

      assert expected == query
    end

    test "with integers" do
      mem_size = 4096
      expected = ~s[MERGE (:Host {mem_size:4096})]

      query =
        cypher do
          merge(node([:Host], %{mem_size: mem_size}))
        end

      assert expected == query
    end

    test "with booleans" do
      active = true
      expected = ~s[MERGE (:Host {active:true})]

      query =
        cypher do
          merge(node([:Host], %{active: active}))
        end

      assert expected == query
    end
  end

  describe "MERGE relationship with external variables" do
    test "with strings" do
      role = "developer"
      expected = ~s[MERGE (:Person)-[:WORKS_IN {role:"#{role}"}\]-()]

      query =
        cypher do
          merge(node([:Person]) -- rel([:WORKS_IN], %{role: role}) -- node())
        end

      assert expected == query
    end

    test "with integers" do
      since = 2004
      expected = ~s[MERGE (:Person)-[:WORKS_IN {since:#{since}}\]-()]

      query =
        cypher do
          merge(node([:Person]) -- rel([:WORKS_IN], %{since: since}) -- node())
        end

      assert expected == query
    end

    test "with booleans" do
      current_job = false
      expected = ~s[MERGE (:Person)-[:WORKS_IN {current_job:#{current_job}}\]-()]

      query =
        cypher do
          merge(node([:Person]) -- rel([:WORKS_IN], %{current_job: current_job}) -- node())
        end

      assert expected == query
    end
  end
end
