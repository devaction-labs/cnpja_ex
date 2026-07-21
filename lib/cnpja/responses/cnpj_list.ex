defmodule Cnpja.CnpjList do
  @moduledoc """
  Saved CNPJ list on the CNPJá account.

  Lists store tax IDs (or search filters) for asynchronous bulk export.
  """

  @enforce_keys [:id, :title]
  defstruct [
    :id,
    :created,
    :updated,
    :title,
    :description,
    :size,
    :items,
    :query,
    :limit
  ]

  @type t :: %__MODULE__{
          id: String.t(),
          created: String.t() | nil,
          updated: String.t() | nil,
          title: String.t(),
          description: String.t() | nil,
          size: number() | nil,
          items: [String.t()],
          query: map() | nil,
          limit: number() | nil
        }

  @doc false
  @spec from_map(map()) :: t()
  def from_map(map) do
    %__MODULE__{
      id: map["id"],
      created: map["created"],
      updated: map["updated"],
      title: map["title"],
      description: map["description"],
      size: map["size"],
      items: map["items"] || [],
      query: map["query"],
      limit: map["limit"]
    }
  end
end
