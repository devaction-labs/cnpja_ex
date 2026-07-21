defmodule Cnpja.CnpjListExportPage do
  @moduledoc "Paginated result of list-export search."

  @enforce_keys [:count, :records]
  defstruct [:next, :limit, :count, :records]

  @type t :: %__MODULE__{
          next: String.t() | nil,
          limit: integer() | nil,
          count: integer(),
          records: [Cnpja.CnpjListExport.t()]
        }

  @doc false
  @spec from_map(map()) :: t()
  def from_map(map) do
    %__MODULE__{
      next: map["next"],
      limit: map["limit"],
      count: map["count"],
      records: Enum.map(map["records"] || [], &Cnpja.CnpjListExport.from_map/1)
    }
  end
end
