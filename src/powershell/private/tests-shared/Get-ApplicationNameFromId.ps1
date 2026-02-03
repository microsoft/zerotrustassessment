function Get-ApplicationNameFromId {
    <#
    .SYNOPSIS
        Resolves application GUIDs to display names from the database.

    .DESCRIPTION
        Takes an array of targets (GUIDs or strings) and resolves GUIDs to application display names
        by querying the ServicePrincipal and Application tables in the database.

    .PARAMETER TargetsArray
        Array of target values (GUIDs or strings like 'AllApplications')

    .PARAMETER Database
        Database connection to query

    .EXAMPLE
        $resolved = Get-ApplicationNameFromId -TargetsArray $targets -Database $db
        Returns an array of resolved display names

    .OUTPUTS
        Array of strings (resolved names or original values)
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [array]$TargetsArray,

        [Parameter(Mandatory = $true)]
        $Database
    )

    $displayArray = @()

    foreach ($target in $TargetsArray) {
        # Check if it's a valid GUID
        try {
            [void][System.Guid]::Parse($target)
            # It's a GUID, try to resolve it using a single UNION query
            try {
                $sqlApp = "SELECT displayName FROM ServicePrincipal WHERE id = '$target' OR appId = '$target' UNION SELECT displayName FROM Application WHERE id = '$target' OR appId = '$target' LIMIT 1"
                $resolvedApp = Invoke-DatabaseQuery -Database $Database -Sql $sqlApp
                if ($resolvedApp) {
                    $displayArray += $resolvedApp.displayName
                } else {
                    $displayArray += $target
                }
            }
            catch {
                $displayArray += $target
            }
        }
        catch {
            # Not a GUID, display as-is
            $displayArray += $target
        }
    }

    return $displayArray
}
