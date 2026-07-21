defmodule Cnpja.OfficeSuframa do
  @moduledoc """
  SUFRAMA summary embedded in a `Cnpja.Office` response.

  Lighter than `Cnpja.Suframa` (full `/suframa` endpoint): no tax_id, address, phones, etc.
  """

  @enforce_keys [:number]
  defstruct [
    :number,
    :since,
    :approved,
    :approval_date,
    :status,
    :incentives
  ]

  @type t :: %__MODULE__{
          number: String.t(),
          since: String.t() | nil,
          approved: boolean() | nil,
          approval_date: String.t() | nil,
          status: Cnpja.Label.t() | nil,
          incentives: [Cnpja.SuframaIncentive.t()]
        }

  @doc false
  @spec from_map(map()) :: t()
  def from_map(map) do
    %__MODULE__{
      number: map["number"],
      since: map["since"],
      approved: map["approved"],
      approval_date: map["approvalDate"],
      status: Cnpja.Label.from_map_nullable(map["status"]),
      incentives: Enum.map(map["incentives"] || [], &Cnpja.SuframaIncentive.from_map/1)
    }
  end
end
