defmodule ExConnTest do
  use ExUnit.Case
  doctest ExConn

  test "greets the world" do
    assert ExConn.hello() == :world
  end
end
