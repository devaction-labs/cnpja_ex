defmodule Cnpja.Ccc do
  @moduledoc "Dados do Cadastro Centralizado de Contribuintes (CCC) de um estabelecimento."

  @enforce_keys [:tax_id]
  defstruct [:tax_id, :updated, :name, :origin_state, :registrations]

  @type t :: %__MODULE__{
          tax_id: String.t(),
          updated: String.t() | nil,
          name: String.t() | nil,
          origin_state: String.t() | nil,
          registrations: [Cnpja.StateRegistration.t()]
        }

  @spec from_map(map()) :: t()
  def from_map(map) do
    %__MODULE__{
      tax_id: map["taxId"],
      updated: map["updated"],
      name: map["name"],
      origin_state: map["originState"],
      registrations: Enum.map(map["registrations"] || [], &Cnpja.StateRegistration.from_map/1)
    }
  end
end
