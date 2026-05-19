defmodule Cnpja.Agent do
  @moduledoc "Representante legal de um sócio."

  defstruct [:person, :role]

  @type t :: %__MODULE__{
          person: Cnpja.PersonRef.t() | nil,
          role: Cnpja.Label.t() | nil
        }

  @spec from_map(map()) :: t()
  def from_map(map) do
    %__MODULE__{
      person: map["person"] && Cnpja.PersonRef.from_map(map["person"]),
      role: map["role"] && Cnpja.Label.from_map(map["role"])
    }
  end

  @spec from_map_nullable(map() | nil) :: t() | nil
  def from_map_nullable(nil), do: nil
  def from_map_nullable(map), do: from_map(map)
end
