defmodule Cnpja.Address do
  @moduledoc "Physical address of an establishment."

  @enforce_keys [:city, :state, :zip]
  defstruct [
    :municipality,
    :street,
    :number,
    :district,
    :details,
    :city,
    :state,
    :zip,
    :latitude,
    :longitude,
    :country
  ]

  @type t :: %__MODULE__{
          municipality: integer() | nil,
          street: String.t() | nil,
          number: String.t() | nil,
          district: String.t() | nil,
          details: String.t() | nil,
          city: String.t(),
          state: String.t(),
          zip: String.t(),
          latitude: float() | nil,
          longitude: float() | nil,
          country: Cnpja.Country.t() | nil
        }

  @spec from_map(map()) :: t()
  def from_map(map) do
    %__MODULE__{
      municipality: map["municipality"],
      street: map["street"],
      number: map["number"],
      district: map["district"],
      details: map["details"],
      city: map["city"],
      state: map["state"],
      zip: map["zip"],
      latitude: map["latitude"],
      longitude: map["longitude"],
      country: Cnpja.Country.from_map_nullable(map["country"])
    }
  end

  @spec from_map_nullable(map() | nil) :: t() | nil
  def from_map_nullable(nil), do: nil
  def from_map_nullable(map), do: from_map(map)
end
