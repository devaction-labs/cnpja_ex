defmodule Cnpja.SizeLabel do
  @moduledoc "Company size classification with id, acronym, and display text."

  @enforce_keys [:id, :acronym, :text]
  defstruct [:id, :acronym, :text]

  @type t :: %__MODULE__{id: integer(), acronym: String.t(), text: String.t()}

  @doc false
  @spec from_map(map()) :: t()
  def from_map(map) do
    %__MODULE__{id: map["id"], acronym: map["acronym"] || "", text: map["text"]}
  end

  @doc false
  @spec from_map_nullable(map() | nil) :: t() | nil
  def from_map_nullable(nil), do: nil
  def from_map_nullable(map), do: from_map(map)
end
