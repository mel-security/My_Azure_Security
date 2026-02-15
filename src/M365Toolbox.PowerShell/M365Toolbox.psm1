Get-ChildItem -Path (Join-Path $PSScriptRoot 'Private') -Filter '*.ps1' | Sort-Object Name | ForEach-Object {
    . $_.FullName
}

Get-ChildItem -Path (Join-Path $PSScriptRoot 'Public') -Filter '*.ps1' | Sort-Object Name | ForEach-Object {
    . $_.FullName
}
