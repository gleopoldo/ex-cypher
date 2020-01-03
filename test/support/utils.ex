defmodule ExCypher.Support.Utils do
  @moduledoc false

  def eval(content) do
    {evaluated, _context} = Code.eval_quoted(content)
    evaluated
  end
end
