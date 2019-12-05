defmodule ExCypherTest do
  use ExUnit.Case
  doctest ExCypher

  test "greets the world" do
    assert ExCypher.hello() == :world
  end
end
