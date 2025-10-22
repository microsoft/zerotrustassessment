<#
.SYNOPSIS
    Get license information for a Microsoft 365 product

.DESCRIPTION
    This function retrieves the license information for a Microsoft 365 product from the current tenant.

.PARAMETER Product
    The Microsoft 365 product for which to retrieve the license information.

.EXAMPLE
    Get-ZtLicenseInformation -Product EntraID
#>
function Get-ZtLicenseInformation {
    [OutputType([string])]
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 0, Mandatory)]
        [ValidateSet('EntraID', 'EntraWorkloadID', 'Intune')]
        [string] $Product
    )

    process {
        switch ($Product) {
            "EntraID" {
                Write-PSFMessage "Retrieving license information for Entra ID" -Level Debug -Tag License
                $AvailablePlans = Invoke-ZtGraphRequest -ApiVersion beta -RelativeUri 'organization' | Select-Object -ExpandProperty assignedPlans | Where-Object  { $_.service -eq "AADPremiumService" -and $_.capabilityStatus -ne 'Deleted' } | Select-Object -ExpandProperty servicePlanId
                if ( "41781fb2-bc02-4b7c-bd55-b576c07bb09d" -in $AvailablePlans ) {
                    $LicenseType = "P2"
                } elseif ( "e866a266-3cff-43a3-acca-0c90a7e00c8b" -in $AvailablePlans ) {
                    $LicenseType = "Governance"
                } elseif ( "41781fb2-bc02-4b7c-bd55-b576c07bb09d" -in $AvailablePlans ) {
                    $LicenseType = "P1"
                } else {
                    $LicenseType = "Free"
                }
                Write-Information "The license type for Entra ID is $LicenseType"
                return $LicenseType
                Break
            }
            "EntraWorkloadID" {
                Write-PSFMessage "Retrieving license SKU" -Level Debug -Tag License
                $skus = Invoke-ZtGraphRequest -RelativeUri "subscribedSkus" | Select-Object -ExpandProperty servicePlans | Select-Object -ExpandProperty servicePlanId
                if ("84c289f0-efcb-486f-8581-07f44fc9efad" -in $skus) {
                    $LicenseType = "P1"
                } elseif ("7dc0e92d-bf15-401d-907e-0884efe7c760" -in $skus) {
                    $LicenseType = "P2"
                } else {
                    $LicenseType = $null
                }
                Write-Information "The license type for Entra ID is $LicenseType"
                return $LicenseType
                Break
            }
            "Intune" {
                Write-PSFMessage "Retrieving license SKU" -Level Debug -Tag License
                $skus = Invoke-ZtGraphRequest -RelativeUri "subscribedSkus" | Select-Object -ExpandProperty servicePlans | Select-Object -ExpandProperty servicePlanId
                # Intune always has P1, others add on to this
                if ("c1ec4a95-1f05-45b3-a911-aa3fa01094f5" -in $skus -or "da24caf9-af8e-485c-b7c8-e73336da2693" -in $skus) {
                    $LicenseType = "P1"
                } else {
                    $LicenseType = $null
                }
                Write-Information "The license type for Intune is $LicenseType"
                return $LicenseType
                Break
            }

            Default {}
        }
    }
}
