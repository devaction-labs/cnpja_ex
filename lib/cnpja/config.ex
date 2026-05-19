defmodule Cnpja.Config do
  @moduledoc "Leitura da configuração do SDK."

  @base_url "https://api.cnpja.com"

  @spec api_key(keyword()) :: String.t()
  def api_key(opts) do
    opts[:api_key] || Application.fetch_env!(:cnpja_ex, :api_key)
  end

  @spec base_url(keyword()) :: String.t()
  def base_url(opts) do
    opts[:base_url] || @base_url
  end
end
