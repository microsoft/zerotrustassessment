<#
.SYNOPSIS
    Checks if an assignment policy target scope applies to external users.

.DESCRIPTION
    Determines if the target scope value indicates external/guest users.

.PARAMETER TargetScope
    The allowedTargetScope value from an assignment policy.

.OUTPUTS
    Boolean - Returns $true if the scope applies to external users, $false otherwise.

.EXAMPLE
    $isExternal = Test-ZtExternalUserScope -TargetScope $policy.allowedTargetScope

.EXAMPLE
    if (Test-ZtExternalUserScope -TargetScope "allExternalUsers") {
        # Process external user policy
    }
#>
function Test-ZtExternalUserScope {
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory = $false)]
        [string]$TargetScope
    )

    if ([string]::IsNullOrEmpty($TargetScope)) {
        return $false
    }

    return $TargetScope -in @(
        "specificConnectedOrganizationUsers",
        "allConfiguredConnectedOrganizationUsers",
        "allExternalUsers"
    )
}
