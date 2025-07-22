<#
.SYNOPSIS
    Parses a date string and returns it in a formatted manner.
.DESCRIPTION
    Attempts to parse a date string using TryParse. If successful, returns the date in "yyyy-MM-dd HH:mm:ss" format.
    If parsing fails, returns the original string. If null or empty, returns "Unknown".
.PARAMETER DateString
    The date string to parse and format.
.EXAMPLE
    Get-FormattedDate -DateString "2023-05-15T13:45:30Z"
    Returns: "2023-05-15 13:45:30"
#>
function Get-FormattedDate {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string]$DateString
    )

    if ([string]::IsNullOrEmpty($DateString)) {
        return "Unknown"
    }

    $parsedDate = [datetime]::MinValue
    if ([datetime]::TryParse($DateString, [ref]$parsedDate)) {
        return $parsedDate.ToString("yyyy-MM-dd")
    }
    else {
        # Try to parse as MM/dd/yyyy format specifically
        if ([datetime]::TryParseExact($DateString, "MM/dd/yyyy", $null, [System.Globalization.DateTimeStyles]::None, [ref]$parsedDate)) {
            return $parsedDate.ToString("yyyy-MM-dd")
        }
        else {
            # If both parsing attempts fail, return the original string
            return $DateString
        }
    }
}
