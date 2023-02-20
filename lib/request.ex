defmodule ExConn.Request do
  defstruct [:method, :url, :body, :headers]

  def add_headers(request, headers) do
    %ExConn.Request{request | headers: Map.merge(request.headers || %{}, headers)}
  end

  def call(request) do
    HTTPoison.request(
      request.method,
      request.url,
      body: Poison.encode(request.body),
      headers: request.headers
    )
  end
end
