function Get-ZtPercentLabel {
    [CmdletBinding()]
    param($value, $total)

    $percent = ($value / $total) * 100

    if ($percent -lt 0 -or $percent -gt 100) {
        return "0%"
    }

    if ($percent -gt 0 -and $percent -lt 1) {
        return "less than 1%"
    }
    else{
        $percentRounded = [math]::Round($percent, 1)
        return "$percentRounded%"
    }
}
