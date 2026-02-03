function Get-ApplicationNameFromId {
    <#
    .SYNOPSIS
        Resolves application GUIDs to display names from the database.

    .DESCRIPTION
        Takes an array of targets (GUIDs or strings) and resolves GUIDs to application display names
        by querying the database for ServicePrincipal and Application data.

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

    # First pass: Separate GUIDs from non-GUIDs and build lookup map
    $guidList = @()
    $targetMap = @{}

    foreach ($target in $TargetsArray) {
        try {
            [void][System.Guid]::Parse($target)
            $guidList += $target
            $targetMap[$target] = $target  # Default to GUID if not found
        }
        catch {
            # Not a GUID, use as-is
            $targetMap[$target] = $target
        }
    }

    # If we have GUIDs, resolve them all in a single query
    if ($guidList.Count -gt 0) {
        try {
            # Build IN clause for all GUIDs (escape single quotes for defense-in-depth)
            $guidInClause = ($guidList | ForEach-Object { "'$($_.Replace("'", "''"))'" }) -join ','

            # Single query to resolve all GUIDs at once
            $sqlApp = @"
SELECT id, appId, displayName FROM ServicePrincipal WHERE id IN ($guidInClause) OR appId IN ($guidInClause)
UNION ALL
SELECT id, appId, displayName FROM Application WHERE id IN ($guidInClause) OR appId IN ($guidInClause)
"@
            $resolvedApps = Invoke-DatabaseQuery -Database $Database -Sql $sqlApp

            # Map resolved apps back to GUIDs in targetMap
            foreach ($app in $resolvedApps) {
                if (-not $app.displayName) { continue }

                # Check if any GUID in our list matches this app's id or appId
                foreach ($guid in $guidList) {
                    if ($app.id -eq $guid -or $app.appId -eq $guid) {
                        $targetMap[$guid] = $app.displayName
                        break
                    }
                }
            }
        }
        catch {
            Write-PSFMessage -Level Warning -Message "Failed to resolve application GUIDs from database: $_"
        }
    }

    # Build final array in original order
    foreach ($target in $TargetsArray) {
        $displayArray += $targetMap[$target]
    }

    return , $displayArray
}
