defmodule Cnpja.Activity do
  @moduledoc "Atividade econômica (CNAE)."

  @enforce_keys [:id, :text]
  defstruct [:id, :text]

  @type t :: %__MODULE__{id: integer(), text: String.t()}

  @spec from_map(map()) :: t()
  def from_map(map) do
    %__MODULE__{id: map["id"], text: map["text"]}
  end

  @spec from_map_nullable(map() | nil) :: t() | nil
  def from_map_nullable(nil), do: nil
  def from_map_nullable(map), do: from_map(map)
end
