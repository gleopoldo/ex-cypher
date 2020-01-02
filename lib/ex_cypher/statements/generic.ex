defmodule ExCypher.Statements.Generic do
  @moduledoc false

  # This module will provide the most generic AST conversion
  # functions that'll be shared between different commands.

  # Of course, such abstraction won't be possible to match
  # all kinds of statements, because some cypher commands
  # like the `WHERE` statement, have a unique syntax that is
  # very different from simpler ones, like the `RETURN`
  # statement.

  # The intent, in this way, is to combine functions in a
  # specialization way. Outer modules attempt to filter and
  # process their specific syntaxes and, whenever they can't,
  # use this module as a last attempt to convert those AST
  # nodes.

  # This way the core logic, which can include the caveat arround
  # elixir's function identification on unknown names, for example,
  # can be shared with other modules

  alias ExCypher.{Node, Relationship}

  @spec parse(ast :: term()) :: String.t()

  # Removing parenthesis from statements that elixir
  # attempts to resolve a name as a function.
  def parse({{:., _, [first, last | []]}, _, _}) do
    {term, _, _} = first
    "#{Atom.to_string(term)}.#{parse(last)}"
  end

  # Injects raw cypher functions
  def parse({:fragment, _ctx, args}) do
    args
    |> Enum.map(&parse/1)
    |> Enum.map(&String.replace(&1, "\"", ""))
    |> Enum.join(", ")
  end

  def parse({:node, _ctx, args}) do
    args =
      args
      |> Enum.map(fn
        {:%{}, _ctx, args} -> Enum.into(args, %{})
        term -> term
      end)

    apply(Node, :node, args)
  end

  def parse({:rel, _ctx, args}) do
    args =
      args
      |> Enum.map(fn
        {:%{}, _ctx, args} -> Enum.into(args, %{})
        term -> term
      end)

    apply(Relationship, :rel, args)
  end

  def parse({association, _ctx, [from, to]})
      when association in [:--, :->, :<-] do

    from = parse(from)
    to = parse(to)

    apply(Relationship, :assoc, [association, {from, to}])
  end

  def parse(term) when is_atom(term),
    do: Atom.to_string(term)

  def parse(list) when is_list(list) do
    list
    |> Enum.map(&parse/1)
    |> Enum.intersperse(",")
  end

  def parse(term = {var_name, _ctx, nil}) when is_atom(var_name) do
    quote bind_quoted: [term: term] do
      case term do
        term when is_binary(term) -> "\"#{term}\""
        term -> term
      end
    end
  end

  def parse(term), do: term |> Macro.to_string()
end
