defmodule Cnpja.Country do
  @moduledoc "País conforme tabela M49."

  @enforce_keys [:id, :name]
  defstruct [:id, :name]

  @type t :: %__MODULE__{id: integer(), name: String.t()}

  @spec from_map(map()) :: t()
  def from_map(map) do
    %__MODULE__{id: map["id"], name: map["name"]}
  end

  @spec from_map_nullable(map() | nil) :: t() | nil
  def from_map_nullable(nil), do: nil
  def from_map_nullable(map), do: from_map(map)
end
