function Assert-M365CommandAvailable {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$CommandName,
        [string]$Hint
    )

    $command = Get-Command -Name $CommandName -ErrorAction SilentlyContinue
    if (-not $command) {
        $baseMessage = "Required command '$CommandName' is not available in the current session."
        if ($Hint) {
            throw "$baseMessage $Hint"
        }

        throw $baseMessage
    }
}
