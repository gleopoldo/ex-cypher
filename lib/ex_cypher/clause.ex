defmodule ExCypher.Clause do
  @moduledoc """
  Abstraction on query clauses and their arguments
  """

  @supported_statements [:match, :create, :merge, :return, :where, :pipe_with, :order, :limit, :set]

  defguard is_supported(command_name)
           when command_name in @supported_statements
end
