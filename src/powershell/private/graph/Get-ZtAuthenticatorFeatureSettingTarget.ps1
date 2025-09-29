function Get-ZtAuthenticatorFeatureSettingTarget {
    <#
    .SYNOPSIS
    Retrieves the display name for an authenticator feature setting target.

    .DESCRIPTION
    This function translates authenticator feature setting target IDs into human-readable display names.
    It handles special cases like 'all_users' and the null UUID for exclusions, and can resolve group names
    for group-based targets.

    .PARAMETER Target
    The target object containing id and targetType properties.

    .EXAMPLE
    Get-ZtAuthenticatorFeatureSettingTarget -Target $includeTarget

    .EXAMPLE
    Get-ZtAuthenticatorFeatureSettingTarget -Target $excludeTarget
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [object]$Target
    )

    if ($Target.id -eq 'all_users') {
        return "All users"
    }
    elseif ($Target.id -eq '00000000-0000-0000-0000-000000000000') {
        return "No exclusions"
    }
    else {
        if ($Target.targetType -eq 'group') {
            $group = Invoke-ZtGraphRequest -RelativeUri "groups/$($Target.id)" -ApiVersion 'v1.0'
            "Group: $($group.displayName)"
        }
    }
}
