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
    $config.PSObject.Properties | ForEach-Object {
        $test = $_.Value
        if ($test.TenantType -contains $mappedTenantType) {
            $testName = "Test-Assessment-$($test.TestId)"

            # Check if the function exists and what parameters it has
            $command = Get-Command $testName -ErrorAction SilentlyContinue
            if ($command) {
                $hasDbParam = $command.Parameters.ContainsKey("Database")

                if ($hasDbParam) {
                    & $testName -Database $Database
                } else {
                    & $testName
                }
            } else {
                Write-Warning "Test function '$testName' not found"
            }
        }
    }
}
