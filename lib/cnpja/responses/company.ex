defmodule Cnpja.Company do
  @moduledoc "Empresa (raiz do CNPJ) com estabelecimentos, sócios e opções tributárias."

  @enforce_keys [:id, :name]
  defstruct [:id, :name, :equity, :nature, :size, :members, :offices, :simples, :simei]

  @type t :: %__MODULE__{
          id: String.t(),
          name: String.t(),
          equity: number() | nil,
          nature: Cnpja.Label.t() | nil,
          size: Cnpja.Label.t() | nil,
          members: [Cnpja.Member.t()],
          offices: [Cnpja.Office.t()],
          simples: Cnpja.SimplesOpt.t() | nil,
          simei: Cnpja.SimplesOpt.t() | nil
        }

  @spec from_map(map()) :: t()
  def from_map(map) do
    %__MODULE__{
      id: map["id"],
      name: map["name"],
      equity: map["equity"],
      nature: Cnpja.Label.from_map_nullable(map["nature"]),
      size: Cnpja.Label.from_map_nullable(map["size"]),
      members: Enum.map(map["members"] || [], &Cnpja.Member.from_map/1),
      offices: Enum.map(map["offices"] || [], &Cnpja.Office.from_map/1),
      simples: Cnpja.SimplesOpt.from_map_nullable(map["simples"]),
      simei: Cnpja.SimplesOpt.from_map_nullable(map["simei"])
    }
  end

  @spec from_map_nullable(map() | nil) :: t() | nil
  def from_map_nullable(nil), do: nil
  def from_map_nullable(map), do: from_map(map)
end
