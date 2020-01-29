defmodule Integration.QueryingTest do
  use ExUnit.Case, async: false

  import ExCypher
  alias ExCypher.Support.Server

  setup_all do
    Server.start_link()
    :ok
  end

  describe "querying stuff in neo4j" do
    test "is able to fetch nodes using MATCH queries" do
      Server.transaction(fn conn ->
        Server.query(conn, """
          CREATE (:Person {name:"Bob"}), (:Person {name:"Ellie"}),
                 (:Person {name:"Mark"}), (:Person {name:"Jane"})
        """)

        query = cypher do
          match(node(:p, [:Person]))
          return p.name
          order {p.name, :asc}
        end

        assert %{records: [["Bob"], ["Ellie"], ["Jane"], ["Mark"]]} =
          Server.query(conn, query)
      end)
    end

    test "is able to filter nodes" do
      Server.transaction(fn conn ->
        Server.query(conn, """
          CREATE (:Person {name:"Bob", age:42}),
                 (:Person {name:"Peter", age:35}),
                 (:Person {name:"Lucy", age:35}),
                 (:Person {name:"Anne", age:18}),
                 (:Person {name:"Mary", age:25})
        """)

        query = cypher do
          match(node(:p, [:Person]))
          where p.age >= 25
          return p.name
          order {p.age, :asc}, {p.name, :asc}
          limit 3
        end

        assert %{records: [["Mary"], ["Lucy"], ["Peter"]]} =
          Server.query(conn, query)
      end)
    end

    test "is able to filter required nodes with different labels" do
      Server.transaction(fn conn ->
        Server.query(conn, """
          CREATE (:Droid {name:"R2-D2"}),
                 (:Droid {name:"C3PO"}),
                 (:Cyborg {name:"Arnold"})
        """)

        query = cypher do
          match(node(:d, [:Droid]))
          return d.name
          order {d.name, :asc}
        end

        assert %{records: [["C3PO"], ["R2-D2"]]} =
          Server.query(conn, query)
      end)
    end

    test "is able to match associations" do
      Server.transaction(fn conn ->
        Server.query(conn, """
          CREATE (acme:Company {name: "Acme"}),
                 (marvel:Company {name: "Marvel"}),
                 (martin:Person {name:"Martin"})-[:WORKS_IN]->(acme),
                 (anne:Person {name:"Anne"})-[:WORKS_IN]->(acme),
                 (hiro:Person {name:"Hiro"})-[:WORKS_IN]->(marvel),
                 (charles:Person {name:"Charles"})-[:WORKS_IN]->(acme)
        """)

        query = cypher do
          match (node(:person, [:Person]) -- rel([:WORKS_IN]) -> node([:Company], %{name: "Acme"}))
          return person.name
          order {person.name, :asc}
        end

        assert %{records: [["Anne"], ["Charles"], ["Martin"]]} =
          Server.query(conn, query)
      end)
    end

    test "is able to match associations and apply filters" do
      Server.transaction(fn conn ->
        Server.query(conn, """
          CREATE (acme:Company {name: "Acme"}),
                 (marvel:Company {name: "Marvel"}),
                 (justin:Person {name:"Justin"}),
                 (martin:Person {name:"Martin"})-[:WORKS_IN]->(acme),
                 (anne:Person {name:"Anne"})-[:WORKS_IN]->(acme),
                 (hiro:Person {name:"Hiro"})-[:WORKS_IN]->(marvel),
                 (charles:Person {name:"Charles"})-[:WORKS_IN]->(acme)
        """)

        query = cypher do
          match (node(:person, [:Person]) -- rel([:WORKS_IN]) -> node(:company, [:Company]))
          where company.name == "Acme"
          return person.name
          order {person.name, :asc}
        end

        assert %{records: [["Anne"], ["Charles"], ["Martin"]]} =
          Server.query(conn, query)
      end)
    end
  end
end
