defmodule ExCypher.ClauseTest do
  use ExUnit.Case

  alias ExCypher.Clause
  require ExCypher.Clause

  describe ".new/2" do
    test "builds a new clause with given args" do
      term = {:command_name, [], [arg1: 1, arg2: 2]}

      assert %Clause{name: nil, args: ^term} = Clause.new(term)
    end

    test "splits the command name when its supported by framework" do
      term = {name, _ctx, args} = {:match, [], [arg1: 1, arg2: 2]}

      assert %Clause{name: ^name, args: ^args} = Clause.new(term)
    end
  end

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
