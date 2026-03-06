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
    PS C:\> Get-ZtCurrentLicense

    #>
    [CmdletBinding()]
    [OutputType([string[]])]
    param(
        [Parameter()]
        [switch]
        $Force
    )

    process {
        if (-not $script:CurrentLicense -or $Force.IsPresent) {
            $skus = Invoke-ZtGraphRequest -RelativeUri "subscribedSkus" | Select-Object -ExpandProperty servicePlans | Where-Object { $_.capabilityStatus -ne 'Deleted' } | Select-Object -ExpandProperty servicePlanId
            $script:CurrentLicense = switch ($skus) {
                '41781fb2-bc02-4b7c-bd55-b576c07bb09d' { 'EntraIDP1' }
                '41781fb2-bc02-4b7c-bd55-b576c07bb09d' { 'P1' }
                'eec0eb4f-6444-4f95-aba0-50c24d67f998' { 'EntraIDP2' }
                'eec0eb4f-6444-4f95-aba0-50c24d67f998' { 'P2' }
                'e866a266-3cff-43a3-acca-0c90a7e00c8b' { 'EntraIDGovernance' }
                'e866a266-3cff-43a3-acca-0c90a7e00c8b' { 'Governance' }
                '84c289f0-efcb-486f-8581-07f44fc9efad' { 'EntraWorkloadID' }
                '7dc0e92d-bf15-401d-907e-0884efe7c760' { 'EntraWorkloadID' }
                'c1ec4a95-1f05-45b3-a911-aa3fa01094f5' { 'Intune' }
                'da24caf9-af8e-485c-b7c8-e73336da2693' { 'Intune' }
                default { Write-Debug -Message "Unknown SKU detected: $_"}
            }

            $script:CurrentLicense = $script:CurrentLicense | Sort-Object -Unique
        }

        return $script:CurrentLicense
    }
}
