defmodule Cnpja.Rfb do
  @moduledoc "Dados de estabelecimento diretamente da Receita Federal, incluindo quadro societário."

  @enforce_keys [:tax_id, :status, :address]
  defstruct [
    :tax_id,
    :alias,
    :founded,
    :head,
    :status,
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
          alias: String.t() | nil,
          founded: String.t() | nil,
          head: boolean() | nil,
          status: Cnpja.Label.t(),
          address: Cnpja.Address.t(),
          phones: [Cnpja.Phone.t()],
          emails: [Cnpja.Email.t()],
          registrations: [Cnpja.StateRegistration.t()],
          links: Cnpja.OfficeLinks.t() | nil,
          company: Cnpja.Company.t() | nil,
          main_activity: Cnpja.Activity.t() | nil,
          side_activities: [Cnpja.Activity.t()],
          suframa: Cnpja.Suframa.t() | nil,
          updated: String.t() | nil,
          members: [Cnpja.Member.t()]
        }

  @spec from_map(map()) :: t()
  def from_map(map) do
    %__MODULE__{
      tax_id: map["taxId"],
      alias: map["alias"],
      founded: map["founded"],
      head: map["head"],
      status: Cnpja.Label.from_map(map["status"]),
      address: Cnpja.Address.from_map(map["address"]),
      phones: Enum.map(map["phones"] || [], &Cnpja.Phone.from_map/1),
      emails: Enum.map(map["emails"] || [], &Cnpja.Email.from_map/1),
      registrations: Enum.map(map["registrations"] || [], &Cnpja.StateRegistration.from_map/1),
      links: Cnpja.OfficeLinks.from_map_nullable(map["links"]),
      company: Cnpja.Company.from_map_nullable(map["company"]),
      main_activity: Cnpja.Activity.from_map_nullable(map["mainActivity"]),
      side_activities: Enum.map(map["sideActivities"] || [], &Cnpja.Activity.from_map/1),
      suframa: Cnpja.Suframa.from_map_nullable(map["suframa"]),
      updated: map["updated"],
      members: Enum.map(map["members"] || [], &Cnpja.Member.from_map/1)
    }
  end
end
