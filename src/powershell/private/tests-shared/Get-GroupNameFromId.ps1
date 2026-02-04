function Get-GroupNameFromId {
    <#
    .SYNOPSIS
        Resolves group GUIDs to display names from Entra.

    .DESCRIPTION
        Takes an array of targets (GUIDs or strings) and resolves GUIDs to group display names
        by querying Entra via Microsoft Graph API.

    .PARAMETER TargetsArray
        Array of target values (GUIDs or strings like 'AllUsers')

    .EXAMPLE
        $resolved = Get-GroupNameFromId -TargetsArray $targets
        Returns an array of resolved display names

    .OUTPUTS
        Array of strings (resolved names or original values)
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$TargetsArray
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
        # Query each group from Entra
        foreach ($guid in $guidsToQuery) {
            try {
                $group = Invoke-ZtGraphRequest -RelativeUri "groups/$guid" -ApiVersion beta -ErrorAction SilentlyContinue
                if ($group -and $group.displayName) {
                    $targetMap[$guid] = $group.displayName
                }
            }
            catch {
                Write-PSFMessage -Level Warning -Message "Unable to resolve group GUID $guid : $_"
            }
        }
    }

    # 3. Reconstruct Output
    foreach ($target in $TargetsArray) {
        $displayArray += $targetMap[$target]
    }

    # Comma operator prevents PowerShell from unrolling single-element arrays
    return ,$displayArray
}
