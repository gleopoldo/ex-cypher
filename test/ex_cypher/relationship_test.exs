defmodule ExCypher.RelationshipTest do
  use ExUnit.Case

  import ExCypher.Relationship

  describe "rel/0" do
    test "returns empty parenthesis" do
      assert "[]" = rel()
    end
  end

  describe "rel/1" do
    test "returns a rel with it's name" do
      assert "[bob]" = rel(:bob)
    end

    test "returns a labeled rel" do
      assert "[:Person]" = rel([:Person])
    end

    test "returns a rel with props" do
      assert ~S|[{name:"mark"}]| = rel(%{name: "mark"})
    end

    test "does not convert integers to strings in props" do
      assert ~S|[{age:65}]| = rel(%{age: 65})
    end

    test "does not convert booleans to strings in props" do
      assert ~S|[{married:true}]| = rel(%{married: true})
    end

    test "returns empty parenthesis when name is nil" do
      assert "[]" = rel(nil)
    end

    test "returns empty parenthesis when labels are empty" do
      assert "[]" = rel([])
    end

    test "returns empty parenthesis when props are empty" do
      assert "[]" = rel(%{})
    end
  end

  describe "rel/2" do
    test "returns a named and labeled rel" do
      assert "[bob:Person]" = rel(:bob, [:Person])
    end

    test "returns a labeled rel with props" do
      assert "[:Person {name:\"billy\"}]" = rel([:Person], %{name: "billy"})
    end

    test "returns a named rel with props" do
      assert "[p {name:\"billy\"}]" = rel(:p, %{name: "billy"})
    end

    test "omits the name when it's nil but have labels" do
      assert "[:Person]" = rel(nil, [:Person])
    end

    test "omits the labels when it's empty but have a name" do
      assert "[p]" = rel(:p, [])
    end

    test "omits the props when it's empty but have a name" do
      assert "[p]" = rel(:p, %{})
    end

    test "omits the props when it's empty but have a label" do
      assert "[:Person]" = rel([:Person], %{})
    end
  end

  describe "rel/3" do
    test "returns a complete rel" do
      assert ~S|[p:Person {name:"ellie"}]| = rel(:p, [:Person], %{name: "ellie"})
    end

    test "returns a rel with multiple props" do
      assert ~S|[p:Person {first_name:"jane",last_name:"doe"}]| =
               rel(:p, [:Person], %{first_name: "jane", last_name: "doe"})
    end
  end
end
