defmodule ExCypher.Buffer do
  @moduledoc """
    In order to preserve the generated query without conflicts about
    where the code is being ran, this module implements a small buffer
    using an `Agent` that keeps a list of all statements that could
    be parsed.

    This way, every time one invokes the `cypher` macro, a new agent is
    started, and every line inside is parsed. Those commands that can
    be converted into a Cypher command are then parsed and pushed into
    the agent.

    At the end, the `ExCypher.Buffer.generate_query/1` function can be
    called and all lines are joined to build the correct query string.

    But remember that this module shouldn't be used directly by your
    code!
  """

  @spec put_buffer(buffer :: pid(), elements :: term()) ::
          :ok | {:error, term()}
  def put_buffer(buffer, elements) do
    Agent.update(buffer, &[elements | &1])
  end

  @spec generate_query(buffer :: pid()) :: String.t()
  def generate_query(buffer) do
    buffer
    |> Agent.get(fn query -> query end)
    |> Enum.reverse()
    |> Enum.join(" ")
  end

  @spec stop_buffer(buffer :: pid()) :: :ok | {:error, term()}
  def stop_buffer(buffer), do: Agent.stop(buffer)

  @spec new_query() :: {:ok, pid()} | {:error, term()}
  def new_query, do: Agent.start_link(fn -> [] end)
end
