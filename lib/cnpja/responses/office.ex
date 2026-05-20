defmodule Cnpja.Office do
  @moduledoc "Establishment identified by a full 14-digit CNPJ."

  @enforce_keys [:tax_id, :status, :address]
  defstruct [
    :tax_id,
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
    :updated
  ]

  @type t :: %__MODULE__{
          tax_id: String.t(),
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
          links: [Cnpja.Link.t()],
          company: Cnpja.CompanyRef.t() | nil,
          main_activity: Cnpja.Activity.t() | nil,
          side_activities: [Cnpja.Activity.t()],
          suframa: [Cnpja.Suframa.t()],
          updated: String.t() | nil
        }

  @doc false
  @spec from_map(map()) :: t()
  def from_map(map) do
    %__MODULE__{
      tax_id: map["taxId"],
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
      links: Enum.map(map["links"] || [], &Cnpja.Link.from_map/1),
      company: Cnpja.CompanyRef.from_map_nullable(map["company"]),
      main_activity: Cnpja.Activity.from_map_nullable(map["mainActivity"]),
      side_activities: Enum.map(map["sideActivities"] || [], &Cnpja.Activity.from_map/1),
      suframa: Enum.map(map["suframa"] || [], &Cnpja.Suframa.from_map/1),
      updated: map["updated"]
    }
  end

  @doc false
  @spec from_map_nullable(map() | nil) :: t() | nil
  def from_map_nullable(nil), do: nil
  def from_map_nullable(map), do: from_map(map)
end
