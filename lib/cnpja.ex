defmodule Cnpja do
  @moduledoc """
  Elixir SDK for the CNPJá API.

  All functions return `{:ok, struct}` on success or `{:error, %Cnpja.Error{}}` on failure
  (except `delete_list/2`, which returns `:ok` on success).

  ## Configuration

  Via `config.exs`:

      config :cnpja_ex,
        api_key: System.get_env("CNPJA_API_KEY"),
        receive_timeout: 30_000

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

  @sdk_keys [:api_key, :base_url, :receive_timeout]

  @param_map %{
    # --- shared ---
    max_age: "maxAge",
    max_stale: "maxStale",
    pages: "pages",
    fov: "fov",
    simples_history: "simplesHistory",
    registrations_source: "registrationsSource",
    history: "history",
    search: "search",

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
    person_country_in: "country.id.in",
    person_country_nin: "country.id.nin"
  }

  @body_key_map %{
    title: "title",
    description: "description",
    limit: "limit",
    items: "items",
    query: "query",
    options: "options",
    simples: "simples",
    simples_history: "simplesHistory",
    registrations: "registrations",
    registrations_source: "registrationsSource",
    suframa: "suframa",
    geocoding: "geocoding",
    strategy: "strategy",
    max_age: "maxAge",
    max_stale: "maxStale"
  }

  # ---------------------------------------------------------------------------
  # Account
  # ---------------------------------------------------------------------------

  @doc """
  Returns the credit balance for the account associated with the API key.
  """
  @spec get_credit(keyword()) :: {:ok, Cnpja.Credit.t()} | {:error, Cnpja.Error.t()}
  def get_credit(opts \\ []) do
    with {:ok, body} <- Client.get("/credit", [], sdk_opts(opts)) do
      {:ok, Cnpja.Credit.from_map(body)}
    end
  end

  # ---------------------------------------------------------------------------
  # Zip / Company / Office / Person
  # ---------------------------------------------------------------------------

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

  The response includes members, offices, and Simples/MEI data when available.
  This endpoint has no query options in the Commercial API.
  """
  @spec get_company(String.t(), keyword()) :: {:ok, Cnpja.Company.t()} | {:error, Cnpja.Error.t()}
  def get_company(company_id, opts \\ []) do
    with {:ok, body} <- Client.get("/company/#{company_id}", [], sdk_opts(opts)) do
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

  Lists of values are joined as comma-separated strings.
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
  - `:person_country_in` / `:person_country_nin` — M49 country codes
  """
  @spec search_persons(keyword()) :: {:ok, Cnpja.PersonSearch.t()} | {:error, Cnpja.Error.t()}
  def search_persons(opts \\ []) do
    with {:ok, body} <- Client.get("/person", build_query(opts), sdk_opts(opts)) do
      {:ok, Cnpja.PersonSearch.from_map(body)}
    end
  end

  # ---------------------------------------------------------------------------
  # Online registries (RFB, Simples, CCC, SUFRAMA)
  # ---------------------------------------------------------------------------

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

  ## Options

  - `:history` — include previous Simples/MEI periods (`true`/`false`)
  - `:simples_history` — alias for `:history` (kept for consistency with `get_office/2`)
  - `:strategy` / `:max_age` / `:max_stale` / `:sync` — cache controls
  """
  @spec get_simples(String.t(), keyword()) :: {:ok, Cnpja.Simples.t()} | {:error, Cnpja.Error.t()}
  def get_simples(tax_id, opts \\ []) do
    opts = normalize_simples_opts(opts)
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

  # ---------------------------------------------------------------------------
  # Saved lists + export
  # ---------------------------------------------------------------------------

  @doc """
  Creates a saved CNPJ list on the account (up to 1000 lists).

  ## Attributes

  - `:title` — required
  - `:description` — optional
  - `:items` — list of 14-digit CNPJs (mutually exclusive with `:query`)
  - `:query` — search filters (same keys as `search_offices/1`, or a map with API keys)
  - `:limit` — max establishments when generating from `:query`

  ## Example

      {:ok, list} = Cnpja.create_list(
        title: "SP ativas",
        query: [state_in: ["SP"], status_in: [2]],
        limit: 1000
      )
  """
  @spec create_list(keyword() | map(), keyword()) ::
          {:ok, Cnpja.CnpjList.t()} | {:error, Cnpja.Error.t()}
  def create_list(attrs, opts \\ []) do
    {attrs, opts} = split_attrs_opts(attrs, opts)

    with {:ok, body} <- Client.post("/list", build_body(attrs), sdk_opts(opts)) do
      {:ok, Cnpja.CnpjList.from_map(body)}
    end
  end

  @doc """
  Searches saved lists on the account.

  ## Options

  - `:token` — pagination cursor
  - `:limit` — page size (default 10)
  - `:search` — term matched against title or description
  """
  @spec search_lists(keyword()) :: {:ok, Cnpja.CnpjListPage.t()} | {:error, Cnpja.Error.t()}
  def search_lists(opts \\ []) do
    with {:ok, body} <- Client.get("/list", build_query(opts), sdk_opts(opts)) do
      {:ok, Cnpja.CnpjListPage.from_map(body)}
    end
  end

  @doc """
  Fetches a saved list by id (includes `items`).
  """
  @spec get_list(String.t(), keyword()) ::
          {:ok, Cnpja.CnpjList.t()} | {:error, Cnpja.Error.t()}
  def get_list(list_id, opts \\ []) do
    with {:ok, body} <- Client.get("/list/#{list_id}", [], sdk_opts(opts)) do
      {:ok, Cnpja.CnpjList.from_map(body)}
    end
  end

  @doc """
  Updates a saved list (`:title`, `:description`, and/or `:items`).
  """
  @spec update_list(String.t(), keyword() | map(), keyword()) ::
          {:ok, Cnpja.CnpjList.t()} | {:error, Cnpja.Error.t()}
  def update_list(list_id, attrs, opts \\ []) do
    {attrs, opts} = split_attrs_opts(attrs, opts)

    with {:ok, body} <- Client.patch("/list/#{list_id}", build_body(attrs), sdk_opts(opts)) do
      {:ok, Cnpja.CnpjList.from_map(body)}
    end
  end

  @doc """
  Deletes a saved list.
  """
  @spec delete_list(String.t(), keyword()) :: :ok | {:error, Cnpja.Error.t()}
  def delete_list(list_id, opts \\ []) do
    Client.delete("/list/#{list_id}", sdk_opts(opts))
  end

  @doc """
  Starts an asynchronous export of a saved list (Excel + JSON zip).

  ## Options (export job)

  Pass enrichment options as the second argument (keyword or map):

  - `:simples` / `:simples_history`
  - `:registrations` / `:registrations_source`
  - `:suframa` / `:geocoding`
  - `:strategy` / `:max_age` / `:max_stale`

  ## Example

      {:ok, %{id: export_id}} =
        Cnpja.create_list_export(list_id, simples: true, geocoding: true)

      {:ok, export} = Cnpja.get_list_export(list_id, export_id)
      # poll until export.status == "COMPLETED"
  """
  @spec create_list_export(String.t(), keyword() | map(), keyword()) ::
          {:ok, Cnpja.CnpjListExportId.t()} | {:error, Cnpja.Error.t()}
  def create_list_export(list_id, export_opts \\ [], opts \\ []) do
    body = %{"options" => build_body(export_opts)}

    with {:ok, resp} <- Client.post("/list/#{list_id}/export", body, sdk_opts(opts)) do
      {:ok, Cnpja.CnpjListExportId.from_map(resp)}
    end
  end

  @doc """
  Lists export jobs for a saved list.

  ## Options

  - `:token` — pagination cursor
  - `:limit` — page size
  """
  @spec search_list_exports(String.t(), keyword()) ::
          {:ok, Cnpja.CnpjListExportPage.t()} | {:error, Cnpja.Error.t()}
  def search_list_exports(list_id, opts \\ []) do
    with {:ok, body} <- Client.get("/list/#{list_id}/export", build_query(opts), sdk_opts(opts)) do
      {:ok, Cnpja.CnpjListExportPage.from_map(body)}
    end
  end

  @doc """
  Fetches a single export job (status, progress, download links).
  """
  @spec get_list_export(String.t(), String.t(), keyword()) ::
          {:ok, Cnpja.CnpjListExport.t()} | {:error, Cnpja.Error.t()}
  def get_list_export(list_id, export_id, opts \\ []) do
    with {:ok, body} <-
           Client.get("/list/#{list_id}/export/#{export_id}", [], sdk_opts(opts)) do
      {:ok, Cnpja.CnpjListExport.from_map(body)}
    end
  end

  # ---------------------------------------------------------------------------
  # Internals
  # ---------------------------------------------------------------------------

  defp sdk_opts(opts), do: Keyword.take(opts, @sdk_keys)

  # Allow SDK opts (api_key, base_url, …) mixed into keyword attrs for create/update.
  defp split_attrs_opts(attrs, opts) when is_list(attrs) do
    sdk = Keyword.take(attrs, @sdk_keys)
    {Keyword.drop(attrs, @sdk_keys), Keyword.merge(sdk, opts)}
  end

  defp split_attrs_opts(attrs, opts) when is_map(attrs), do: {attrs, opts}

  defp build_query(opts) do
    opts
    |> Keyword.drop(@sdk_keys)
    |> Enum.map(fn {k, v} -> {Map.get(@param_map, k, to_string(k)), v} end)
  end

  # `/simples` uses `history`; accept `:simples_history` as alias.
  defp normalize_simples_opts(opts) do
    case Keyword.pop(opts, :simples_history) do
      {nil, opts} -> opts
      {val, opts} -> Keyword.put_new(opts, :history, val)
    end
  end

  defp build_body(attrs) when is_list(attrs) do
    attrs
    |> Keyword.drop(@sdk_keys)
    |> Map.new(fn {k, v} -> {body_key(k), body_value(k, v)} end)
  end

  defp build_body(attrs) when is_map(attrs) do
    Map.new(attrs, fn
      {k, v} when is_atom(k) -> {body_key(k), body_value(k, v)}
      {k, v} when is_binary(k) -> {k, v}
    end)
  end

  defp body_key(k), do: Map.get(@body_key_map, k, to_string(k))

  defp body_value(:query, v) when is_list(v) do
    Map.new(build_query(v))
  end

  defp body_value(:query, v) when is_map(v), do: v

  defp body_value(:options, v) when is_list(v) or is_map(v), do: build_body(v)

  defp body_value(:registrations, v) when is_list(v), do: v
  defp body_value(_k, v), do: v
end
