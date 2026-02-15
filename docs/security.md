# Security principles

- No secret storage in repository or local config files.
- Authentication is interactive through Exchange Online modules at runtime.
- Logs avoid PII:
  - Email values masked (`a***@domain.tld`).
  - Input strings also hashed (SHA256) for traceability.
  - Never store message body/content preview.
- Destructive actions:
  - `Invoke-PhishingPurge` uses `SupportsShouldProcess`.
  - HardDelete disabled by default in UI flow.
  - HardDelete requires both preview flag and typed confirmation.
- Audit logs generated for Search start, Preview, and Purge actions.

- Runtime safety check verifies required compliance cmdlets are loaded after connection (`New-ComplianceSearch`, `New-ComplianceSearchAction`).
