defmodule Cnpja.Zip do
  @moduledoc "Brazilian postal code (CEP) data."

  @enforce_keys [:code, :city, :state]
  defstruct [:updated, :municipality, :code, :street, :number, :district, :city, :state]

  @type t :: %__MODULE__{
          updated: String.t() | nil,
          municipality: integer() | nil,
          code: String.t(),
          street: String.t() | nil,
          number: String.t() | nil,
          district: String.t() | nil,
          city: String.t(),
          state: String.t()
        }

  @spec from_map(map()) :: t()
  def from_map(map) do
    %__MODULE__{
      updated: map["updated"],
      municipality: map["municipality"],
      code: map["code"],
      street: map["street"],
      number: map["number"],
      district: map["district"],
      city: map["city"],
      state: map["state"]
    }
  end
end
