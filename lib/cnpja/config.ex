defmodule Cnpja.Config do
  @moduledoc false

  @base_url "https://api.cnpja.com"
  @default_receive_timeout 30_000

  @spec api_key(keyword()) :: String.t()
  def api_key(opts) do
    opts[:api_key] || Application.fetch_env!(:cnpja_ex, :api_key)
  end

  @spec base_url(keyword()) :: String.t()
  def base_url(opts) do
    opts[:base_url] || @base_url
  end

  @spec receive_timeout(keyword()) :: pos_integer()
  def receive_timeout(opts) do
    opts[:receive_timeout] ||
      Application.get_env(:cnpja_ex, :receive_timeout, @default_receive_timeout)
  end
end
