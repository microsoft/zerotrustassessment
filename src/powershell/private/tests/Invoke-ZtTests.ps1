<#
.SYNOPSIS
    Runs all the Zero Trust Assessment tests.
#>

function Invoke-ZtTests {
    [CmdletBinding()]
    param (
        $Database,
        [string]$ConfigPath = ".\private\tests\tests-config.json",
        [ValidateSet("AAD", "CIAM")]
        [string]$TenantType = "AAD"
    )

    # Load the test configuration from JSON file
    $configContent = Get-Content -Path $ConfigPath -Raw
    $config = $configContent | ConvertFrom-Json

    # Filter tests by tenant type and execute them
    $config.tests | Where-Object { $_.tenantTypes -contains $TenantType } | ForEach-Object {
        if ($_.requiresDatabase) {
            & $_.name -Database $Database
        } else {
            & $_.name
        }
    }
}
