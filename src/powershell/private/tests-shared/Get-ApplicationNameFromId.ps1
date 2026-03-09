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
        [string[]]$TargetsArray,

        [Parameter(Mandatory = $true)]
        $Database
    )

    $displayArray = @()
    $targetMap = @{}
    # Use HashSet for deduplication of GUIDs to query
    $guidsToQuery = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)

    # 1. Classification & Deduplication
    foreach ($target in $TargetsArray) {
        $targetMap[$target] = $target # Default fallback

        $guidRef = [System.Guid]::Empty
        if ([System.Guid]::TryParse($target, [ref]$guidRef)) {
            [void]$guidsToQuery.Add($target)
        }
    }

    # 2. Query
    if ($guidsToQuery.Count -gt 0) {
        try {
            # Build IN clause for all GUIDs
            $guidInClause = ($guidsToQuery | ForEach-Object { "'$($_.Replace("'", "''"))'" }) -join ','

            # Single query to resolve all GUIDs at once
            $sqlApp = @"
SELECT id, appId, displayName FROM ServicePrincipal WHERE id IN ($guidInClause) OR appId IN ($guidInClause)
UNION
SELECT id, appId, displayName FROM Application WHERE id IN ($guidInClause) OR appId IN ($guidInClause)
"@
            $resolvedApps = Invoke-DatabaseQuery -Database $Database -Sql $sqlApp

            # 3. Build Lookup Hash
            foreach ($app in $resolvedApps) {
                if (-not [string]::IsNullOrEmpty($app.displayName)) {
                    # Handle DB returning Guid objects by forcing string conversion for keys
                    if ($app.id)    { $targetMap["$($app.id)"]    = $app.displayName }
                    if ($app.appId) { $targetMap["$($app.appId)"] = $app.displayName }
                }
            }
        }
        catch {
            Write-PSFMessage -Level Warning -Message "Failed to resolve application GUIDs from database: $_"
        }
    }

    # 4. Reconstruct Output
    foreach ($target in $TargetsArray) {
        $displayArray += $targetMap[$target]
    }

    # Comma operator prevents PowerShell from unrolling single-element arrays
    return ,$displayArray
}
