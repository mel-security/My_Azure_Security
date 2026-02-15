function New-PhishingPreview {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$SearchName,
        [Parameter(Mandatory)]
        [string]$Operator
    )

    $actionName = "${SearchName}_Preview"
    $action = New-ComplianceSearchAction -SearchName $SearchName -Preview -ErrorAction Stop

    Write-ToolboxAuditLog -Action 'PreviewStart' -Operator $Operator -Parameters @{
        SearchName = $SearchName
        ActionName = $actionName
    } | Out-Null

    return $action
}
