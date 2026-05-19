defmodule Cnpja.Person do
  @moduledoc "Individual or legal entity with their company memberships."

  @enforce_keys [:id, :name, :type]
  defstruct [:id, :type, :name, :tax_id, :age, :country, :membership]

  @type t :: %__MODULE__{
          id: String.t(),
          type: String.t(),
          name: String.t(),
          tax_id: String.t() | nil,
          age: String.t() | nil,
          country: Cnpja.Country.t() | nil,
          membership: [Cnpja.PersonMembership.t()]
        }

  @doc false
  @spec from_map(map()) :: t()
  def from_map(map) do
    %__MODULE__{
      id: map["id"],
      type: map["type"],
      name: map["name"],
      tax_id: map["taxId"],
      age: map["age"],
      country: Cnpja.Country.from_map_nullable(map["country"]),
      membership: Enum.map(map["membership"] || [], &Cnpja.PersonMembership.from_map/1)
    }
  end
end
