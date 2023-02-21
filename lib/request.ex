defmodule ExConn.Request do
  defstruct [:method, :url, :body, :headers]

  @spec add_headers(%ExConn.Request{}, map) :: %ExConn.Request{}
  def add_headers(request, headers) do
    %ExConn.Request{request | headers: Map.merge(request.headers || %{}, headers)}
  end

  @spec call(%ExConn.Request{}) ::
          {:error, HTTPoison.Error.t()}
          | {:ok,
             HTTPoison.AsyncResponse.t() | HTTPoison.MaybeRedirect.t() | HTTPoison.Response.t()}
  def call(request) do
    HTTPoison.request(
      request.method,
      request.url,
      body: Poison.encode(request.body),
      headers: request.headers
    )
  end
end
