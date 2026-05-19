defmodule Cnpja.Error do
  @moduledoc "Erro retornado pela API CNPJá."

  defstruct [:status, :message, :constraints, :required, :remaining, :raw]

  @type t :: %__MODULE__{
          status: integer(),
          message: String.t(),
          constraints: [String.t()] | nil,
          required: integer() | nil,
          remaining: integer() | nil,
          raw: map()
        }

  @spec from_response(integer(), map()) :: t()
  def from_response(400, body) do
    %__MODULE__{
      status: 400,
      message: body["message"] || "Validation error",
      constraints: body["constraints"] || [],
      raw: body
    }
  end

  def from_response(429, body) do
    %__MODULE__{
      status: 429,
      message: body["message"] || "Rate limit exceeded",
      required: body["required"],
      remaining: body["remaining"],
      raw: body
    }
  end

  def from_response(status, body) do
    %__MODULE__{
      status: status,
      message: body["message"] || "HTTP #{status}",
      raw: body
    }
  end
end
