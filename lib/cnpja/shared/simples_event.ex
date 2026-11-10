defmodule Cnpja.SimplesEvent do
  @moduledoc "Upcoming regular-regime (IBS/CBS) event for a Simples Nacional optant."

  @enforce_keys [:regime, :from, :text]
  defstruct [:regime, :from, :text]

  @type t :: %__MODULE__{regime: String.t(), from: String.t(), text: String.t()}

  @spec from_map(map()) :: t()
  def from_map(map) do
    %__MODULE__{regime: map["regime"], from: map["from"], text: map["text"]}
  end
end
