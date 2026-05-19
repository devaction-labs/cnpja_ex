defmodule Cnpja.PersonSearch do
  @moduledoc "Paginated result of a person search."

  @enforce_keys [:count, :records]
  defstruct [:next, :limit, :count, :records]

  @type t :: %__MODULE__{
          next: String.t() | nil,
          limit: integer() | nil,
          count: integer(),
          records: [Cnpja.Person.t()]
        }

  @spec from_map(map()) :: t()
  def from_map(map) do
    %__MODULE__{
      next: map["next"],
      limit: map["limit"],
      count: map["count"],
      records: Enum.map(map["records"] || [], &Cnpja.Person.from_map/1)
    }
  end
end
