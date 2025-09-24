# Convert the risk level to uppercase format for the first letter.
function Get-RiskStateLabel {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        # Risk level to format
        [string] $RiskState
    )

    process {
        if([System.String]::IsNullOrEmpty($RiskState)) {
            return $null
        }
        $riskStateList = @{
            "none" = "None"
            "confirmedSafe" = "Confirmed Safe"
            "remediated" = "Remediated"
            "dismissed" = "Dismissed"
            "atRisk" = "At Risk"
        }
        return $riskStateList[$RiskState]
    }
}
