function New-PhishingComplianceSearch {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$SearchName,
        [Parameter(Mandatory)]
        [ValidateSet('SenderEmail', 'Domain')]
        [string]$Mode,
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Value,
        [Parameter(Mandatory)]
        [datetime]$StartUtc,
        [Parameter(Mandatory)]
        [datetime]$EndUtc,
        [string]$ExchangeLocation = 'All',
        [Parameter(Mandatory)]
        [string]$Operator
    )

    $query = New-ContentMatchQuery -Mode $Mode -Value $Value -StartUtc $StartUtc -EndUtc $EndUtc

    $search = New-ComplianceSearch -Name $SearchName -ExchangeLocation $ExchangeLocation -ContentMatchQuery $query -ErrorAction Stop
    Start-ComplianceSearch -Identity $SearchName -ErrorAction Stop | Out-Null

    Write-ToolboxAuditLog -Action 'SearchStart' -Operator $Operator -Parameters @{
        SearchName = $SearchName
        Mode = $Mode
        Value = $Value
        StartUtc = $StartUtc.ToUniversalTime().ToString('o')
        EndUtc = $EndUtc.ToUniversalTime().ToString('o')
    } | Out-Null

    return $search
}
