function Test-ZtLicense {
    <#
    .SYNOPSIS
    Validate that the current licensing is compatible with the Compatible license requirements.

    .DESCRIPTION
    This function checks if the current licensing meets the requirements specified in the CompatibleLicense parameter.

    .PARAMETER CompatibleLicense
    An array of compatible licenses required for a test. Each item can be a single license or a combination of licenses separated by '&'
    (e.g. "LicenseA&LicenseB" means both LicenseA and LicenseB are required).

    .PARAMETER CurrentLicense
    An array of licenses currently held by the tenant. If not specified, the function will retrieve the current licenses automatically.

    .EXAMPLE
    Test-ZtLicense -CompatibleLicense @("LicenseA", "LicenseB&LicenseC") -CurrentLicense @("LicenseD", "LicenseB", "LicenseC")
    # This will return true because the tenant has both LicenseB and LicenseC, which satisfies the second compatible license requirement.

    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param (
        [Parameter(Mandatory)]
        [string[]] $CompatibleLicense,

        [Parameter()]
        [string[]] $CurrentLicense = (Get-ZtCurrentLicense)
    )

    # Find the first matching compatible license
    [string[]]$result = $CompatibleLicense.Where({
        $composedLicense = $_
        $decomposedLicenses = $composedLicense -split '\&'
        if ($decomposedLicenses.count -eq $decomposedLicenses.Where({ $_ -in $CurrentLicense }).count) {
            return $true
        }
        else {
            return $false
        }
    },1) # Stop after the first match

    return ($result.count -gt 0)
}
