# Convert the risk level to uppercase format for the first letter.
function Get-FormattedRiskLevel {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        # Risk level to format
        [Parameter(Mandatory = $true, Position = 0)]
        [string] $RiskLevel
    )

    process {
        $firstLetter = $RiskLevel.Substring(0, 1).ToUpper()
        $rest = $RiskLevel.Substring(1)
        return $firstLetter + $rest
    }
}
