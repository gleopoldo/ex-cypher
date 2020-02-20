defmodule Integration.CreatingNodesTest do
  use ExUnit.Case

  import ExCypher
  alias ExCypher.Support.Server

  setup do
    Server.start_link()
  end

  @moduletag integration: true

  describe "querying stuff in neo4j" do
    test "is able to insert new nodes with CREATE statements" do
      Server.transaction(fn conn ->
        query =
          cypher do
            create(node(:p, [:Person], %{name: "Anne"}))
            return(p.name)
            order({p.name, :asc})
          end

        assert %{records: [["Anne"]]} = Server.query(conn, query)
      end)
    end

    test "is able to insert multiple nodes" do
      Server.transaction(fn conn ->
        query =
          cypher do
            create(
              node([:Person], %{name: "Anne"}),
              node([:Person], %{name: "Bob"}),
              node([:Robot], %{name: "WALL-E"})
            )
          end

        assert %{
                 records: [],
                 stats: %{"nodes-created" => 3}
               } = Server.query(conn, query)
      end)
    end

    test "is able to build associations" do
      Server.transaction(fn conn ->
        query =
          cypher do
            create(
              node(:acme, [:Company], %{name: "Acme"}),
              node(:anne, [:Person], %{name: "Anne"}),
              node(:jack, [:Person], %{name: "Jack"})
            )
          end

        assert %{stats: %{"nodes-created" => 3}} = Server.query(conn, query)

        query =
          cypher do
            match(
              node(:company, [:Company], %{name: "Acme"}),
              node(:person, [:Person])
            )

            create((node(:person) -- rel([:WORKS_IN]) -> node(:company)))
            return(person.name)
            order({person.name, :asc})
          end

        assert %{
                 records: [["Anne"], ["Jack"]],
                 stats: %{"relationships-created" => 2}
               } = Server.query(conn, query)
      end)
    end

    test "is able to merge nodes and relationships" do
      Server.transaction(fn conn ->
        query =
          cypher do
            create(
              node(:acme, [:Company], %{name: "Acme"}),
              node(:anne, [:Person], %{name: "Anne"}),
              node(:jack, [:Person], %{name: "Jack"}),
              (node(:anne) -- rel([:WORKS_IN]) -> node(:acme))
            )
          end

        assert %{stats: %{"nodes-created" => 3}} = Server.query(conn, query)

        query =
          cypher do
            merge(node(:acme, [:Company], %{name: "Acme"}))
            merge(node(:anne, [:Person], %{name: "Anne"}))
            merge(node(:jack, [:Person], %{name: "Jack"}))
            merge(node(:bob, [:Person], %{name: "Bob"}))
            merge((node(:anne) -- rel([:WORKS_IN]) -> node(:acme)))
            merge((node(:jack) -- rel([:WORKS_IN]) -> node(:acme)))
            merge((node(:anne) -- rel([:WORKS_WITH]) -> node(:jack)))
          end

        assert %{stats: %{"nodes-created" => 1, "relationships-created" => 2}} =
                 Server.query(conn, query)
      end)
    end

    test "is able to create nodes with multiple labels" do
      Server.transaction(fn conn ->
        query =
          cypher do
            create(
              node(:person, [:Person, :Inventor, :Artist], %{name: "Leonardo da Vinci"})
            )
          end

        assert %{stats: %{"nodes-created" => 1}} = Server.query(conn, query)

        assert %{records: [["Leonardo da Vinci"]]} =
          Server.query(conn, cypher do
            match(node(:person, [:Inventor]))
            return person.name
          end)

        assert %{records: [["Leonardo da Vinci"]]} =
          Server.query(conn, cypher do
            match(node(:person, [:Person]))
            return person.name
          end)

        assert %{records: [["Leonardo da Vinci"]]} =
          Server.query(conn, cypher do
            match(node(:person, [:Artist, :Inventor]))
            return person.name
          end)
      end)
    end
  end
end
