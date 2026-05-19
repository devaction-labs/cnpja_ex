defmodule Cnpja.SuframaIncentive do
  @moduledoc "Tax incentive granted by SUFRAMA."

  @enforce_keys [:tribute, :benefit, :purpose, :basis]
  defstruct [:tribute, :benefit, :purpose, :basis]

  @type t :: %__MODULE__{
          tribute: String.t(),
          benefit: String.t(),
          purpose: String.t(),
          basis: String.t()
        }

  @spec from_map(map()) :: t()
  def from_map(map) do
    %__MODULE__{
      tribute: map["tribute"],
      benefit: map["benefit"],
      purpose: map["purpose"],
      basis: map["basis"]
    }
  end
end
