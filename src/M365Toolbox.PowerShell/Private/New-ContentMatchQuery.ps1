function New-ContentMatchQuery {
    param(
        [Parameter(Mandatory)]
        [ValidateSet('SenderEmail', 'Domain')]
        [string]$Mode,
        [Parameter(Mandatory)]
        [string]$Value,
        [Parameter(Mandatory)]
        [datetime]$StartUtc,
        [Parameter(Mandatory)]
        [datetime]$EndUtc
    )

    if ($EndUtc -lt $StartUtc) {
        throw 'EndUtc must be greater than or equal to StartUtc.'
    }

    $startDate = $StartUtc.ToUniversalTime().ToString('yyyy-MM-dd')
    $endDate = $EndUtc.ToUniversalTime().ToString('yyyy-MM-dd')

    $actorFilter = switch ($Mode) {
        'SenderEmail' { "from:$Value" }
        'Domain' { "participants:$Value" }
    }

    "kind:email AND ($actorFilter) AND (received>=$startDate AND received<=$endDate)"
}
