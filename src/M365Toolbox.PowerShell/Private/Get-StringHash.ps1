function Get-StringHash {
    param(
        [Parameter(Mandatory)]
        [string]$Value
    )

    $bytes = [System.Text.Encoding]::UTF8.GetBytes($Value)
    $hash = [System.Security.Cryptography.SHA256]::HashData($bytes)
    -join ($hash | ForEach-Object { $_.ToString('x2') })
}
