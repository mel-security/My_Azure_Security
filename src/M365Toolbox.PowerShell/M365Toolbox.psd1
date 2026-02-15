@{
    RootModule        = 'M365Toolbox.psm1'
    ModuleVersion     = '0.1.0'
    GUID              = '15cf39fe-d963-4e22-97de-6173594063b1'
    Author            = 'M365Toolbox'
    CompanyName       = 'M365Toolbox'
    Copyright         = '(c) M365Toolbox'
    PowerShellVersion = '7.0'
    FunctionsToExport = @(
        'Connect-M365Toolbox',
        'New-PhishingComplianceSearch',
        'Get-ComplianceSearchStatus',
        'Wait-ComplianceSearchCompleted',
        'New-PhishingPreview',
        'Get-PhishingPreviewStatus',
        'Invoke-PhishingPurge',
        'Write-ToolboxAuditLog'
    )
    PrivateData = @{
        PSData = @{
            Tags       = @('M365', 'ExchangeOnline', 'Purview', 'Security')
            ProjectUri = 'https://github.com/example/M365Toolbox'
        }
    }
}
