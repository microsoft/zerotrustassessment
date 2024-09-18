function Get-FormattedDate {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $Date
    )
    $dateValue = [DateTime]::MinValue
    if([DateTime]::TryParse($Date, [ref]$dateValue)){
        return $dateValue.ToString("yyyy-MM-dd")
    }
    else {
        return $Date
    }
}
