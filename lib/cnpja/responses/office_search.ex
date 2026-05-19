defmodule Cnpja.OfficeSearch do
  @moduledoc "Paginated result of an establishment search."

  @enforce_keys [:count, :records]
  defstruct [:next, :limit, :count, :records]

  @type t :: %__MODULE__{
          next: String.t() | nil,
          limit: integer() | nil,
          count: integer(),
          records: [Cnpja.Office.t()]
        }

  @spec from_map(map()) :: t()
  def from_map(map) do
    %__MODULE__{
      next: map["next"],
      limit: map["limit"],
      count: map["count"],
      records: Enum.map(map["records"] || [], &Cnpja.Office.from_map/1)
    }
  end
end
