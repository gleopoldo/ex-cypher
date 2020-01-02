defmodule ExCypher.Graph.Relationship do
  @moduledoc """
  Builds relationships using cypher syntax
  """
  import ExCypher.Graph.Props, only: [escape_relation: 3]

  @typep assoc_direction :: :-- | :-> | :<-
  @typep node_or_relationship ::
    {type :: :node | :relationship, node :: String.t()}

  @doc """
  Returns the Cypher's syntax for a relationship:

  ### Usage:

      iex> rel()
      "[]"

      iex> rel(%{year: 1980})
      "[{\"year\": 1980}]"

      iex> rel([:WORKS_IN])
      "[:WORKS_IN]"

      iex> rel(:r, %{year: 1980})
      "[r {\"year\": 1980}]"

      iex> rel([:Rel], %{year: 1980})
      "[:Rel {\"year\": 1980}]"

      iex> rel(:r, [:Rel], %{year: 1980})
      "[r:Rel {\"year\": 1980}]"
  """

  @spec rel() :: String.t()
  def rel, do: rel("")

  @spec rel(props :: map()) :: String.t()
  def rel(props = %{}), do: rel(nil, nil, props)

  @spec rel(labels :: list(), props :: map()) :: String.t()
  def rel(labels, props = %{})
      when is_list(labels),
      do: rel("", labels, props)

  @spec rel(
          name :: String.t(),
          labels :: list(),
          props :: map()
        ) :: String.t()
  def rel(name, labels \\ [], props \\ %{}) do
    escape_relation(name, labels, props)
    |> Enum.join()
    |> to_rel()
  end

  def to_rel(string) do
    "[" <> String.trim(string) <> "]"
  end

  @doc """
    Builds associations between nodes and relationships
  """
  @spec assoc(
          direction :: assoc_direction,
          {from :: node_or_relationship, to :: node_or_relationship}
        ) :: String.t()
  def assoc(assoc_type, {{from_type, from}, {to_type, to}}) do
    assoc_symbol = assoc_string(assoc_type, from_type, to_type)

    Enum.join([from, assoc_symbol, to], "")
  end

  defp any_rel?(from_type, to_type) do
    from_type == :relationship || to_type == :relationship
  end

  defp assoc_string(assoc_type, from_type, to_type) do
    case {assoc_type, any_rel?(from_type, to_type)} do
      {:--, false} -> "--"
      {:--, true} -> "-"
      {:<-, false} -> "<--"
      {:<-, true} -> "<-"
      {:->, false} -> "-->"
      {:->, true} -> "->"
    end
  end
end
