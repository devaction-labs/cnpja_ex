defmodule Cnpja.Client do
  @moduledoc false

  @spec get(String.t(), keyword(), keyword()) ::
          {:ok, map() | binary()} | {:error, Cnpja.Error.t()}
  def get(path, query \\ [], opts \\ []) do
    request(path, query, opts, :json)
  end

  @spec get_binary(String.t(), keyword(), keyword()) ::
          {:ok, binary()} | {:error, Cnpja.Error.t()}
  def get_binary(path, query \\ [], opts \\ []) do
    request(path, query, opts, :binary)
  end

  defp request(path, query, opts, mode) do
    api_key = Cnpja.Config.api_key(opts)
    base_url = Cnpja.Config.base_url(opts)

    req_opts =
      [
        base_url: base_url,
        url: path,
        headers: [{"Authorization", api_key}],
        params: Enum.reject(query, fn {_k, v} -> is_nil(v) end),
        retry: false
      ]
      |> maybe_raw(mode)

    case Req.get(req_opts) do
      {:ok, %{status: status, body: body}} when status in 200..299 ->
        {:ok, body}

      {:ok, %{status: status, body: body}} ->
        parsed = if is_map(body), do: body, else: parse_error_body(body)
        {:error, Cnpja.Error.from_response(status, parsed)}

      {:error, exception} ->
        {:error, %Cnpja.Error{status: 0, message: Exception.message(exception), raw: %{}}}
    end
  end

  defp maybe_raw(opts, :binary), do: Keyword.put(opts, :decode_body, false)
  defp maybe_raw(opts, :json), do: opts

  defp parse_error_body(body) when is_binary(body) do
    case Jason.decode(body) do
      {:ok, map} -> map
      _ -> %{"message" => body}
    end
  end

  defp parse_error_body(body), do: body
end
