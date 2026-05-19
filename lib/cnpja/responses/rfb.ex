defmodule Cnpja.Rfb do
  @moduledoc "Establishment data sourced directly from the Receita Federal, including the membership board."

  @enforce_keys [:tax_id, :status, :address]
  defstruct [
    :tax_id,
    :name,
    :equity,
    :nature,
    :size,
    :jurisdiction,
    :alias,
    :founded,
    :head,
    :status_date,
    :status,
    :reason,
    :special_date,
    :special,
    :address,
    :phones,
    :emails,
    :registrations,
    :links,
    :company,
    :main_activity,
    :side_activities,
    :suframa,
    :updated,
    :members
  ]

  @type t :: %__MODULE__{
          tax_id: String.t(),
          name: String.t() | nil,
          equity: number() | nil,
          nature: Cnpja.Label.t() | nil,
          size: Cnpja.SizeLabel.t() | nil,
          jurisdiction: String.t() | nil,
          alias: String.t() | nil,
          founded: String.t() | nil,
          head: boolean() | nil,
          status_date: String.t() | nil,
          status: Cnpja.Label.t(),
          reason: Cnpja.Label.t() | nil,
          special_date: String.t() | nil,
          special: Cnpja.Label.t() | nil,
          address: Cnpja.Address.t(),
          phones: [Cnpja.Phone.t()],
          emails: [Cnpja.Email.t()],
          registrations: [Cnpja.StateRegistration.t()],
          links: Cnpja.OfficeLinks.t() | nil,
          company: Cnpja.CompanyRef.t() | nil,
          main_activity: Cnpja.Activity.t() | nil,
          side_activities: [Cnpja.Activity.t()],
          suframa: Cnpja.Suframa.t() | nil,
          updated: String.t() | nil,
          members: [Cnpja.Member.t()]
        }

  @doc false
  @spec from_map(map()) :: t()
  def from_map(map) do
    %__MODULE__{
      tax_id: map["taxId"],
      name: map["name"],
      equity: map["equity"],
      nature: Cnpja.Label.from_map_nullable(map["nature"]),
      size: Cnpja.SizeLabel.from_map_nullable(map["size"]),
      jurisdiction: map["jurisdiction"],
      alias: map["alias"],
      founded: map["founded"],
      head: map["head"],
      status_date: map["statusDate"],
      status: Cnpja.Label.from_map(map["status"]),
      reason: Cnpja.Label.from_map_nullable(map["reason"]),
      special_date: map["specialDate"],
      special: Cnpja.Label.from_map_nullable(map["special"]),
      address: Cnpja.Address.from_map(map["address"]),
      phones: Enum.map(map["phones"] || [], &Cnpja.Phone.from_map/1),
      emails: Enum.map(map["emails"] || [], &Cnpja.Email.from_map/1),
      registrations: Enum.map(map["registrations"] || [], &Cnpja.StateRegistration.from_map/1),
      links: Cnpja.OfficeLinks.from_map_nullable(map["links"]),
      company: Cnpja.CompanyRef.from_map_nullable(map["company"]),
      main_activity: Cnpja.Activity.from_map_nullable(map["mainActivity"]),
      side_activities: Enum.map(map["sideActivities"] || [], &Cnpja.Activity.from_map/1),
      suframa: Cnpja.Suframa.from_map_nullable(map["suframa"]),
      updated: map["updated"],
      members: Enum.map(map["members"] || [], &Cnpja.Member.from_map/1)
    }
  end
end
