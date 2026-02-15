function Get-ComplianceSearchStatus {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$SearchName
    )

    Get-ComplianceSearch -Identity $SearchName -ErrorAction Stop |
        Select-Object Name, Status, JobRunId, Items, SuccessResults
}
