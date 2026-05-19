defmodule Cnpja.Simples do
  @moduledoc "Simples Nacional and MEI enrollment data for a company."

  @enforce_keys [:tax_id]
  defstruct [:tax_id, :updated, :simples, :simei]

  @type t :: %__MODULE__{
          tax_id: String.t(),
          updated: String.t() | nil,
          simples: Cnpja.SimplesOpt.t() | nil,
          simei: Cnpja.SimplesOpt.t() | nil
        }

  @spec from_map(map()) :: t()
  def from_map(map) do
    %__MODULE__{
      tax_id: map["taxId"],
      updated: map["updated"],
      simples: Cnpja.SimplesOpt.from_map_nullable(map["simples"]),
      simei: Cnpja.SimplesOpt.from_map_nullable(map["simei"])
    }
  end
end
