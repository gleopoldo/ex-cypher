defmodule ExCypher.RelationshipTest do
  use ExUnit.Case

  import ExCypher.Graph.Relationship
  import ExCypher.Support.Utils, only: [eval: 1]

  describe "rel/0" do
    test "returns empty parenthesis" do
      assert "[]" = eval(rel())
    end
  end

  describe "rel/1" do
    test "returns a rel with it's name" do
      assert "[bob]" = eval(rel(:bob))
    end

    test "returns a labeled rel" do
      assert "[:Person]" = eval(rel([:Person]))
    end

    test "returns a rel with props" do
      assert ~S|[{name:"mark"}]| = eval(rel(%{name: "mark"}))
    end

    test "does not convert integers to strings in props" do
      assert ~S|[{age:65}]| = eval(rel(%{age: 65}))
    end

    test "does not convert booleans to strings in props" do
      assert ~S|[{married:true}]| = eval(rel(%{married: true}))
    end

    test "returns empty parenthesis when name is nil" do
      assert "[]" = eval(rel(nil))
    end

    test "returns empty parenthesis when labels are empty" do
      assert "[]" = eval(rel([]))
    end

    test "returns empty parenthesis when props are empty" do
      assert "[]" = eval(rel(%{}))
    end
  end

  describe "rel/2" do
    test "returns a named and labeled rel" do
      assert "[bob:Person]" = eval(rel(:bob, [:Person]))
    end

    test "returns a labeled rel with props" do
      assert "[:Person {name:\"billy\"}]" = eval(rel([:Person], %{name: "billy"}))
    end

    test "returns a named rel with props" do
      assert "[p {name:\"billy\"}]" = eval(rel(:p, %{name: "billy"}))
    end

    test "omits the name when it's nil but have labels" do
      assert "[:Person]" = eval(rel(nil, [:Person]))
    end

    test "omits the labels when it's empty but have a name" do
      assert "[p]" = eval(rel(:p, []))
    end

    test "omits the props when it's empty but have a name" do
      assert "[p]" = eval(rel(:p, %{}))
    end

    test "omits the props when it's empty but have a label" do
      assert "[:Person]" = eval(rel([:Person], %{}))
    end
  end

  describe "rel/3" do
    test "returns a complete rel" do
      assert ~S|[p:Person {name:"ellie"}]| = eval(rel(:p, [:Person], %{name: "ellie"}))
    end

    test "returns a rel with multiple props" do
      assert ~S|[p:Person {first_name:"jane",last_name:"doe"}]| =
               eval(rel(:p, [:Person], %{first_name: "jane", last_name: "doe"}))
    end
  end
end
