defmodule Cnpja.CompanyRef do
  @moduledoc "Lightweight company reference embedded inside an establishment — excludes the offices list to avoid circular data."

  @enforce_keys [:id, :name]
  defstruct [:id, :name, :equity, :nature, :size, :jurisdiction, :members, :simples, :simei]

  @type t :: %__MODULE__{
          id: String.t(),
          name: String.t(),
          equity: number() | nil,
          nature: Cnpja.Label.t() | nil,
          size: Cnpja.SizeLabel.t() | nil,
          jurisdiction: String.t() | nil,
          members: [Cnpja.Member.t()],
          simples: Cnpja.SimplesOpt.t() | nil,
          simei: Cnpja.SimplesOpt.t() | nil
        }

  @doc false
  @spec from_map(map()) :: t()
  def from_map(map) do
    %__MODULE__{
      id: map["id"],
      name: map["name"],
      equity: map["equity"],
      nature: Cnpja.Label.from_map_nullable(map["nature"]),
      size: Cnpja.SizeLabel.from_map_nullable(map["size"]),
      jurisdiction: map["jurisdiction"],
      members: Enum.map(map["members"] || [], &Cnpja.Member.from_map/1),
      simples: Cnpja.SimplesOpt.from_map_nullable(map["simples"]),
      simei: Cnpja.SimplesOpt.from_map_nullable(map["simei"])
    }
  end

  @doc false
  @spec from_map_nullable(map() | nil) :: t() | nil
  def from_map_nullable(nil), do: nil
  def from_map_nullable(map), do: from_map(map)
end
