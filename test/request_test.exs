defmodule ExConn.RequestTest do
  use ExUnit.Case

  test "add headers when headers is nil" do
    request = %ExConn.Request{}
    new_request = request |> ExConn.Request.add_headers(%{name: "dylan"})

    assert %{name: "dylan"} == new_request.headers
  end

  test "add headers when headers are present" do
    request = %ExConn.Request{headers: %{name: "dylan"}}
    new_request = request |> ExConn.Request.add_headers(%{surname: "blakemore"})

    assert %{name: "dylan", surname: "blakemore"} == new_request.headers
  end
end
