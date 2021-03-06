defmodule ExCypher.NodeTest do
  use ExUnit.Case

  import Kernel, except: [node: 0, node: 1]
  import ExCypher.Support.Utils, only: [eval: 1]
  import ExCypher.Graph.Node

  describe "node/0" do
    test "returns empty parenthesis" do
      assert "()" = eval(node())
    end
  end

  describe "node/1" do
    test "returns a node with it's name" do
      assert "(bob)" = eval(node(:bob))
    end

    test "returns a labeled node" do
      assert "(:Person)" = eval(node([:Person]))
    end

    test "returns a node with props" do
      assert ~S|({name:"mark"})| = eval(node(%{name: "mark"}))
    end

    test "does not convert integers to strings in props" do
      assert "({age:65})" = eval(node(%{age: 65}))
    end

    test "does not convert booleans to strings in props" do
      assert ~S|({married:true})| = eval(node(%{married: true}))
    end

    test "returns empty parenthesis when name is nil" do
      assert "()" = eval(node(nil))
    end

    test "returns empty parenthesis when labels are empty" do
      assert "()" = eval(node([]))
    end

    test "returns empty parenthesis when props are empty" do
      assert "()" = eval(node(%{}))
    end
  end

  describe "node/2" do
    test "returns a named and labeled node" do
      assert "(bob:Person)" = eval(node(:bob, [:Person]))
    end

    test "returns a labeled node with props" do
      assert "(:Person {name:\"billy\"})" = eval(node([:Person], %{name: "billy"}))
    end

    test "returns a named node with props" do
      assert "(p {name:\"billy\"})" = eval(node(:p, %{name: "billy"}))
    end

    test "omits the name when it's nil but have labels" do
      assert "(:Person)" = eval(node(nil, [:Person]))
    end

    test "omits the labels when it's empty but have a name" do
      assert "(p)" = eval(node(:p, []))
    end

    test "omits the props when it's empty but have a name" do
      assert "(p)" = eval(node(:p, %{}))
    end

    test "omits the props when it's empty but have a label" do
      assert "(:Person)" = eval(node([:Person], %{}))
    end
  end

  describe "node/3" do
    test "returns a complete node" do
      assert ~S|(p:Person {name:"ellie"})| = eval(node(:p, [:Person], %{name: "ellie"}))
    end

    test "returns a node with multiple props" do
      assert ~S|(p:Person {first_name:"jane",last_name:"doe"})| =
               eval(node(:p, [:Person], %{first_name: "jane", last_name: "doe"}))
    end
  end
end
