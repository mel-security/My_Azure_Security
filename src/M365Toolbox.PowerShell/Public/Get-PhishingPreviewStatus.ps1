function Get-PhishingPreviewStatus {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$SearchName
    )

    Get-ComplianceSearchAction -Identity "${SearchName}_Preview" -ErrorAction Stop |
        Select-Object Name, Status, RunBy, JobEndTime
}
