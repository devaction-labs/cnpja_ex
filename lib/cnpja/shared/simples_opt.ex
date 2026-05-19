defmodule Cnpja.SimplesOpt do
  @moduledoc "Dados de opção pelo Simples Nacional ou enquadramento no MEI."

  @enforce_keys [:optant]
  defstruct [:optant, :since, :history]

  @type t :: %__MODULE__{
          optant: boolean(),
          since: String.t() | nil,
          history: [Cnpja.SimplesHistory.t()]
        }

  @spec from_map(map()) :: t()
  def from_map(map) do
    %__MODULE__{
      optant: map["optant"],
      since: map["since"],
      history: Enum.map(map["history"] || [], &Cnpja.SimplesHistory.from_map/1)
    }
  end

  @spec from_map_nullable(map() | nil) :: t() | nil
  def from_map_nullable(nil), do: nil
  def from_map_nullable(map), do: from_map(map)
end
