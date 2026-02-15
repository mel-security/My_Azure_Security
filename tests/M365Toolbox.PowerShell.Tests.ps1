Import-Module "$PSScriptRoot/../src/M365Toolbox.PowerShell/M365Toolbox.psd1" -Force

Describe 'New-ContentMatchQuery' {
    InModuleScope M365Toolbox {
        It 'builds sender email query' {
            $q = New-ContentMatchQuery -Mode SenderEmail -Value 'alice@example.com' -StartUtc ([datetime]'2024-01-01') -EndUtc ([datetime]'2024-01-07')
            $q | Should -Be 'kind:email AND (from:alice@example.com) AND (received>=2024-01-01 AND received<=2024-01-07)'
        }

        It 'builds domain query' {
            $q = New-ContentMatchQuery -Mode Domain -Value 'example.com' -StartUtc ([datetime]'2024-01-01') -EndUtc ([datetime]'2024-01-07')
            $q | Should -Be 'kind:email AND (participants:example.com) AND (received>=2024-01-01 AND received<=2024-01-07)'
        }

        It 'throws on invalid date range' {
            { New-ContentMatchQuery -Mode Domain -Value 'example.com' -StartUtc ([datetime]'2024-01-07') -EndUtc ([datetime]'2024-01-01') } | Should -Throw
        }
    }
}

Describe 'Invoke-PhishingPurge safeguards' {
    BeforeEach {
        Mock New-ComplianceSearchAction { [PSCustomObject]@{ Name = 'action' } }
        Mock Write-ToolboxAuditLog { }
    }

    It 'blocks hard delete without preview' {
        { Invoke-PhishingPurge -SearchName 'Case-1' -PurgeType HardDelete -Operator 'ops@example.com' -PreviewExecuted:$false -TypedConfirmation 'DELETE Case-1' -Confirm:$false } | Should -Throw
    }

    It 'blocks hard delete with wrong typed confirmation' {
        { Invoke-PhishingPurge -SearchName 'Case-1' -PurgeType HardDelete -Operator 'ops@example.com' -PreviewExecuted:$true -TypedConfirmation 'DELETE X' -Confirm:$false } | Should -Throw
    }

    It 'allows hard delete with preview and typed confirmation' {
        $result = Invoke-PhishingPurge -SearchName 'Case-1' -PurgeType HardDelete -Operator 'ops@example.com' -PreviewExecuted:$true -TypedConfirmation 'DELETE Case-1' -Confirm:$false
        $result.Name | Should -Be 'action'
    }
}
