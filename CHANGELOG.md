# Changelog

## [0.1.3] - 2026-05-19

### Fixed

- `Office.suframa` and `Rfb.suframa` type corrected from `Suframa.t() | nil` to `[Suframa.t()]` — the API returns an array
- `Office.links` and `Rfb.links` type corrected from `OfficeLinks.t() | nil` to `[Link.t()]` — the API returns an array of `{type, url}` objects; `Cnpja.OfficeLinks` replaced by `Cnpja.Link`
- `Company.id` and `CompanyRef.id` type corrected from `integer()` to `String.t()` — the API returns a string (e.g. `"37335118"`)
- RFB, Simples, CCC, and SUFRAMA endpoints corrected to use `taxId` as a **query param** instead of a path segment (e.g. `/rfb?taxId=...` not `/rfb/37335118000180`)
- All search query param names corrected from camelCase (`simplesOptant`, `stateIn`) to API dot-notation (`company.simples.optant.eq`, `address.state.in`)
- `get_ccc/3` `states` argument now sent as `states=` query param instead of a path segment
- Removed unreachable `parse_error_body/1` fallback clause from `Cnpja.Client`

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
