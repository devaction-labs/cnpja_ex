defmodule Cnpja.PersonMembership do
  @moduledoc "A person's membership record within a company."

  @enforce_keys [:since, :role, :company]
  defstruct [:since, :role, :company, :agent]

  @type t :: %__MODULE__{
          since: String.t(),
          role: Cnpja.Label.t(),
          company: Cnpja.PersonMembershipCompany.t(),
          agent: Cnpja.Agent.t() | nil
        }

  @doc false
  @spec from_map(map()) :: t()
  def from_map(map) do
    %__MODULE__{
      since: map["since"],
      role: Cnpja.Label.from_map(map["role"]),
      company: Cnpja.PersonMembershipCompany.from_map(map["company"]),
      agent: Cnpja.Agent.from_map_nullable(map["agent"])
    }
  end
end
