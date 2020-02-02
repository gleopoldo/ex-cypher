defmodule ExCypher.Support.Server do
  @moduledoc false

  @server_url "http://#{System.get_env("NEO4J_HOST")}:#{System.get_env("NEO4J_PORT")}"

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
    with {:ok, response} <- Neo.query(conn, query) do
      response
    else
      {:error, reason} ->
        IO.inspect(reason)
        {:error, reason}
    end
  end
end
