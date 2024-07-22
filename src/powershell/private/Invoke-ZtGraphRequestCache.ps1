<#
.SYNOPSIS
    Enhanced version of Invoke-MgGraphRequest that supports caching.
#>
Function Invoke-ZtGraphRequestCache
{
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
        [string] $OutputFilePath

    )

    $results = $null
    $isBatch = $uri.AbsoluteUri.EndsWith('$batch')
    $isInCache = $__ZtSession.GraphCache.ContainsKey($Uri.AbsoluteUri)
    $cacheKey = $Uri.AbsoluteUri
    $isMethodGet = $Method -eq 'GET'

    if (!$DisableCache -and !$isBatch -and $isInCache -and $isMethodGet)
    {
        # Don't read from cache for batch requests.
        Write-Verbose ("Using graph cache: $($cacheKey)")
        $results = $__ZtSession.GraphCache[$cacheKey]
    }

    if (!$results)
    {
        Write-Verbose ("Invoking Graph: $($Uri.AbsoluteUri)")
        Write-Verbose ([string]::IsNullOrEmpty($Body))


        if ($Method -eq 'GET')
        {
            $results = Invoke-MgGraphRequest -Method $Method -Uri $Uri -Headers $Headers -OutputType $OutputType -OutputFilePath $OutputFilePath # -Body $Body # Cannot use Body with GET in PS 5.1
        }
        else
        {
            $results = Invoke-MgGraphRequest -Method $Method -Uri $Uri -Headers $Headers -OutputType $OutputType -Body $Body
        }



        if (!$isBatch -and $isMethodGet)
        {
            # Update cache
            if ($isInCache)
            {
                $__ZtSession.GraphCache[$cacheKey] = $results
            }
            else
            {
                $__ZtSession.GraphCache.Add($cacheKey, $results)
            }
        }
    }
    return $results
}
