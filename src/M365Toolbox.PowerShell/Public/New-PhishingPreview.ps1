function New-PhishingPreview {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$SearchName,
        [Parameter(Mandatory)]
        [string]$Operator
    )

    Assert-M365CommandAvailable -CommandName 'New-ComplianceSearchAction' -Hint "Command not found. Connect to Security & Compliance with Connect-IPPSSession and ensure ExchangeOnlineManagement is up to date."

    $actionName = "${SearchName}_Preview"
    $action = New-ComplianceSearchAction -SearchName $SearchName -Preview -ErrorAction Stop

    Write-ToolboxAuditLog -Action 'PreviewStart' -Operator $Operator -Parameters @{
        SearchName = $SearchName
        ActionName = $actionName
    } | Out-Null

    return $action
}
