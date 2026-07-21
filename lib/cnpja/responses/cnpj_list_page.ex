defmodule Cnpja.CnpjListPage do
  @moduledoc "Paginated result of a saved-list search."

  @enforce_keys [:count, :records]
  defstruct [:next, :limit, :count, :records]

  @type t :: %__MODULE__{
          next: String.t() | nil,
          limit: integer() | nil,
          count: integer(),
          records: [Cnpja.CnpjListSummary.t()]
        }

  @doc false
  @spec from_map(map()) :: t()
  def from_map(map) do
    %__MODULE__{
      next: map["next"],
      limit: map["limit"],
      count: map["count"],
      records: Enum.map(map["records"] || [], &Cnpja.CnpjListSummary.from_map/1)
    }
  end
end
