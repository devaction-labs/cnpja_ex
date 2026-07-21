defmodule Cnpja.Client do
  @moduledoc false

  @spec get(String.t(), keyword() | [{String.t(), term()}], keyword()) ::
          {:ok, map() | binary() | nil} | {:error, Cnpja.Error.t()}
  def get(path, query \\ [], opts \\ []) do
    request(:get, path, query: query, opts: opts)
  end

  @spec get_binary(String.t(), keyword() | [{String.t(), term()}], keyword()) ::
          {:ok, binary()} | {:error, Cnpja.Error.t()}
  def get_binary(path, query \\ [], opts \\ []) do
    request(:get, path, query: query, opts: opts, mode: :binary)
  end

  @spec post(String.t(), map(), keyword()) ::
          {:ok, map() | nil} | {:error, Cnpja.Error.t()}
  def post(path, body, opts \\ []) do
    request(:post, path, body: body, opts: opts)
  end

  @spec patch(String.t(), map(), keyword()) ::
          {:ok, map() | nil} | {:error, Cnpja.Error.t()}
  def patch(path, body, opts \\ []) do
    request(:patch, path, body: body, opts: opts)
  end

  @spec delete(String.t(), keyword()) :: :ok | {:error, Cnpja.Error.t()}
  def delete(path, opts \\ []) do
    case request(:delete, path, opts: opts) do
      {:ok, _} -> :ok
      {:error, _} = err -> err
    end
  end

  defp request(method, path, opts) do
    query = Keyword.get(opts, :query, [])
    body = Keyword.get(opts, :body)
    mode = Keyword.get(opts, :mode, :json)
    sdk_opts = Keyword.get(opts, :opts, [])

    api_key = Cnpja.Config.api_key(sdk_opts)
    base_url = Cnpja.Config.base_url(sdk_opts)
    receive_timeout = Cnpja.Config.receive_timeout(sdk_opts)

    req_opts =
      [
        method: method,
        base_url: base_url,
        url: path,
        headers: [{"Authorization", api_key}],
        params: normalize_params(query),
        receive_timeout: receive_timeout,
        retry: false
      ]
      |> maybe_json_body(body)
      |> maybe_raw(mode)

    case Req.request(req_opts) do
      {:ok, %{status: status}} when status in [204] ->
        {:ok, nil}

      {:ok, %{status: status, body: body}} when status in 200..299 ->
        {:ok, body}

      {:ok, %{status: status, body: body}} ->
        parsed = if is_map(body), do: body, else: parse_error_body(body)
        {:error, Cnpja.Error.from_response(status, parsed)}

      {:error, exception} ->
        {:error, %Cnpja.Error{status: 0, message: Exception.message(exception), raw: %{}}}
    end
  end

  defp normalize_params(query) do
    query
    |> Enum.reject(fn {_k, v} -> is_nil(v) end)
    |> Enum.map(fn {k, v} -> {k, normalize_value(v)} end)
  end

  defp normalize_value(v) when is_list(v), do: Enum.join(v, ",")
  defp normalize_value(v), do: v

  defp maybe_json_body(opts, nil), do: opts

  defp maybe_json_body(opts, body) when is_map(body) do
    opts
    |> Keyword.put(:json, body)
  end

  defp maybe_raw(opts, :binary), do: Keyword.put(opts, :decode_body, false)
  defp maybe_raw(opts, :json), do: opts

  defp parse_error_body(body) when is_binary(body) do
    case Jason.decode(body) do
      {:ok, map} -> map
      _ -> %{"message" => body}
    end
  end
end
