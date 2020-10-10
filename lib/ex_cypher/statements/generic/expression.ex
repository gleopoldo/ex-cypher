defmodule ExCypher.Statements.Generic.Expression do
  defstruct [:type, :env, :args]

  def new(ast, env) do
    cond do
      fragment?(ast) ->
        {_command, _, args} = ast
        %__MODULE__{type: :fragment, args: args, env: env}

      property?(ast) ->
        {{_, _, [first, last | []]}, _, _} = ast
        %__MODULE__{type: :property, args: [first, last], env: env}

      node?(ast) ->
        {_command, _, args} = ast
        %__MODULE__{type: :node, args: args, env: env}

      relationship?(ast) ->
        {_command, _, args} = ast
        %__MODULE__{type: :relationship, args: args, env: env}


      true ->
        %__MODULE__{args: nil, env: env}
    end
  end

    # args
  def fragment?({:fragment, _ctx, _args}), do: true
  def fragment?(_), do: false

    # args, get first and last term. must have only two
  def property?({{:., _, [_first, _last | []]}, _, _}), do: true
  def property?(_), do: false

    # args
  def node?({:node, _ctx, args}), do: true
  def node?(_), do: false

    # args
    def relationship?({:rel, _ctx, args}), do: true
    def relationship?(_), do: false

    # args, get first and last term. must have only two
    @associations [:--, :->, :<-]
    def association?({assoc, _ctx, args}) when assoc in @associations,
    do: true
    def association?(_), do: false
end
