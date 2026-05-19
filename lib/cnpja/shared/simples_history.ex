defmodule Cnpja.SimplesHistory do
  @moduledoc "Período histórico do Simples Nacional ou MEI."

  @enforce_keys [:from, :text]
  defstruct [:from, :until, :text]

  @type t :: %__MODULE__{from: String.t(), until: String.t() | nil, text: String.t()}

  @spec from_map(map()) :: t()
  def from_map(map) do
    %__MODULE__{from: map["from"], until: map["until"], text: map["text"]}
  end
end
