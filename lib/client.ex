defmodule ExConn.Client do
  @url ""
  @headers %{}
  @endpoints []

  defmacro __using__(_) do
    quote do
      Module.register_attribute(__MODULE__, :endpoints, accumulate: true)

      import ExConn.Client,
        only: [
          url: 0,
          url: 1,
          headers: 0,
          headers: 1,
          endpoints: 0,
          endpoint: 1,
          endpoint: 2,
          request: 2
        ]
    end
  end

  @doc false
  defmacro url(opts) do
    quote bind_quoted: [opts: opts] do
      Module.put_attribute(__MODULE__, :url, opts)
    end
  end

  @doc false
  defmacro headers(opts) do
    quote bind_quoted: [opts: opts] do
      Module.put_attribute(__MODULE__, :headers, opts)
    end
  end

  @doc false
  defmacro endpoint(name, method: method, path: path, params: params) do
    quote bind_quoted: [name: name, method: method, path: path, params: params] do
      Module.put_attribute(__MODULE__, :endpoints, {
        name,
        %ExConn.Endpoint{
          name: name,
          method: method,
          path: "#{ExConn.Variable.resolve!(@url)}#{path}",
          allowed_params: params
        }
      })
    end
  end

  @spec url :: String.t()
  def url(), do: ExConn.Variable.resolve!(@url)

  @spec headers :: map
  def headers(), do: ExConn.Variable.resolve!(@headers)

  @spec endpoints :: list(%ExConn.Endpoint{})
  def endpoints(), do: Enum.reverse(@endpoints)

  @spec endpoint(atom) :: %ExConn.Endpoint{}
  def endpoint(name), do: @endpoints[name]

  @spec request(atom, map) :: {:err, String.t()} | {:ok, %ExConn.Request{}}
  def request(name, params) do
    ExConn.Endpoint.request(endpoint(name), params, ExConn.Variable.resolve!(@headers))
  end
end
