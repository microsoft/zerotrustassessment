function Get-ZtPercentLabel {
    [CmdletBinding()]
    param($value, $total)

    # Handle null, empty, or zero total to prevent division by zero
    if ($null -eq $total -or $total -eq 0) {
        return "0%"
    }

    # Handle null or invalid value
    if ($null -eq $value -or $value -lt 0) {
        return "0%"
    }

    try {
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
    catch {
        # Return safe default if any calculation fails
        return "0%"
    }
}
