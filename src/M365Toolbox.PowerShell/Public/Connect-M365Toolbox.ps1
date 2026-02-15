function Connect-M365Toolbox {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidatePattern('.+@.+')]
        [string]$UserPrincipalName
    )

    try {
        Import-Module ExchangeOnlineManagement -ErrorAction Stop

        Connect-ExchangeOnline -UserPrincipalName $UserPrincipalName -ShowBanner:$false -ShowProgress:$false -ErrorAction Stop | Out-Null
        Connect-IPPSSession -UserPrincipalName $UserPrincipalName -ErrorAction Stop | Out-Null

        Assert-M365CommandAvailable -CommandName 'New-ComplianceSearch' -Hint "Verify Security & Compliance permissions and that Connect-IPPSSession succeeded."
        Assert-M365CommandAvailable -CommandName 'New-ComplianceSearchAction' -Hint "If missing, update ExchangeOnlineManagement and reconnect: Install-Module ExchangeOnlineManagement -Force"

        $result = [PSCustomObject]@{
            Connected = $true
            TimestampUtc = (Get-Date).ToUniversalTime()
            UserPrincipalName = (Mask-Email -Email $UserPrincipalName)
        }

        Write-ToolboxAuditLog -Action 'Connect' -Operator $UserPrincipalName -Parameters @{ UserPrincipalName = $UserPrincipalName } | Out-Null
        return $result
    } catch {
        Write-Error "Connection failed: $($_.Exception.Message)"
        return [PSCustomObject]@{
            Connected = $false
            TimestampUtc = (Get-Date).ToUniversalTime()
            UserPrincipalName = (Mask-Email -Email $UserPrincipalName)
            Error = $_.Exception.Message
        }
    }
}
