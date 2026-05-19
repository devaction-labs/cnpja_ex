defmodule Cnpja.StateRegistration do
  @moduledoc "Inscrição estadual de um estabelecimento."

  @enforce_keys [:number, :state, :enabled]
  defstruct [:number, :state, :enabled, :status_date, :status, :type]

  @type t :: %__MODULE__{
          number: String.t(),
          state: String.t(),
          enabled: boolean(),
          status_date: String.t() | nil,
          status: Cnpja.Label.t() | nil,
          type: Cnpja.Label.t() | nil
        }

  @spec from_map(map()) :: t()
  def from_map(map) do
    %__MODULE__{
      number: map["number"],
      state: map["state"],
      enabled: map["enabled"],
      status_date: map["statusDate"],
      status: map["status"] && Cnpja.Label.from_map(map["status"]),
      type: map["type"] && Cnpja.Label.from_map(map["type"])
    }
  end
end
