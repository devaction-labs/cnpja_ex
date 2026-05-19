defmodule Cnpja.Suframa do
  @moduledoc "Dados de inscrição na SUFRAMA de um estabelecimento."

  @enforce_keys [:tax_id]
  defstruct [:tax_id, :number, :name, :approved, :status, :incentives]

  @type t :: %__MODULE__{
          tax_id: String.t(),
          number: String.t() | nil,
          name: String.t() | nil,
          approved: String.t() | nil,
          status: Cnpja.Label.t() | nil,
          incentives: [Cnpja.SuframaIncentive.t()]
        }

  @spec from_map(map()) :: t()
  def from_map(map) do
    %__MODULE__{
      tax_id: map["taxId"],
      number: map["number"],
      name: map["name"],
      approved: map["approved"],
      status: Cnpja.Label.from_map_nullable(map["status"]),
      incentives: Enum.map(map["incentives"] || [], &Cnpja.SuframaIncentive.from_map/1)
    }
  end

  @spec from_map_nullable(map() | nil) :: t() | nil
  def from_map_nullable(nil), do: nil
  def from_map_nullable(map), do: from_map(map)
end
