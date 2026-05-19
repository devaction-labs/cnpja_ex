defmodule Cnpja.Suframa do
  @moduledoc "SUFRAMA enrollment data for an establishment."

  @enforce_keys [:tax_id]
  defstruct [
    :tax_id,
    :number,
    :name,
    :since,
    :head,
    :approved,
    :approval_date,
    :updated,
    :status,
    :nature,
    :address,
    :main_activity,
    :side_activities,
    :phones,
    :emails,
    :incentives
  ]

  @type t :: %__MODULE__{
          tax_id: String.t(),
          number: String.t() | nil,
          name: String.t() | nil,
          since: String.t() | nil,
          head: boolean() | nil,
          approved: boolean() | nil,
          approval_date: String.t() | nil,
          updated: String.t() | nil,
          status: Cnpja.Label.t() | nil,
          nature: Cnpja.Label.t() | nil,
          address: Cnpja.Address.t() | nil,
          main_activity: Cnpja.Activity.t() | nil,
          side_activities: [Cnpja.Activity.t()],
          phones: [Cnpja.Phone.t()],
          emails: [Cnpja.Email.t()],
          incentives: [Cnpja.SuframaIncentive.t()]
        }

  @doc false
  @spec from_map(map()) :: t()
  def from_map(map) do
    %__MODULE__{
      tax_id: map["taxId"],
      number: map["number"],
      name: map["name"],
      since: map["since"],
      head: map["head"],
      approved: map["approved"],
      approval_date: map["approvalDate"],
      updated: map["updated"],
      status: Cnpja.Label.from_map_nullable(map["status"]),
      nature: Cnpja.Label.from_map_nullable(map["nature"]),
      address: Cnpja.Address.from_map_nullable(map["address"]),
      main_activity: Cnpja.Activity.from_map_nullable(map["mainActivity"]),
      side_activities: Enum.map(map["sideActivities"] || [], &Cnpja.Activity.from_map/1),
      phones: Enum.map(map["phones"] || [], &Cnpja.Phone.from_map/1),
      emails: Enum.map(map["emails"] || [], &Cnpja.Email.from_map/1),
      incentives: Enum.map(map["incentives"] || [], &Cnpja.SuframaIncentive.from_map/1)
    }
  end

  @doc false
  @spec from_map_nullable(map() | nil) :: t() | nil
  def from_map_nullable(nil), do: nil
  def from_map_nullable(map), do: from_map(map)
end
