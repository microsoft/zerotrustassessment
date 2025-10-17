# Convert the policy state to uppercase format for the first letter.
function Get-FormattedPolicyState {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        # Policy state to format
        [string] $PolicyState
    )

    process {
        if([System.String]::IsNullOrEmpty($PolicyState)) {
            return $null
        }
        $firstLetter = $PolicyState.Substring(0, 1).ToUpper()
        $rest = $PolicyState.Substring(1)
        return $firstLetter + $rest
    }
}
