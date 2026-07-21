defmodule Cnpja.CnpjListExportId do
  @moduledoc "Identifier returned when a list export job is created."

  @enforce_keys [:id]
  defstruct [:id]

  @type t :: %__MODULE__{id: String.t()}

  @doc false
  @spec from_map(map()) :: t()
  def from_map(map) do
    %__MODULE__{id: map["id"]}
  end
end
