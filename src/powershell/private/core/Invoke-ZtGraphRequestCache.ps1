<#
.SYNOPSIS
    Enhanced version of Invoke-MgGraphRequest that supports caching.
#>
Function Invoke-ZtGraphRequestCache {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [Uri] $Uri,

        [Parameter(Mandatory = $false)]
        [string] $Method = 'GET',

        [Parameter(Mandatory = $false)]
        [string] $OutputType,

        [Parameter(Mandatory = $false)]
        [System.Collections.IDictionary] $Headers,

        # Specify if this request should skip cache and go directly to Graph.
        [Parameter(Mandatory = $false)]
        [switch] $DisableCache,
        [string] $Body,

        # If specified, writes the raw results to disk
        [Parameter(Mandatory = $false)]
        [string] $OutputFilePath,

        # The index of Graph request page. If not specified, the first page is assumed (0).
        [Parameter(Mandatory = $false)]
        [string]$PageIndex
    )

    $results = $null
    $isBatch = $uri.AbsoluteUri.EndsWith('$batch')
    $isInCache = $__ZtSession.GraphCache.ContainsKey($Uri.AbsoluteUri)
    $cacheKey = $Uri.AbsoluteUri
    $isMethodGet = $Method -eq 'GET'

    if (!$DisableCache -and !$isBatch -and $isInCache -and $isMethodGet) {
        # Don't read from cache for batch requests.
        Write-PSFMessage "Using graph cache: $($cacheKey)" -Level Debug
        $results = $__ZtSession.GraphCache[$cacheKey]
    }

    if (!$results) {
        Write-PSFMessage "Invoking Graph: $($Uri.AbsoluteUri)" -Level Debug -Tag Graph
        Write-PSFMessage ([string]::IsNullOrEmpty($Body)) -Level Debug -Tag Graph


        if ($Method -eq 'GET') {
            if ($OutputFilePath) {
                $OutputType = 'Json' # Force JSON output if writing to file so we get the raw results
            }

            $results = Invoke-MgGraphRequest -Method $Method -Uri $Uri -Headers $Headers -OutputType $OutputType # -Body $Body # Cannot use Body with GET in PS 5.1
            if ($OutputFilePath) {
                $filePath = Get-ExportJsonFilePath -Path $OutputFilePath -PageIndex $PageIndex
                $results | Out-File (New-Item -Path $filePath -Force) # Write raw results to disk
                $results = $results | ConvertFrom-Json -depth 100 # Convert back to PSObject
            }
        }
        else {
            $results = Invoke-MgGraphRequest -Method $Method -Uri $Uri -Headers $Headers -OutputType $OutputType -Body $Body
        }

        if (!$isBatch -and $isMethodGet) {
            # Update cache
            if ($isInCache) {
                $__ZtSession.GraphCache[$cacheKey] = $results
            }
            else {
                $__ZtSession.GraphCache.Add($cacheKey, $results)
            }
        }
    }
    return $results
}
