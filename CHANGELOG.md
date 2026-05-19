# Changelog

## [0.1.0] - 2026-05-19

### Added

- Full coverage of all 17 CNPJá API endpoints
- Typed structs for all API responses (`Cnpja.Office`, `Cnpja.Company`, `Cnpja.Zip`, etc.)
- Tagged tuple error handling — `{:ok, struct}` / `{:error, %Cnpja.Error{}}`
- Support for configuration via `config.exs` and per-call `api_key:` option
- Bypass-based integration tests for all endpoints
- ExDoc documentation published on HexDocs
