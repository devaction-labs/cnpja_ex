defmodule Cnpja.BypassHelpers do
  @moduledoc false

  import ExUnit.Callbacks, only: [setup: 1]

  defmacro __using__(_) do
    quote do
      import Cnpja.BypassHelpers

      setup do
        bypass = Bypass.open()
        Application.put_env(:cnpja_ex, :api_key, "test-key")
        {:ok, bypass: bypass}
      end
    end
  end

  def stub(bypass, method, path, status, body) do
    Bypass.expect_once(bypass, method, path, fn conn ->
      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.send_resp(status, Jason.encode!(body))
    end)
  end

  def stub_binary(bypass, method, path, status, binary) do
    Bypass.expect_once(bypass, method, path, fn conn ->
      conn
      |> Plug.Conn.put_resp_content_type("application/octet-stream")
      |> Plug.Conn.send_resp(status, binary)
    end)
  end

  def base_url(bypass), do: "http://localhost:#{bypass.port}"
end
