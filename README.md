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

## Troubleshooting - `New-ComplianceSearchAction` not found
If you get `CommandNotFoundException` for `New-ComplianceSearchAction`:
1. Ensure `ExchangeOnlineManagement` is installed and up to date.
2. Connect with both:
   - `Connect-ExchangeOnline`
   - `Connect-IPPSSession`
3. Validate command availability:
   - `Get-Command New-ComplianceSearchAction`

The module now validates command availability and returns an explicit hint when the cmdlet is missing.

## Install dotnet + pwsh in this Linux container
```bash
# PowerShell (pwsh)
apt-get update
apt-get install -y wget apt-transport-https software-properties-common
wget -q https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb
dpkg -i packages-microsoft-prod.deb
apt-get update
apt-get install -y powershell

# .NET SDK 8
apt-get install -y dotnet-sdk-8.0
```

## Security guardrails
- No secrets are stored in this repository.
- Logs mask email addresses and hash sensitive parameters.
- HardDelete is safeguarded in both PowerShell and UI flow:
  - disabled until search completed + preview executed
  - requires typed confirmation: `DELETE <SearchName>`
- Audit logs are written locally in `%LOCALAPPDATA%\M365Toolbox\Logs\audit.jsonl`.
