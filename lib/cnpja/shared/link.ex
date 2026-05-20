defmodule Cnpja.Link do
  @moduledoc "Public document link returned inside an establishment or RFB response."

  @enforce_keys [:type, :url]
  defstruct [:type, :url]

  @type t :: %__MODULE__{type: String.t(), url: String.t()}

  @doc false
  @spec from_map(map()) :: t()
  def from_map(map) do
    %__MODULE__{type: map["type"], url: map["url"]}
  end
end
