defmodule ExCypher.ClauseTest do
  use ExUnit.Case

  alias ExCypher.Clause
  require ExCypher.Clause

  describe ".is_supported/1" do
    supported_terms = [:match, :create, :merge, :return, :where, :pipe_with, :order, :limit]

    for term <- supported_terms do
      test "returns true when command name equals to #{term}" do
        assert Clause.is_supported(unquote(term))
      end
    end

    test "returns false when command name is not supported" do
      refute Clause.is_supported(:non_supported)
    end
  end
end
