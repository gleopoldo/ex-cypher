defmodule ExCypher.Support.Server do
  @moduledoc false

  @server_url "bolt://#{System.get_env("NEO4J_HOST")}:#{System.get_env("NEO4J_PORT")}"

  alias Bolt.Sips, as: Neo

  def start_link do
    try do
      case Bolt.Sips.start_link(url: @server_url) do
        {:ok, _pid} -> :ok
        term -> term
      end
    catch
      # seems that we may fall into a race condition starting Bolt.Sips.Router
      # when adding this line to a setup_all in more than one test.
      :exit, {:noproc, _} -> __MODULE__.start_link()
      err -> err
    end
  end

  def query(query) when is_binary(query),
    do: query(Neo.conn(), query)

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
