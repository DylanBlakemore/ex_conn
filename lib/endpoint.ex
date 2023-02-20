defmodule ExConn.Endpoint do
  defstruct [:name, :method, :path, :allowed_params]

  @placeholder ~r/%{[a-z|_]+}/
  @param_key ~r/[a-z|_]+/

  @type request_result :: {:err, String.t()} | {:ok, %ExConn.Request{}}

  @spec request(%ExConn.Endpoint{}, map(), map()) :: request_result()
  def request(endpoint, params, headers) do
    case validate_params(endpoint.allowed_params, params) do
      :ok ->
        {:ok, encode_request(endpoint.method, endpoint.path, params, headers)}

      :err ->
        {:err, "Invalid parameters"}
    end
  end

  defp encode_request(method, url, params, headers) do
    parameters = split_params(url, params)

    %ExConn.Request{
      method: method,
      url: encode_url(method, url, parameters),
      body: elem(parameters, 1),
      headers: headers
    }
  end

  defp encode_url(:get, url, {url_params, query_params}) do
    url |> encode_url_params(url_params) |> insert_query_params(query_params)
  end

  defp encode_url(_, url, {url_params, _}) do
    url |> encode_url_params(url_params)
  end

  defp encode_url_params(url, params) do
    params |> Map.to_list() |> Enum.reduce(url, insert_param())
  end

  defp insert_query_params(url, params) when params == %{}, do: url

  defp insert_query_params(url, params) do
    url
    |> URI.new!()
    |> URI.append_query(URI.encode_query(params))
    |> URI.to_string()
  end

  defp split_params(url, params) do
    url_keys =
      Regex.scan(@placeholder, url)
      |> List.flatten()
      |> Enum.map(fn placeholder -> Regex.run(@param_key, placeholder) end)
      |> List.flatten()
      |> Enum.map(fn placeholder -> String.to_atom(placeholder) end)

    Map.split(params, url_keys)
  end

  defp insert_param do
    fn {key, value}, url -> String.replace(url, "%{#{key}}", "#{value}") end
  end

  defp validate_params(allowed_params, params) do
    valid_params?(Enum.all?(params, fn {param, _} -> param in allowed_params end))
  end

  defp valid_params?(true), do: :ok
  defp valid_params?(false), do: :err
end
