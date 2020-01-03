defmodule ExCypher.Clause do
  @moduledoc """
  Abstraction on query clauses and their arguments
  """

  defstruct [:name, :args]

  alias __MODULE__

  @type t() :: %__MODULE__{
          name: String.t(),
          args: [term()]
        }

  @supported_statements [:match, :create, :merge, :return, :where, :pipe_with, :order, :limit]

  defguard is_supported(command_name)
           when command_name in @supported_statements

  @spec new({name :: atom(), context :: list(), args :: term()}) :: Clause.t()
  def new({name, _ctx, args}) when is_supported(name),
      do: %Clause{name: name, args: args}

  def new(term), do: %Clause{name: nil, args: term}
end
