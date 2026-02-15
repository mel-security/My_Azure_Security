function Mask-Email {
    param(
        [Parameter(Mandatory)]
        [string]$Email
    )

    if ($Email -notmatch '^(?<local>[^@]+)@(?<domain>.+)$') {
        return '***'
    }

    $local = $Matches.local
    $domain = $Matches.domain
    $first = $local.Substring(0, 1)
    return "{0}***@{1}" -f $first, $domain
}
