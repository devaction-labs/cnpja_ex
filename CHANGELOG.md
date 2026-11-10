# Changelog

## [0.2.1] - 2026-11-10

### Added

- `Cnpja.SimplesEvent` struct and `Cnpja.SimplesOpt.events` (upcoming IBS/CBS regular-regime events)
- `:phone_area_nin` filter for `search_offices/1`; documented the remaining phone, e-mail, address, since and exclusion filters

### Changed

- Dependencies updated (req 0.7.5, finch 0.24, mint 1.11)

### Fixed

- Typespecs of `Cnpja.Error.code` (`integer() | nil`) and `Cnpja.PersonMembershipCompany.id` (`String.t()`)

## [0.2.0] - 2026-07-21

### Breaking

- `Cnpja.Company.offices` is now `[Cnpja.CompanyOffice.t()]` (API subset without address)
- `Cnpja.Office.suframa` is now `[Cnpja.OfficeSuframa.t()]` (embedded summary, not full `Cnpja.Suframa`)
- `Cnpja.Rfb` no longer has `registrations`, `links`, `suframa`, or `company` fields (not returned by `/rfb`)
- `get_company/2` no longer documents or sends non-existent `:simples` / `:simples_history` query options

### Added

- **Lists API** (saved CNPJ collections + async export):
  - `create_list/2`, `search_lists/1`, `get_list/2`, `update_list/3`, `delete_list/2`
  - `create_list_export/3`, `search_list_exports/2`, `get_list_export/3`
  - Structs: `Cnpja.CnpjList`, `Cnpja.CnpjListSummary`, `Cnpja.CnpjListPage`,
    `Cnpja.CnpjListExport`, `Cnpja.CnpjListExportPage`, `Cnpja.CnpjListExportId`
- `Cnpja.CompanyOffice` and `Cnpja.OfficeSuframa` response structs
- `Cnpja.Error.code` from API error payloads
- `search_persons/1` filter `:person_country_nin` (`country.id.nin`)
- Client support for `POST`, `PATCH`, `DELETE` (required by Lists API)
- Configurable `:receive_timeout` (config and per-call option; default 30s)
- Query params that are lists are joined as comma-separated values

### Fixed

- `get_simples/2` now sends `history=` (API param); `:simples_history` remains as a documented alias
- Nested company offices and office-embedded SUFRAMA parse correctly against real OpenAPI DTOs

### Improved

- README covers lists/export and updated dependency version
- Expanded test coverage for lists, history param, error codes, and nested DTOs

## [0.1.3] - 2026-05-19

### Fixed

- `Office.suframa` and `Rfb.suframa` type corrected from `Suframa.t() | nil` to `[Suframa.t()]` — the API returns an array
- `Office.links` and `Rfb.links` type corrected from `OfficeLinks.t() | nil` to `[Link.t()]` — the API returns an array of `{type, url}` objects; `Cnpja.OfficeLinks` replaced by `Cnpja.Link`
- `Company.id` and `CompanyRef.id` type corrected from `integer()` to `String.t()` — the API returns a string (e.g. `"37335118"`)
- RFB, Simples, CCC, and SUFRAMA endpoints corrected to use `taxId` as a **query param** instead of a path segment (e.g. `/rfb?taxId=...` not `/rfb/37335118000180`)
- All search query param names corrected from camelCase (`simplesOptant`, `stateIn`) to API dot-notation (`company.simples.optant.eq`, `address.state.in`)
- `get_ccc/3` `states` argument now sent as `states=` query param instead of a path segment
- Removed unreachable `parse_error_body/1` fallback clause from the HTTP client

### Added

- `Cnpja.Link` struct — public document link with `type` and `url` fields, replacing `Cnpja.OfficeLinks`
- Extended `search_offices/1` with full set of filter params: `founded_gte/lte`, `status_date_gte/lte`, `special_date_gte/lte`, street/district/number/details filters, phone/email field-level filters, `activity_in/nin`, `simples_since_gte/lte`, `simei_since_gte/lte`, and more

### Improved

- Test suite expanded to 76 tests with 100% line coverage

## [0.1.2] - 2026-05-19

### Fixed

- API paths corrected from plural to singular: `/offices` → `/office`, `/companies` → `/company`, `/persons` → `/person`. All previous versions returned 404 on these endpoints when called against the real CNPJá API.

## [0.1.1] - 2026-05-19

### Added

- `Cnpja.CompanyRef` — lightweight company reference embedded in `Office` and `Rfb` to avoid circular parsing
- `Cnpja.SizeLabel` — company size struct with `id`, `acronym`, and `text` fields (distinct from `Label`)
- `Cnpja.PersonMembership` and `Cnpja.PersonMembershipCompany` — typed person membership records
- `status_date`, `reason`, `special_date`, `special` fields on `Cnpja.Office` and `Cnpja.Rfb`
- `name`, `equity`, `nature`, `size`, `jurisdiction` fields on `Cnpja.Rfb`
- `jurisdiction` field on `Cnpja.Company`
- `performed` field on `Cnpja.Activity`
- Full `Cnpja.Suframa` rewrite: `since`, `head`, `approved` (boolean), `approval_date`, `address`, `phones`, `emails`, `incentives`
- Address parsing accepts both `"zip"` and `"code"` field names
- Extended `@camel_map` covering all search, image, and certificate query parameters

### Improved

- Test suite expanded to 74 tests with 98.3% line coverage
- Network error path and plain-text error body now tested

## [0.1.0] - 2026-05-19

### Added

- Full coverage of all 17 CNPJá API endpoints
- Typed structs for all API responses (`Cnpja.Office`, `Cnpja.Company`, `Cnpja.Zip`, etc.)
- Tagged tuple error handling — `{:ok, struct}` / `{:error, %Cnpja.Error{}}`
- Support for configuration via `config.exs` and per-call `api_key:` option
- Bypass-based integration tests for all endpoints
- ExDoc documentation published on HexDocs
