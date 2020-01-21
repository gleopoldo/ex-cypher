defmodule Integration.Querying do
  use ExUnit.Case, async: false

  import ExCypher
  alias ExCypher.Support.Server

  setup do
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
  end
end
