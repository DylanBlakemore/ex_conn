defmodule ExConn.ClientTest do
  use ExUnit.Case

  defmodule MockClient do
    use ExConn.Client

    url("ENV[MOCK_CONNECTOR_URL] || default-mock-url.com")

    headers(%{
      "Content-Type" => "application/json",
      "API_KEY" => "ENV[MOCK_API_KEY] || default-api-key"
    })

    endpoint(
      :get_thing,
      method: :get,
      path: "/endpoint_1/%{id}",
      params: [
        :id
      ]
    )

    endpoint(
      :post_thing,
      method: :post,
      path: "/endpoint_1",
      params: [
        :id,
        :name
      ]
    )

    endpoint(
      :get_specific_thing,
      method: :get,
      path: "/endpoint_1/%{id}/specifics",
      params: [
        :id,
        :name
      ]
    )
  end

  test "headers" do
    assert MockClient.headers() == %{
             "Content-Type" => "application/json",
             "API_KEY" => "default-api-key"
           }
  end

  describe "url" do
    test "with an environment variable" do
      System.put_env("MOCK_CONNECTOR_URL", "mock-url.com")

      assert MockClient.url() == "mock-url.com"

      System.delete_env("MOCK_CONNECTOR_URL")
    end

    test "without an environment variable" do
      assert MockClient.url() == "default-mock-url.com"
    end
  end

  describe "headers" do
    test "with an environment variable" do
      System.put_env("MOCK_API_KEY", "mock-api-key")

      assert MockClient.headers() == %{
               "API_KEY" => "mock-api-key",
               "Content-Type" => "application/json"
             }

      System.delete_env("MOCK_API_KEY")
    end

    test "without an environment variable" do
      assert MockClient.headers() == %{
               "API_KEY" => "default-api-key",
               "Content-Type" => "application/json"
             }
    end
  end

  describe "endpoints" do
    test "specific endpoint" do
      assert %{
               name: :get_thing,
               method: :get,
               path: "default-mock-url.com/endpoint_1/%{id}",
               allowed_params: [
                 :id
               ]
             } = MockClient.endpoint(:get_thing)

      assert %{
               name: :post_thing,
               method: :post,
               path: "default-mock-url.com/endpoint_1",
               allowed_params: [
                 :id,
                 :name
               ]
             } = MockClient.endpoint(:post_thing)
    end

    test "all endpoints" do
      endpoints = MockClient.endpoints()

      assert %{
               name: :get_thing,
               method: :get,
               path: "default-mock-url.com/endpoint_1/%{id}",
               allowed_params: [
                 :id
               ]
             } = endpoints[:get_thing]

      assert %{
               name: :post_thing,
               method: :post,
               path: "default-mock-url.com/endpoint_1",
               allowed_params: [
                 :id,
                 :name
               ]
             } = endpoints[:post_thing]
    end
  end

  describe "request" do
    test "get with ID" do
      {:ok, request} = MockClient.request(:get_thing, %{id: 1234})

      assert request == %ExConn.Request{
               method: :get,
               url: "default-mock-url.com/endpoint_1/1234",
               body: %{},
               headers: %{"Content-Type" => "application/json", "API_KEY" => "default-api-key"}
             }
    end
  end
end
