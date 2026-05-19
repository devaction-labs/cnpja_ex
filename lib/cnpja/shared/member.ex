defmodule Cnpja.Member do
  @moduledoc "Company member or administrator."

  @enforce_keys [:since, :person, :role]
  defstruct [:since, :person, :role, :agent]

  @type t :: %__MODULE__{
          since: String.t(),
          person: Cnpja.PersonRef.t(),
          role: Cnpja.Label.t(),
          agent: Cnpja.Agent.t() | nil
        }

  @spec from_map(map()) :: t()
  def from_map(map) do
    %__MODULE__{
      since: map["since"],
      person: Cnpja.PersonRef.from_map(map["person"]),
      role: Cnpja.Label.from_map(map["role"]),
      agent: Cnpja.Agent.from_map_nullable(map["agent"])
    }
  end
end
