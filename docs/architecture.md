# Architecture MVP - M365Toolbox

## Components
- **M365Toolbox.Desktop (WPF/.NET 8)**: local Windows UI and workflow orchestration.
- **PowerShellRunner**: hosts `System.Management.Automation` runspace pool in-process.
- **M365Toolbox.PowerShell module**: wraps Exchange Online + Purview commands with safeguards.
- **Audit logs**: local JSONL in `%LOCALAPPDATA%/M365Toolbox/Logs`.

## Flow (text diagram)
1. Login tab: operator enters UPN.
2. `Connect-M365Toolbox` calls `Connect-ExchangeOnline` + `Connect-IPPSSession`.
3. Phishing Response tab:
   - Build KQL from sender/domain + UTC range.
   - `New-PhishingComplianceSearch` then poll `Get-ComplianceSearchStatus`.
   - Run `New-PhishingPreview` and check status.
   - Purge path:
     - SoftDelete available after search completed.
     - HardDelete available only after preview + typed confirmation `DELETE <SearchName>`.
4. Every sensitive action writes masked/hash-only audit entries.
