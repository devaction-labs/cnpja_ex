defmodule Cnpja.OfficeLinks do
  @moduledoc "Links to public documents of an establishment (certificates, map, street view)."

  defstruct [
    :rfb_certificate,
    :simples_certificate,
    :ccc_certificate,
    :suframa_certificate,
    :office_map,
    :office_street
  ]

  @type t :: %__MODULE__{
          rfb_certificate: String.t() | nil,
          simples_certificate: String.t() | nil,
          ccc_certificate: String.t() | nil,
          suframa_certificate: String.t() | nil,
          office_map: String.t() | nil,
          office_street: String.t() | nil
        }

  @spec from_map(map()) :: t()
  def from_map(map) do
    %__MODULE__{
      rfb_certificate: map["rfbCertificate"],
      simples_certificate: map["simplesCertificate"],
      ccc_certificate: map["cccCertificate"],
      suframa_certificate: map["suframaCertificate"],
      office_map: map["officeMap"],
      office_street: map["officeStreet"]
    }
  end

  @spec from_map_nullable(map() | nil) :: t() | nil
  def from_map_nullable(nil), do: nil
  def from_map_nullable(map), do: from_map(map)
end
