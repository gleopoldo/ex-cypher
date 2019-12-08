defmodule ExCypher.Relationship do
  import ExCypher.Statement, only: [stringify: 1]

  def rel(name, props \\ %{}) do
    ["[:", name, props, "]"]
    |> Enum.map(&stringify/1)
    |> Enum.join()
  end

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
