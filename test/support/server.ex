defmodule ExCypher.Support.Server do
  @moduledoc false

  @server_url "bolt://#{System.get_env("NEO4J_HOST")}:#{System.get_env("NEO4J_PORT")}"

  alias Bolt.Sips, as: Neo

  def start_link do
    {:ok, _} = Application.ensure_all_started(:bolt_sips, :permanent)

    case Bolt.Sips.start_link(url: @server_url) do
      {:ok, _pid} -> :ok
      #{:error, {:reason, :already_started}} -> :ok
      term -> term
    end
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
