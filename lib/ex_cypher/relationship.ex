defmodule ExCypher.Relationship do
  @moduledoc """
  Mounts Cypher syntax-compliant relationships between nodes.
  """
  import ExCypher.Props, only: [stringify: 1]

  @typep assoc_direction :: :-- | :-> | :<-
  @typep node_or_relationship :: String.t()

  @doc """
  Builds Cypher relationship structure given a set of parameters

  ### Usage:

  * Building a relationship with params:
      iex> rel(%{year: 1980})
      "[{\"year\": 1980}]"

  * Building a named relationship:
      iex> rel(:r, %{year: 1980})
      "[r {\"year\": 1980}]"

  * Building a labeled relationship:
      iex> rel([:Rel], %{year: 1980})
      "[:Rel {\"year\": 1980}]"
  """

  @spec rel(props :: map()) :: String.t()
  def rel(props = %{}), do: rel("", [], props)

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
    ["[", name, labels, props, "]"]
    |> Enum.map(&stringify/1)
    |> Enum.join()
  end

  @doc """
    Builds associations between nodes and relationships
  """
  @spec assoc(
          direction :: assoc_direction,
          {from :: node_or_relationship, to :: node_or_relationship}
        ) :: String.t()
  def assoc(:--, {from, to}) do
    if any_rel?(from, to) do
      "#{from}-#{to}"
    else
      "#{from}--#{to}"
    end
  end

  def assoc(:->, {from, to}) do
    if any_rel?(from, to) do
      "#{from}->#{to}"
    else
      "#{from}-->#{to}"
    end
  end

  def assoc(:<-, {from, to}) do
    if any_rel?(from, to) do
      "#{from}<-#{to}"
    else
      "#{from}<--#{to}"
    end
  end

  defp any_rel?(from, to) do
    named_rel?(from) || named_rel?(to)
  end

  defp named_rel?(stmt) when is_list(stmt) do
    stmt |> Enum.join("") |> named_rel?()
  end

  defp named_rel?(stmt) do
    String.starts_with?(stmt, "[") || String.ends_with?(stmt, "]")
  end
end
