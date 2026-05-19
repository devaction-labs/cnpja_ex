defmodule Cnpja do
  @moduledoc """
  Elixir SDK for the CNPJá API.

  All functions return `{:ok, struct}` on success or `{:error, %Cnpja.Error{}}` on failure.

  ## Configuration

  Via `config.exs`:

      config :cnpja_ex, api_key: System.get_env("CNPJA_API_KEY")

  Via option (multi-tenant):

      Cnpja.get_office("37335118000180", api_key: "other-key")

  ## Example

      case Cnpja.get_office("37335118000180") do
        {:ok, office}                       -> office.alias
        {:error, %Cnpja.Error{status: 404}} -> "not found"
        {:error, %Cnpja.Error{status: 429, required: r}} -> "insufficient credits: \#{r}"
        {:error, %Cnpja.Error{}}            -> "generic error"
      end
  """

  alias Cnpja.Client

  @sdk_keys [:api_key, :base_url]

  @camel_map %{
    simples_history: "simplesHistory",
    registrations_source: "registrationsSource",
    max_age: "maxAge",
    max_stale: "maxStale",
    history: "history",
    fov: "fov",
    pages: "pages",
    alias_in: "aliasIn",
    alias_nin: "aliasNin",
    company_name_in: "companyNameIn",
    company_name_nin: "companyNameNin",
    legal_nature_in: "legalNatureIn",
    legal_nature_nin: "legalNatureNin",
    equity_gte: "equityGte",
    equity_lte: "equityLte",
    size_in: "sizeIn",
    simples_optant: "simplesOptant",
    simei_optant: "simeiOptant",
    status_in: "statusIn",
    municipality_in: "municipalityIn",
    state_in: "stateIn",
    zip_in: "zipIn",
    main_activity_in: "mainActivityIn",
    side_activity_in: "sideActivityIn",
    has_phone: "hasPhone",
    has_email: "hasEmail",
    type_in: "typeIn",
    name_in: "nameIn",
    name_nin: "nameNin",
    tax_id_in: "taxIdIn",
    age_in: "ageIn",
    country_in: "countryIn"
  }

  @doc """
  Returns the credit balance for the account associated with the API key.
  """
  @spec get_credit(keyword()) :: {:ok, Cnpja.Credit.t()} | {:error, Cnpja.Error.t()}
  def get_credit(opts \\ []) do
    with {:ok, body} <- Client.get("/credit", [], sdk_opts(opts)) do
      {:ok, Cnpja.Credit.from_map(body)}
    end
  end

  @doc """
  Looks up a Brazilian postal code (CEP).

  ## Example

      {:ok, zip} = Cnpja.get_zip("01310100")
      zip.city  #=> "São Paulo"
  """
  @spec get_zip(String.t(), keyword()) :: {:ok, Cnpja.Zip.t()} | {:error, Cnpja.Error.t()}
  def get_zip(code, opts \\ []) do
    with {:ok, body} <- Client.get("/zip/#{code}", [], sdk_opts(opts)) do
      {:ok, Cnpja.Zip.from_map(body)}
    end
  end

  @doc """
  Looks up a company by the first 8 digits of the CNPJ (root).

  ## Options

  - `:simples` — include Simples Nacional data
  - `:simples_history` — include Simples Nacional history
  """
  @spec get_company(String.t(), keyword()) :: {:ok, Cnpja.Company.t()} | {:error, Cnpja.Error.t()}
  def get_company(company_id, opts \\ []) do
    with {:ok, body} <- Client.get("/companies/#{company_id}", build_query(opts), sdk_opts(opts)) do
      {:ok, Cnpja.Company.from_map(body)}
    end
  end

  @doc """
  Looks up an establishment by its full 14-digit CNPJ.

  ## Options

  - `:simples` — include Simples Nacional data
  - `:simples_history` — include Simples Nacional history
  - `:registrations` — state registrations: `"ALL"`, `"NONE"`, or comma-separated state codes
  - `:registrations_source` — IE source: `"CCC"` (default) or `"RECEIPTS"`
  - `:suframa` — include SUFRAMA data
  - `:geocoding` — include geographic coordinates
  - `:links` — certificate links, comma-separated
  - `:strategy` — cache strategy: `"CACHE_IF_ERROR"` | `"NO_CACHE"` | `"CACHE"`
  - `:max_age` — maximum cache age in days
  - `:max_stale` — stale cache tolerance in days
  """
  @spec get_office(String.t(), keyword()) :: {:ok, Cnpja.Office.t()} | {:error, Cnpja.Error.t()}
  def get_office(tax_id, opts \\ []) do
    with {:ok, body} <- Client.get("/offices/#{tax_id}", build_query(opts), sdk_opts(opts)) do
      {:ok, Cnpja.Office.from_map(body)}
    end
  end

  @doc """
  Returns the map image of the establishment location (PNG binary).

  ## Options

  - `:width` — image width in pixels
  - `:height` — image height in pixels
  - `:zoom` — zoom level
  - `:scale` — scale factor
  - `:type` — map type
  """
  @spec get_office_map(String.t(), keyword()) :: {:ok, binary()} | {:error, Cnpja.Error.t()}
  def get_office_map(tax_id, opts \\ []) do
    Client.get_binary("/offices/#{tax_id}/map", build_query(opts), sdk_opts(opts))
  end

  @doc """
  Returns the Street View image of the establishment (JPEG binary).

  ## Options

  - `:width` — image width in pixels
  - `:height` — image height in pixels
  - `:fov` — field of view angle
  """
  @spec get_office_street_view(String.t(), keyword()) ::
          {:ok, binary()} | {:error, Cnpja.Error.t()}
  def get_office_street_view(tax_id, opts \\ []) do
    Client.get_binary("/offices/#{tax_id}/street", build_query(opts), sdk_opts(opts))
  end

  @doc """
  Searches establishments with filters.

  ## Options

  - `:token` — pagination cursor (mutually exclusive with all filters)
  - `:limit` — results per page
  - `:alias_in` / `:alias_nin` — include/exclude trade name terms
  - `:company_name_in` / `:company_name_nin` — include/exclude company name terms
  - `:legal_nature_in` / `:legal_nature_nin` — legal nature codes
  - `:equity_gte` / `:equity_lte` — share capital range
  - `:size_in` — company size IDs (`1`=ME, `3`=EPP, `5`=Other)
  - `:simples_optant` — enrolled in Simples Nacional (`true`/`false`)
  - `:simei_optant` — enrolled as MEI (`true`/`false`)
  - `:head` — headquarters only
  - `:status_in` — status codes (2=Active, 3=Suspended, 4=Unfit, 8=Closed)
  - `:municipality_in` / `:state_in` / `:zip_in` — location filters
  - `:main_activity_in` / `:side_activity_in` — CNAE filters
  - `:has_phone` / `:has_email` — contact presence filters
  """
  @spec search_offices(keyword()) :: {:ok, Cnpja.OfficeSearch.t()} | {:error, Cnpja.Error.t()}
  def search_offices(opts \\ []) do
    with {:ok, body} <- Client.get("/offices", build_query(opts), sdk_opts(opts)) do
      {:ok, Cnpja.OfficeSearch.from_map(body)}
    end
  end

  @doc """
  Looks up a person by their CNPJá ID.
  """
  @spec get_person(String.t(), keyword()) :: {:ok, Cnpja.Person.t()} | {:error, Cnpja.Error.t()}
  def get_person(person_id, opts \\ []) do
    with {:ok, body} <- Client.get("/persons/#{person_id}", [], sdk_opts(opts)) do
      {:ok, Cnpja.Person.from_map(body)}
    end
  end

  @doc """
  Searches persons with filters.

  ## Options

  - `:token` — pagination cursor (mutually exclusive with all filters)
  - `:limit` — results per page
  - `:type_in` — person types: `"NATURAL"`, `"LEGAL"`, `"FOREIGN"`, `"UNKNOWN"` (comma-separated)
  - `:name_in` / `:name_nin` — include/exclude name terms
  - `:tax_id_in` — partial CPF digits (positions 4–9, comma-separated)
  - `:age_in` — age ranges, e.g. `"21-30,31-40"`
  - `:country_in` — M49 country codes (comma-separated)
  """
  @spec search_persons(keyword()) :: {:ok, Cnpja.PersonSearch.t()} | {:error, Cnpja.Error.t()}
  def search_persons(opts \\ []) do
    with {:ok, body} <- Client.get("/persons", build_query(opts), sdk_opts(opts)) do
      {:ok, Cnpja.PersonSearch.from_map(body)}
    end
  end

  @doc """
  Queries establishment data directly from the Receita Federal.
  """
  @spec get_rfb(String.t(), keyword()) :: {:ok, Cnpja.Rfb.t()} | {:error, Cnpja.Error.t()}
  def get_rfb(tax_id, opts \\ []) do
    with {:ok, body} <- Client.get("/rfb/#{tax_id}", build_query(opts), sdk_opts(opts)) do
      {:ok, Cnpja.Rfb.from_map(body)}
    end
  end

  @doc """
  Returns the Comprovante de Inscrição e de Situação Cadastral as a PDF binary.

  ## Options

  - `:pages` — pages to include: `"REGISTRATION"`, `"MEMBERS"`, or both comma-separated
  """
  @spec get_rfb_certificate(String.t(), keyword()) :: {:ok, binary()} | {:error, Cnpja.Error.t()}
  def get_rfb_certificate(tax_id, opts \\ []) do
    Client.get_binary("/rfb/#{tax_id}/certificate", build_query(opts), sdk_opts(opts))
  end

  @doc """
  Queries Simples Nacional and MEI data for a company.
  """
  @spec get_simples(String.t(), keyword()) :: {:ok, Cnpja.Simples.t()} | {:error, Cnpja.Error.t()}
  def get_simples(tax_id, opts \\ []) do
    with {:ok, body} <- Client.get("/simples/#{tax_id}", build_query(opts), sdk_opts(opts)) do
      {:ok, Cnpja.Simples.from_map(body)}
    end
  end

  @doc """
  Returns the Simples Nacional enrollment declaration as a PDF binary.
  """
  @spec get_simples_certificate(String.t(), keyword()) ::
          {:ok, binary()} | {:error, Cnpja.Error.t()}
  def get_simples_certificate(tax_id, opts \\ []) do
    Client.get_binary("/simples/#{tax_id}/certificate", [], sdk_opts(opts))
  end

  @doc """
  Queries state registrations from the CCC for the given states.

  ## Parameters

  - `tax_id` — full 14-digit CNPJ
  - `states` — comma-separated state codes or `"ALL"`

  ## Example

      {:ok, ccc} = Cnpja.get_ccc("37335118000180", "SP,MG")
  """
  @spec get_ccc(String.t(), String.t(), keyword()) ::
          {:ok, Cnpja.Ccc.t()} | {:error, Cnpja.Error.t()}
  def get_ccc(tax_id, states, opts \\ []) do
    with {:ok, body} <- Client.get("/ccc/#{tax_id}/#{states}", build_query(opts), sdk_opts(opts)) do
      {:ok, Cnpja.Ccc.from_map(body)}
    end
  end

  @doc """
  Returns the CCC fiscal regularity certificate as a PDF binary.

  ## Options

  - `:state` — specific state code to filter the certificate
  """
  @spec get_ccc_certificate(String.t(), keyword()) :: {:ok, binary()} | {:error, Cnpja.Error.t()}
  def get_ccc_certificate(tax_id, opts \\ []) do
    Client.get_binary("/ccc/#{tax_id}/certificate", build_query(opts), sdk_opts(opts))
  end

  @doc """
  Queries SUFRAMA enrollment data for an establishment.
  """
  @spec get_suframa(String.t(), keyword()) :: {:ok, Cnpja.Suframa.t()} | {:error, Cnpja.Error.t()}
  def get_suframa(tax_id, opts \\ []) do
    with {:ok, body} <- Client.get("/suframa/#{tax_id}", build_query(opts), sdk_opts(opts)) do
      {:ok, Cnpja.Suframa.from_map(body)}
    end
  end

  @doc """
  Returns the SUFRAMA fiscal incentives certificate as a PDF binary.
  """
  @spec get_suframa_certificate(String.t(), keyword()) ::
          {:ok, binary()} | {:error, Cnpja.Error.t()}
  def get_suframa_certificate(tax_id, opts \\ []) do
    Client.get_binary("/suframa/#{tax_id}/certificate", [], sdk_opts(opts))
  end

  defp sdk_opts(opts), do: Keyword.take(opts, @sdk_keys)

  defp build_query(opts) do
    opts
    |> Keyword.drop(@sdk_keys)
    |> Enum.map(fn {k, v} -> {Map.get(@camel_map, k, to_string(k)), v} end)
  end
end
