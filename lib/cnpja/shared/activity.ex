defmodule Cnpja.Activity do
  @moduledoc "Economic activity (CNAE code)."

  @enforce_keys [:id, :text]
  defstruct [:id, :text, :performed]

  @type t :: %__MODULE__{id: integer(), text: String.t(), performed: boolean() | nil}

  @doc false
  @spec from_map(map()) :: t()
  def from_map(map) do
    %__MODULE__{id: map["id"], text: map["text"], performed: map["performed"]}
  end

  @doc false
  @spec from_map_nullable(map() | nil) :: t() | nil
  def from_map_nullable(nil), do: nil
  def from_map_nullable(map), do: from_map(map)
end
