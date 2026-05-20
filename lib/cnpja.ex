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

  @param_map %{
    # --- shared ---
    max_age: "maxAge",
    max_stale: "maxStale",
    pages: "pages",
    fov: "fov",
    simples_history: "simplesHistory",
    registrations_source: "registrationsSource",

    # --- search_offices (dot-notation API params) ---
    names_in: "names.in",
    names_nin: "names.nin",
    alias_in: "alias.in",
    alias_nin: "alias.nin",
    company_name_in: "company.name.in",
    company_name_nin: "company.name.nin",
    equity_gte: "company.equity.gte",
    equity_lte: "company.equity.lte",
    legal_nature_in: "company.nature.id.in",
    legal_nature_nin: "company.nature.id.nin",
    size_in: "company.size.id.in",
    simples_optant: "company.simples.optant.eq",
    simples_since_gte: "company.simples.since.gte",
    simples_since_lte: "company.simples.since.lte",
    simei_optant: "company.simei.optant.eq",
    simei_since_gte: "company.simei.since.gte",
    simei_since_lte: "company.simei.since.lte",
    tax_id_nin: "taxId.nin",
    founded_gte: "founded.gte",
    founded_lte: "founded.lte",
    head_eq: "head.eq",
    status_date_gte: "statusDate.gte",
    status_date_lte: "statusDate.lte",
    status_in: "status.id.in",
    reason_in: "reason.id.in",
    special_date_gte: "specialDate.gte",
    special_date_lte: "specialDate.lte",
    special_in: "special.id.in",
    municipality_in: "address.municipality.in",
    municipality_nin: "address.municipality.nin",
    street_in: "address.street.in",
    street_nin: "address.street.nin",
    number_in: "address.number.in",
    number_nin: "address.number.nin",
    details_in: "address.details.in",
    details_nin: "address.details.nin",
    district_in: "address.district.in",
    district_nin: "address.district.nin",
    state_in: "address.state.in",
    zip_in: "address.zip.in",
    zip_gte: "address.zip.gte",
    zip_lte: "address.zip.lte",
    country_in: "address.country.id.in",
    country_nin: "address.country.id.nin",
    has_phone: "phones.ex",
    phone_type_in: "phones.type.in",
    phone_area_in: "phones.area.in",
    phone_area_gte: "phones.area.gte",
    phone_area_lte: "phones.area.lte",
    phone_number_in: "phones.number.in",
    phone_number_nin: "phones.number.nin",
    has_email: "emails.ex",
    email_ownership_in: "emails.ownership.in",
    email_address_in: "emails.address.in",
    email_address_nin: "emails.address.nin",
    email_domain_in: "emails.domain.in",
    email_domain_nin: "emails.domain.nin",
    activity_in: "activities.id.in",
    activity_nin: "activities.id.nin",
    main_activity_in: "mainActivity.id.in",
    main_activity_nin: "mainActivity.id.nin",
    side_activity_in: "sideActivities.id.in",
    side_activity_nin: "sideActivities.id.nin",

    # --- search_persons ---
    type_in: "type.in",
    name_in: "name.in",
    name_nin: "name.nin",
    tax_id_in: "taxId.in",
    age_in: "age.in",
    person_country_in: "country.id.in"
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
    with {:ok, body} <- Client.get("/company/#{company_id}", build_query(opts), sdk_opts(opts)) do
      {:ok, Cnpja.Company.from_map(body)}
    end
  end

  @doc """
  Looks up an establishment by its full 14-digit CNPJ.

  ## Options

  - `:simples` — include Simples Nacional data
  - `:simples_history` — include Simples Nacional history
  - `:registrations` — state registrations: `"ALL"`, `"ORIGIN"`, or comma-separated state codes
  - `:registrations_source` — IE source: `"AUTO"` (default), `"CCC"` or `"SINTEGRA"`
  - `:suframa` — include SUFRAMA data
  - `:geocoding` — include geographic coordinates
  - `:links` — certificate links, comma-separated
  - `:strategy` — cache strategy: `"CACHE_IF_ERROR"` | `"CACHE_IF_FRESH"` | `"CACHE"` | `"ONLINE"`
  - `:max_age` — maximum cache age in days
  - `:max_stale` — stale cache tolerance in days
  - `:sync` — wait for credit settlement synchronously
  """
  @spec get_office(String.t(), keyword()) :: {:ok, Cnpja.Office.t()} | {:error, Cnpja.Error.t()}
  def get_office(tax_id, opts \\ []) do
    with {:ok, body} <- Client.get("/office/#{tax_id}", build_query(opts), sdk_opts(opts)) do
      {:ok, Cnpja.Office.from_map(body)}
    end
  end

  @doc """
  Returns the aerial map image of the establishment location (PNG binary).

  ## Options

  - `:width` — image width in pixels (80–640, default 640)
  - `:height` — image height in pixels (80–640, default 640)
  - `:zoom` — zoom level (1–20, default 17)
  - `:scale` — pixel density multiplier (1–2, default 1)
  - `:type` — map type: `"roadmap"` | `"terrain"` | `"satellite"` | `"hybrid"`
  """
  @spec get_office_map(String.t(), keyword()) :: {:ok, binary()} | {:error, Cnpja.Error.t()}
  def get_office_map(tax_id, opts \\ []) do
    Client.get_binary("/office/#{tax_id}/map", build_query(opts), sdk_opts(opts))
  end

  @doc """
  Returns the Street View image of the establishment (JPEG binary).

  ## Options

  - `:width` — image width in pixels (80–640, default 640)
  - `:height` — image height in pixels (80–640, default 640)
  - `:fov` — field of view in degrees (60–120, default 90)
  """
  @spec get_office_street_view(String.t(), keyword()) ::
          {:ok, binary()} | {:error, Cnpja.Error.t()}
  def get_office_street_view(tax_id, opts \\ []) do
    Client.get_binary("/office/#{tax_id}/street", build_query(opts), sdk_opts(opts))
  end

  @doc """
  Searches establishments with filters.

  ## Options

  - `:token` — pagination cursor (mutually exclusive with all filters)
  - `:limit` — results per page (1–1000, default 10)
  - `:names_in` / `:names_nin` — include/exclude terms in trade name or company name
  - `:alias_in` / `:alias_nin` — include/exclude terms in trade name only
  - `:company_name_in` / `:company_name_nin` — include/exclude terms in company name
  - `:legal_nature_in` / `:legal_nature_nin` — legal nature IDs (IBGE codes)
  - `:equity_gte` / `:equity_lte` — share capital range
  - `:size_in` — company size IDs (`1`=ME, `3`=EPP, `5`=Other)
  - `:simples_optant` — enrolled in Simples Nacional
  - `:simei_optant` — enrolled as MEI
  - `:head_eq` — `true` for headquarters only, `false` for branches only
  - `:status_in` — status IDs (1=Nula, 2=Ativa, 3=Suspensa, 4=Inapta, 8=Baixada)
  - `:reason_in` — reason IDs for status
  - `:status_date_gte` / `:status_date_lte` — status date range (ISO 8601)
  - `:special_in` — special status IDs
  - `:special_date_gte` / `:special_date_lte` — special status date range
  - `:founded_gte` / `:founded_lte` — opening date range (ISO 8601)
  - `:municipality_in` / `:municipality_nin` — IBGE municipality codes
  - `:state_in` — state abbreviations
  - `:zip_in` — postal codes
  - `:zip_gte` / `:zip_lte` — postal code range
  - `:district_in` / `:district_nin` — neighbourhood terms
  - `:street_in` / `:street_nin` — street name terms
  - `:country_in` / `:country_nin` — M49 country codes
  - `:main_activity_in` / `:side_activity_in` — CNAE codes
  - `:activity_in` / `:activity_nin` — CNAE codes across main and side activities
  - `:has_phone` — `true`/`false` for phone presence
  - `:has_email` — `true`/`false` for e-mail presence
  """
  @spec search_offices(keyword()) :: {:ok, Cnpja.OfficeSearch.t()} | {:error, Cnpja.Error.t()}
  def search_offices(opts \\ []) do
    with {:ok, body} <- Client.get("/office", build_query(opts), sdk_opts(opts)) do
      {:ok, Cnpja.OfficeSearch.from_map(body)}
    end
  end

  @doc """
  Looks up a person by their CNPJá ID.
  """
  @spec get_person(String.t(), keyword()) :: {:ok, Cnpja.Person.t()} | {:error, Cnpja.Error.t()}
  def get_person(person_id, opts \\ []) do
    with {:ok, body} <- Client.get("/person/#{person_id}", [], sdk_opts(opts)) do
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
  - `:person_country_in` — M49 country codes (comma-separated)
  """
  @spec search_persons(keyword()) :: {:ok, Cnpja.PersonSearch.t()} | {:error, Cnpja.Error.t()}
  def search_persons(opts \\ []) do
    with {:ok, body} <- Client.get("/person", build_query(opts), sdk_opts(opts)) do
      {:ok, Cnpja.PersonSearch.from_map(body)}
    end
  end

  @doc """
  Queries establishment data directly from the Receita Federal.
  """
  @spec get_rfb(String.t(), keyword()) :: {:ok, Cnpja.Rfb.t()} | {:error, Cnpja.Error.t()}
  def get_rfb(tax_id, opts \\ []) do
    query = [{"taxId", tax_id} | build_query(opts)]

    with {:ok, body} <- Client.get("/rfb", query, sdk_opts(opts)) do
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
    query = [{"taxId", tax_id} | build_query(opts)]
    Client.get_binary("/rfb/certificate", query, sdk_opts(opts))
  end

  @doc """
  Queries Simples Nacional and MEI data for a company.
  """
  @spec get_simples(String.t(), keyword()) :: {:ok, Cnpja.Simples.t()} | {:error, Cnpja.Error.t()}
  def get_simples(tax_id, opts \\ []) do
    query = [{"taxId", tax_id} | build_query(opts)]

    with {:ok, body} <- Client.get("/simples", query, sdk_opts(opts)) do
      {:ok, Cnpja.Simples.from_map(body)}
    end
  end

  @doc """
  Returns the Simples Nacional enrollment declaration as a PDF binary.
  """
  @spec get_simples_certificate(String.t(), keyword()) ::
          {:ok, binary()} | {:error, Cnpja.Error.t()}
  def get_simples_certificate(tax_id, opts \\ []) do
    Client.get_binary("/simples/certificate", [{"taxId", tax_id}], sdk_opts(opts))
  end

  @doc """
  Queries state registrations from the CCC for the given states.

  ## Parameters

  - `tax_id` — full 14-digit CNPJ or CPF (rural producer)
  - `states` — comma-separated state codes, `"ALL"` or `"ORIGIN"`

  ## Options

  - `:source` — data source: `"AUTO"` (default), `"CCC"` or `"SINTEGRA"`
  - `:strategy` — cache strategy
  - `:max_age` / `:max_stale` — cache age limits in days

  ## Example

      {:ok, ccc} = Cnpja.get_ccc("37335118000180", "ALL")
  """
  @spec get_ccc(String.t(), String.t(), keyword()) ::
          {:ok, Cnpja.Ccc.t()} | {:error, Cnpja.Error.t()}
  def get_ccc(tax_id, states, opts \\ []) do
    query = [{"taxId", tax_id}, {"states", states} | build_query(opts)]

    with {:ok, body} <- Client.get("/ccc", query, sdk_opts(opts)) do
      {:ok, Cnpja.Ccc.from_map(body)}
    end
  end

  @doc """
  Returns the CCC fiscal regularity certificate as a PDF binary.

  ## Options

  - `:state` — specific state code (required for rural producer CPF)
  """
  @spec get_ccc_certificate(String.t(), keyword()) :: {:ok, binary()} | {:error, Cnpja.Error.t()}
  def get_ccc_certificate(tax_id, opts \\ []) do
    query = [{"taxId", tax_id} | build_query(opts)]
    Client.get_binary("/ccc/certificate", query, sdk_opts(opts))
  end

  @doc """
  Queries SUFRAMA enrollment data for an establishment.
  """
  @spec get_suframa(String.t(), keyword()) ::
          {:ok, Cnpja.Suframa.t()} | {:error, Cnpja.Error.t()}
  def get_suframa(tax_id, opts \\ []) do
    query = [{"taxId", tax_id} | build_query(opts)]

    with {:ok, body} <- Client.get("/suframa", query, sdk_opts(opts)) do
      {:ok, Cnpja.Suframa.from_map(body)}
    end
  end

  @doc """
  Returns the SUFRAMA fiscal incentives certificate as a PDF binary.
  """
  @spec get_suframa_certificate(String.t(), keyword()) ::
          {:ok, binary()} | {:error, Cnpja.Error.t()}
  def get_suframa_certificate(tax_id, opts \\ []) do
    Client.get_binary("/suframa/certificate", [{"taxId", tax_id}], sdk_opts(opts))
  end

  defp sdk_opts(opts), do: Keyword.take(opts, @sdk_keys)

  defp build_query(opts) do
    opts
    |> Keyword.drop(@sdk_keys)
    |> Enum.map(fn {k, v} -> {Map.get(@param_map, k, to_string(k)), v} end)
  end
end
