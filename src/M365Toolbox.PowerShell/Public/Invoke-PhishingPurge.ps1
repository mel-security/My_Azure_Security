function Invoke-PhishingPurge {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param(
        [Parameter(Mandatory)]
        [string]$SearchName,
        [Parameter(Mandatory)]
        [ValidateSet('SoftDelete', 'HardDelete')]
        [string]$PurgeType,
        [Parameter(Mandatory)]
        [string]$Operator,
        [bool]$PreviewExecuted = $false,
        [string]$TypedConfirmation
    )

    if ($PurgeType -eq 'HardDelete') {
        if (-not $PreviewExecuted) {
            throw 'HardDelete requires a completed preview first.'
        }

        $expected = "DELETE $SearchName"
        if ($TypedConfirmation -cne $expected) {
            throw "HardDelete requires typed confirmation exactly matching '$expected'."
        }
    }

    if ($PSCmdlet.ShouldProcess($SearchName, "Run purge: $PurgeType")) {
        $action = New-ComplianceSearchAction -SearchName $SearchName -Purge -PurgeType $PurgeType -Confirm:$false -ErrorAction Stop
        Write-ToolboxAuditLog -Action 'Purge' -Operator $Operator -Parameters @{
            SearchName = $SearchName
            PurgeType = $PurgeType
        } | Out-Null

        return $action
    }
}
