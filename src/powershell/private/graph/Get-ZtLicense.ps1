<#
.SYNOPSIS
    Checks if a specific license is enabled in the tenant.

.DESCRIPTION
    Helper method that returns a boolean value check for specific license in the tenant.

.PARAMETER Product
    The Microsoft 365 product for which to retrieve the license information.

.EXAMPLE
    Get-ZtLicenseInformation -Product EntraIDP1
#>

function Get-ZtLicense {
    [OutputType([System.Boolean])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateSet('EntraIDP1', 'EntraIDP2', 'EntraIDGovernance', 'EntraWorkloadID', 'Intune')]
        [string] $Product
    )

    process {
        $skus = Invoke-ZtGraphRequest -RelativeUri "subscribedSkus" | Select-Object -ExpandProperty servicePlans | Where-Object { $_.capabilityStatus -ne 'Deleted' } | Select-Object -ExpandProperty servicePlanId
        switch ($Product) {
            'EntraIDP1' {
                return '41781fb2-bc02-4b7c-bd55-b576c07bb09d' -in $skus
            }
            'EntraIDP2' {
                return 'eec0eb4f-6444-4f95-aba0-50c24d67f998' -in $skus
            }
            'EntraIDGovernance' {
                return 'e866a266-3cff-43a3-acca-0c90a7e00c8b' -in $skus
            }
            'EntraWorkloadID' { #P1 or P2
                return '84c289f0-efcb-486f-8581-07f44fc9efad' -in $skus -or '7dc0e92d-bf15-401d-907e-0884efe7c760' -in $skus
            }
            'Intune' { #Intune P1 or Intune P1 education
                return 'c1ec4a95-1f05-45b3-a911-aa3fa01094f5' -in $skus -or 'da24caf9-af8e-485c-b7c8-e73336da2693' -in $skus
            }
            Default {
                return $false
            }
        }
    }
}
