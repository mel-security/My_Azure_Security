# M365Toolbox (MVP)

MVP Windows desktop tool to orchestrate Microsoft 365 phishing response actions using PowerShell automation (Exchange Online + Purview compliance search).

## Prerequisites
- Windows workstation
- .NET SDK 8.0+
- PowerShell 7.x
- Runtime PowerShell modules (installed locally, not vendored):
  - `ExchangeOnlineManagement`
- M365 roles/permissions (example):
  - Exchange admin capabilities for Exchange Online connectivity
  - Purview/Compliance permissions to create searches, previews and purge actions

## Repository layout
- `src/M365Toolbox.PowerShell/`: internal module with phishing workflow functions and safeguards
- `src/M365Toolbox.Desktop/`: .NET 8 WPF desktop UI and runspace host
- `tests/`: Pester tests (offline)
- `docs/`: architecture and security notes
- `.github/workflows/ci.yml`: build + tests pipeline

## Local run
```powershell
# PowerShell module tests
pwsh -NoProfile -Command "Invoke-Pester tests/M365Toolbox.PowerShell.Tests.ps1"

# Build desktop app
 dotnet build src/M365Toolbox.Desktop/M365Toolbox.Desktop.csproj
```

## Security guardrails
- No secrets are stored in this repository.
- Logs mask email addresses and hash sensitive parameters.
- HardDelete is safeguarded in both PowerShell and UI flow:
  - disabled until search completed + preview executed
  - requires typed confirmation: `DELETE <SearchName>`
- Audit logs are written locally in `%LOCALAPPDATA%\M365Toolbox\Logs\audit.jsonl`.
