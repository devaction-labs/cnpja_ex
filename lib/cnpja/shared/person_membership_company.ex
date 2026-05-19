defmodule Cnpja.PersonMembershipCompany do
  @moduledoc "Lightweight company reference inside a person membership record."

  @enforce_keys [:id, :name]
  defstruct [:id, :name, :equity, :nature, :size, :jurisdiction]

  @type t :: %__MODULE__{
          id: integer(),
          name: String.t(),
          equity: number() | nil,
          nature: Cnpja.Label.t() | nil,
          size: Cnpja.SizeLabel.t() | nil,
          jurisdiction: String.t() | nil
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
      jurisdiction: map["jurisdiction"]
    }
  end
end
