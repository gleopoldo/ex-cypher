defmodule ExCypher.Support.Server do
  @moduledoc false

  @server_url "bolt://neo4j"

  alias Bolt.Sips, as: Neo

  def start_link do
    {:ok, _pid} = Bolt.Sips.start_link(url: @server_url)
  end

  def transaction(function) do
    Neo.transaction(Neo.conn(), fn conn ->
      function.(conn)
      Neo.rollback(conn, :dont_persist)
    end)
  end

  def query(conn, query) do
    {:ok, response} = Neo.query(conn, query)
    response
  end
end
