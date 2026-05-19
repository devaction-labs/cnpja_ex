defmodule Cnpja.Email do
  @moduledoc "Email address of an establishment."

  @enforce_keys [:address, :domain]
  defstruct [:ownership, :address, :domain]

  @type t :: %__MODULE__{
          ownership: String.t() | nil,
          address: String.t(),
          domain: String.t()
        }

  @spec from_map(map()) :: t()
  def from_map(map) do
    %__MODULE__{
      ownership: map["ownership"],
      address: map["address"],
      domain: map["domain"]
    }
  end
end
