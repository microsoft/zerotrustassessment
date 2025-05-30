<#
.SYNOPSIS
    Runs all the Zero Trust Assessment tests.
#>

function Invoke-ZtTests {
    [CmdletBinding()]
    param (
        $Database,
        [string]$ConfigPath = ".\private\tests\TestMeta.json",
        [ValidateSet("AAD", "CIAM")]
        [string]$TenantType = "AAD"
    )

    # Map input parameters to config file values
    $tenantTypeMapping = @{
        "AAD" = "Workforce"
        "CIAM" = "External"
    }

    $mappedTenantType = $tenantTypeMapping[$TenantType]

    # Load the test configuration from JSON file
    $configContent = Get-Content -Path $ConfigPath -Raw
    $config = $configContent | ConvertFrom-Json

    # Filter tests by tenant type and execute them
    # Note: Your config structure uses test IDs as keys, so we need to iterate through values
    $config.PSObject.Properties | ForEach-Object {
        $test = $_.Value
        if ($test.TenantType -contains $mappedTenantType) {
            $testName = "Test-Assessment-$($test.TestId)"
            if ($test.RequiresDatabase) {
                & $testName -Database $Database
            } else {
                & $testName
            }
        }
    }
}
