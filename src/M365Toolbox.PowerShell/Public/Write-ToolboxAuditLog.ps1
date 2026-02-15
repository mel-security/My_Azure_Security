function Write-ToolboxAuditLog {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Action,
        [Parameter(Mandatory)]
        [string]$Operator,
        [hashtable]$Parameters = @{}
    )

    $logRoot = Join-Path ([Environment]::GetFolderPath('LocalApplicationData')) 'M365Toolbox/Logs'
    if (-not (Test-Path $logRoot)) {
        New-Item -Path $logRoot -ItemType Directory -Force | Out-Null
    }

    $sanitized = @{}
    foreach ($key in $Parameters.Keys) {
        $value = [string]$Parameters[$key]
        if ($value -match '@') {
            $sanitized[$key] = Mask-Email -Email $value
            $sanitized["${key}Hash"] = Get-StringHash -Value $value
        } else {
            $sanitized[$key] = $value
            $sanitized["${key}Hash"] = Get-StringHash -Value $value
        }
    }

    $entry = [ordered]@{
        TimestampUtc = (Get-Date).ToUniversalTime().ToString('o')
        Operator = Mask-Email -Email $Operator
        Action = $Action
        Parameters = $sanitized
    }

    $json = $entry | ConvertTo-Json -Compress -Depth 5
    Add-Content -Path (Join-Path $logRoot 'audit.jsonl') -Value $json
    return $entry
}
