defmodule MipsTest do
  use ExUnit.Case

  test "pseudo" do
    Mips.Resolvers.resolve_pseudo("add $0, $0, $1")
  end

  test "main" do
  #  Mips.start()
  end
end
