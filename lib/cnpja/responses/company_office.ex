defmodule Cnpja.CompanyOffice do
  @moduledoc """
  Lightweight establishment summary embedded in a `Cnpja.Company` response.

  Unlike `Cnpja.Office`, this DTO has no address, phones, emails, or registrations.
  """

  @enforce_keys [:tax_id, :status]
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
    :main_activity
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
          main_activity: Cnpja.Activity.t() | nil
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
      main_activity: Cnpja.Activity.from_map_nullable(map["mainActivity"])
    }
  end
end
