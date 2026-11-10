# cnpja_ex

[![Hex.pm](https://img.shields.io/hexpm/v/cnpja_ex.svg)](https://hex.pm/packages/cnpja_ex)
[![Docs](https://img.shields.io/badge/hex-docs-blue.svg)](https://hexdocs.pm/cnpja_ex)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Elixir SDK for the [CNPJá API](https://cnpja.com) — real-time lookups for Brazilian CNPJ, CEP, Receita Federal, Simples Nacional, CCC, SUFRAMA, saved lists and bulk export.

## Installation

Add `cnpja_ex` to your dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:cnpja_ex, "~> 0.2.1"}
  ]
end
```

## Configuration

```elixir
# config/config.exs
config :cnpja_ex,
  api_key: System.get_env("CNPJA_API_KEY"),
  receive_timeout: 30_000
```

You can also pass options per call (useful for multi-tenant apps):

```elixir
Cnpja.get_office("37335118000180", api_key: "other-key", receive_timeout: 60_000)
```

## Quick start

```elixir
{:ok, office} = Cnpja.get_office("37335118000180")

office.alias          #=> "EMPRESA XYZ"
office.status.text    #=> "Ativa"
office.address.city   #=> "São Paulo"
```

## Available functions

| Function | Description |
|---|---|
| `Cnpja.get_credit/1` | Account credit balance |
| `Cnpja.get_zip/2` | Postal code (CEP) lookup |
| `Cnpja.get_company/2` | Company by CNPJ root (8 digits) |
| `Cnpja.get_office/2` | Establishment by full CNPJ (14 digits) |
| `Cnpja.get_office_map/2` | Establishment map image (PNG) |
| `Cnpja.get_office_street_view/2` | Street View image (JPEG) |
| `Cnpja.search_offices/1` | Search establishments with filters |
| `Cnpja.get_person/2` | Person by CNPJá ID |
| `Cnpja.search_persons/1` | Search persons with filters |
| `Cnpja.get_rfb/2` | Receita Federal establishment data |
| `Cnpja.get_rfb_certificate/2` | Comprovante de Situação Cadastral (PDF) |
| `Cnpja.get_simples/2` | Simples Nacional and MEI data |
| `Cnpja.get_simples_certificate/2` | Simples Nacional declaration (PDF) |
| `Cnpja.get_ccc/3` | State registrations from the CCC |
| `Cnpja.get_ccc_certificate/2` | CCC regularity certificate (PDF) |
| `Cnpja.get_suframa/2` | SUFRAMA enrollment data |
| `Cnpja.get_suframa_certificate/2` | SUFRAMA incentives certificate (PDF) |
| `Cnpja.create_list/2` | Create a saved CNPJ list |
| `Cnpja.search_lists/1` | Search saved lists |
| `Cnpja.get_list/2` | Get a saved list (with items) |
| `Cnpja.update_list/3` | Update a saved list |
| `Cnpja.delete_list/2` | Delete a saved list |
| `Cnpja.create_list_export/3` | Start async Excel/JSON export |
| `Cnpja.search_list_exports/2` | List export jobs for a list |
| `Cnpja.get_list_export/3` | Export status, progress and download links |

## Error handling

All lookup functions return `{:ok, struct}` or `{:error, %Cnpja.Error{}}`. No exceptions are raised.
`delete_list/2` returns `:ok` or `{:error, %Cnpja.Error{}}`.

```elixir
case Cnpja.get_office("37335118000180") do
  {:ok, office} ->
    office.alias

  {:error, %Cnpja.Error{status: 404}} ->
    "not found"

  {:error, %Cnpja.Error{status: 429, required: required, remaining: remaining}} ->
    "insufficient credits — need #{required}, have #{remaining}"

  {:error, %Cnpja.Error{status: 401}} ->
    "invalid API key"

  {:error, %Cnpja.Error{status: 400, code: code, constraints: constraints}} ->
    "validation error (#{code}): #{inspect(constraints)}"

  {:error, %Cnpja.Error{}} ->
    "unexpected error"
end
```

## Options — `get_office/2`

```elixir
Cnpja.get_office("37335118000180",
  simples: true,
  simples_history: true,
  registrations: "ALL",
  registrations_source: "CCC",
  suframa: true,
  geocoding: true,
  links: "RFB_CERTIFICATE,SIMPLES_CERTIFICATE",
  strategy: "CACHE_IF_ERROR",
  max_age: 45,
  max_stale: 365
)
```

## Saved lists and bulk export

Lists store CNPJs (or search filters) on your CNPJá account for asynchronous bulk export:

```elixir
{:ok, list} =
  Cnpja.create_list(
    title: "SP ativas",
    query: [state_in: "SP", status_in: "2"],
    limit: 1000
  )

{:ok, %{id: export_id}} =
  Cnpja.create_list_export(list.id, simples: true, geocoding: true)

{:ok, export} = Cnpja.get_list_export(list.id, export_id)
# poll until export.status == "COMPLETED"
export.links
#=> [%Cnpja.Link{type: "EXCEL", url: "..."}, %Cnpja.Link{type: "JSON_ZIP", url: "..."}]
```

## License

MIT © [devaction-labs](https://github.com/devaction-labs)
