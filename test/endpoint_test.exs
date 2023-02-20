defmodule ExConn.EndpointTest do
  use ExUnit.Case

  test "invalid params" do
    endpoint = %ExConn.Endpoint{
      name: :dummy_1,
      method: :get,
      path: "my_url.com/endpoint_1",
      allowed_params: []
    }

    assert {:err, "Invalid parameters"} = ExConn.Endpoint.request(endpoint, %{id: 123}, %{})
  end

  test "no params" do
    endpoint = %ExConn.Endpoint{
      name: :dummy_1,
      method: :get,
      path: "my_url.com/endpoint_1",
      allowed_params: []
    }

    {:ok, request} =
      ExConn.Endpoint.request(endpoint, %{}, %{"auth" => "Auth", "header" => "Header"})

    assert %ExConn.Request{
             method: :get,
             url: "my_url.com/endpoint_1",
             body: %{},
             headers: %{"auth" => "Auth", "header" => "Header"}
           } == request
  end

  test "param replacement" do
    endpoint = %ExConn.Endpoint{
      name: :dummy_1,
      method: :get,
      path: "my_url.com/endpoint_1/%{id}",
      allowed_params: [:id]
    }

    {:ok, request} = ExConn.Endpoint.request(endpoint, %{id: 1234}, %{})

    assert request.url == "my_url.com/endpoint_1/1234"
  end

  test "query params" do
    endpoint = %ExConn.Endpoint{
      name: :dummy_1,
      method: :get,
      path: "my_url.com/endpoint_1/%{id}",
      allowed_params: [:id, :name, :surname]
    }

    {:ok, request} =
      ExConn.Endpoint.request(endpoint, %{id: 1234, name: "dylan", surname: "blakemore"}, %{})

    assert request.url == "my_url.com/endpoint_1/1234?name=dylan&surname=blakemore"
  end

  test "params in body" do
    endpoint = %ExConn.Endpoint{
      name: :dummy_1,
      method: :post,
      path: "my_url.com/endpoint_1/%{id}",
      allowed_params: [:id, :name, :surname]
    }

    {:ok, request} =
      ExConn.Endpoint.request(endpoint, %{id: 1234, name: "dylan", surname: "blakemore"}, %{})

    assert request.url == "my_url.com/endpoint_1/1234"
    assert request.body == %{surname: "blakemore", name: "dylan"}
  end
end
