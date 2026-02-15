function Wait-ComplianceSearchCompleted {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$SearchName,
        [int]$TimeoutSeconds = 300,
        [int]$PollIntervalSeconds = 5
    )

    $deadline = (Get-Date).ToUniversalTime().AddSeconds($TimeoutSeconds)
    do {
        $status = Get-ComplianceSearchStatus -SearchName $SearchName
        if ($status.Status -eq 'Completed') {
            return $status
        }

        Start-Sleep -Seconds $PollIntervalSeconds
    } while ((Get-Date).ToUniversalTime() -lt $deadline)

    throw "Timeout waiting for compliance search '$SearchName' to complete."
}
