# Changelog

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
