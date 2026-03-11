function Get-ZtCurrentLicense {
    <#
    .SYNOPSIS
        Returns the list of Licenses/skus subscribed to.

    .DESCRIPTION
        This function retrieves the list of licenses or service plans that the tenant is currently subscribed to.
        It uses the Microsoft Graph API to fetch the subscribed SKUs and filters out any deleted service plans.
        It will only return the licenses that are relevant for the Zero Trust Assessment, based on a predefined mapping of SKUs to license names.

    .PARAMETER Force
        If specified, forces a refresh of the cached license information. By default, the function caches the license information in the
        $script:CurrentLicense variable to avoid unnecessary API calls on subsequent invocations.

    .EXAMPLE
        PS C:\> Get-ZtCurrentLicense -Force

        This will retrieve the current licenses for the tenant, bypassing any cached information.
    #>
    [CmdletBinding()]
    [OutputType([string[]])]
    param(
        [Parameter()]
        [switch]
        $Force
    )

    process {
        try
        {
            if (-not $script:CurrentLicense -or $Force.IsPresent) {
                [string[]] $script:CurrentLicense = Invoke-ZtRetry -RetryCount 3 -ScriptBlock {
                    (Invoke-ZtGraphRequest -RelativeUri "subscribedSkus" -ErrorAction Stop).servicePlans.Where{ $_.capabilityStatus -ne 'Deleted' }.servicePlanName | Sort-Object -Unique
                }
            }
        }
        catch {
            Write-PSFMessage -Level Warning -Message ('Failed to retrieve current licenses. Error: {0}' -f $_.Exception.Message) -ErrorRecord $_
            $script:CurrentLicense = @()
        }

        return $script:CurrentLicense
    }
}
