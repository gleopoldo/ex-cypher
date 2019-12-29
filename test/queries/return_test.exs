defmodule Queries.ReturnTest do
  use ExUnit.Case

  import ExCypher

  describe "RETURN" do
    test "returns a single element" do
      assert "RETURN n" = cypher(do: return(:n))
    end

    test "returns multiple elements" do
      assert "RETURN m, n, o" = cypher(do: return(:m, :n, :o))
    end

    test "returns an element property" do
      assert "RETURN c.name" = cypher(do: return(c.name))
    end
  end
end
