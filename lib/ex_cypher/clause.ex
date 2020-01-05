defmodule ExCypher.Clause do
  @moduledoc """
  Abstraction on query clauses and their arguments
  """

  defstruct [:name, :env, :args]

  alias __MODULE__

  @type t() :: %__MODULE__{
          name: String.t(),
          args: [term()]
        }

  @supported_statements [:match, :create, :merge, :return, :where, :pipe_with, :order, :limit]

  defguard is_supported(command_name)
           when command_name in @supported_statements

  @spec new({name :: atom(), context :: list(), args :: term()},
            env :: Macro.Env.t()) :: Clause.t()
  def new(term, env \\ nil)

  def new({name, _ctx, args}, env) when is_supported(name),
    do: %Clause{name: name, env: env, args: args}

  def new(term, env), do: %Clause{name: nil, env: env, args: term}
end
