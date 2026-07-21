defmodule Cnpja.CnpjListExport do
  @moduledoc """
  Asynchronous export job for a saved CNPJ list.

  Status lifecycle: `PENDING` → `PROCESSING` → `PROCESSED` → `EXPORTING` → `COMPLETED` | `FAILED`.
  When completed, `links` contains public URLs for `EXCEL` and `JSON_ZIP` files.
  """

  @enforce_keys [:id, :status]
  defstruct [
    :id,
    :created,
    :updated,
    :status,
    :status_reason,
    :progress,
    :options,
    :links
  ]

  @type t :: %__MODULE__{
          id: String.t(),
          created: String.t() | nil,
          updated: String.t() | nil,
          status: String.t(),
          status_reason: String.t() | nil,
          progress: number() | nil,
          options: map() | nil,
          links: [Cnpja.Link.t()]
        }

  @doc false
  @spec from_map(map()) :: t()
  def from_map(map) do
    %__MODULE__{
      id: map["id"],
      created: map["created"],
      updated: map["updated"],
      status: map["status"],
      status_reason: map["statusReason"],
      progress: map["progress"],
      options: map["options"],
      links: Enum.map(map["links"] || [], &Cnpja.Link.from_map/1)
    }
  end
end
