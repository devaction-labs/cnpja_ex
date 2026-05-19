defmodule Cnpja.Credit do
  @moduledoc "Account credit balance."

  @enforce_keys [:perpetual, :transient]
  defstruct [:perpetual, :transient]

  @type t :: %__MODULE__{perpetual: integer(), transient: integer()}

  @spec from_map(map()) :: t()
  def from_map(map) do
    %__MODULE__{perpetual: map["perpetual"], transient: map["transient"]}
  end
end
