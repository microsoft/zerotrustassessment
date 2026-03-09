function Get-UserNameFromId {
    <#
    .SYNOPSIS
        Resolves user GUIDs to display names from the database.

    .DESCRIPTION
        Takes an array of targets (GUIDs or strings) and resolves GUIDs to user display names
        by querying the User table in the database.

    .PARAMETER TargetsArray
        Array of target values (GUIDs or strings like 'AllUsers')

    .PARAMETER Database
        Database connection to query

    .EXAMPLE
        $resolved = Get-UserNameFromId -TargetsArray $targets -Database $db
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
            $sqlUser = "SELECT id, displayName FROM User WHERE id IN ($guidInClause)"
            $resolvedUsers = Invoke-DatabaseQuery -Database $Database -Sql $sqlUser

            # 3. Build Lookup Hash
            foreach ($user in $resolvedUsers) {
                if (-not [string]::IsNullOrEmpty($user.displayName)) {
                    # Handle DB returning Guid objects by forcing string conversion for keys
                    if ($user.id) { $targetMap["$($user.id)"] = $user.displayName }
                }
            }
        }
        catch {
            Write-PSFMessage -Level Warning -Message "Failed to resolve user GUIDs from database: $_"
        }
    }

    # 4. Reconstruct Output
    foreach ($target in $TargetsArray) {
        $displayArray += $targetMap[$target]
    }

    # Comma operator prevents PowerShell from unrolling single-element arrays
    return ,$displayArray
}
