defmodule ExCypher.Relationship do
  @moduledoc """
  Builds relationships using cypher syntax
  """
  import ExCypher.Props, only: [stringify: 1]

  @typep assoc_direction :: :-- | :-> | :<-
  @typep node_or_relationship :: String.t()

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
  def rel(props = %{}), do: props |> stringify() |> to_rel()

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
    [name, labels, props]
    |> Enum.map(&stringify/1)
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
