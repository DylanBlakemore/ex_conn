defmodule ExConn.Variable do
  @spec resolve!(binary | list | map) :: any
  def resolve!(var) when is_map(var) do
    var
    |> Enum.map(fn {k, v} -> {k, resolve!(v)} end)
    |> Map.new()
  end

  def resolve!(var) when is_list(var) do
    var
    |> Enum.map(fn v -> resolve!(v) end)
  end

  def resolve!(var) when is_binary(var) do
    var
    |> String.split("||")
    |> Enum.map(fn s -> String.trim(s) end)
    |> Enum.map(fn s -> parse(s) end)
    |> Enum.find(fn s -> s end)
  end

  def resolve!(var), do: var

  defp parse(value) do
    regex = ~r/(?<=ENV\[)[a-zA-Z_\]]*(?=\])/

    case Regex.run(regex, value) do
      nil -> value
      [] -> value
      [match] -> System.get_env(match)
    end
  end
end
