defmodule Cnpja.Phone do
  @moduledoc "Telefone de um estabelecimento."

  @enforce_keys [:area, :number]
  defstruct [:type, :area, :number]

  @type t :: %__MODULE__{
          type: String.t() | nil,
          area: String.t(),
          number: String.t()
        }

  @spec from_map(map()) :: t()
  def from_map(map) do
    %__MODULE__{type: map["type"], area: map["area"], number: map["number"]}
  end
end
