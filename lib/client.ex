defmodule ExConn.Client do
  defmacro __using__(_) do
    quote location: :keep do
      Module.register_attribute(__MODULE__, :endpoints, accumulate: true)

      import ExConn.Client,
        only: [
          url: 1,
          resolve_string: 1,
          resolve_map: 1,
          resolve_value: 1,
          endpoint: 2,
          headers: 1
        ]
    end
  end

  defmacro url(opts) do
    quote location: :keep, bind_quoted: [opts: opts] do
      Module.put_attribute(__MODULE__, :url, opts)

      def url, do: resolve_string(@url)
    end
  end

  defmacro headers(opts) do
    quote location: :keep, bind_quoted: [opts: opts] do
      Module.put_attribute(__MODULE__, :headers, opts)

      def headers, do: resolve_map(@headers)
    end
  end

  defmacro endpoint(name, method: method, path: path, params: params) do
    quote location: :keep,
          bind_quoted: [name: name, method: method, path: path, params: params] do
      Module.put_attribute(__MODULE__, :endpoints, {
        name,
        %ExConn.Endpoint{
          name: name,
          method: method,
          path: "#{resolve_string(@url)}#{path}",
          allowed_params: params
        }
      })

      def endpoints, do: Enum.reverse(@endpoints)
      def endpoint(name), do: @endpoints[name]

      def request(name, params) do
        ExConn.Endpoint.request(endpoint(name), params, resolve_map(@headers))
      end

      defoverridable endpoint: 1, endpoints: 0, request: 2
    end
  end

  def resolve_string(value) do
    value
    |> String.split("||")
    |> Enum.map(fn s -> String.trim(s) end)
    |> Enum.map(fn s -> resolve_value(s) end)
    |> Enum.find(fn s -> s end)
  end

  def resolve_value(var) do
    regex = ~r/(?<=ENV\[)[a-zA-Z_\]]*(?=\])/

    case Regex.run(regex, var) do
      nil -> var
      [] -> var
      [match] -> System.get_env(match)
    end
  end

  def resolve_map(map) do
    map |> Enum.map(fn {k, v} -> {k, resolve_string(v)} end) |> Map.new()
  end
end
