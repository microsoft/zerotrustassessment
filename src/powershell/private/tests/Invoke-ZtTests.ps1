<#
.SYNOPSIS
    Runs all the Zero Trust Assessment tests.
#>

function Invoke-ZtTests {
    [CmdletBinding()]
    param (
        $Database,

        # The IDs of the specific test(s) to run. If not specified, all tests will be run.
        [string[]]
        $Tests

    )

    # Get Tenant Type (AAD = Workforce, CIAM = EEID)
    $org = Invoke-ZtGraphRequest -RelativeUri 'organization'
    $tenantType = $org.TenantType
    Write-PSFMessage "$tenantType tenant detected. This will determine the tests that are run."


    # Map input parameters to config file values
    $tenantTypeMapping = @{
        "AAD" = "Workforce"
        "CIAM" = "External"
    }

    $mappedTenantType = $tenantTypeMapping[$TenantType]

    $config = $__ZtSession.TestMeta

    # Get the list of tests to run
    if ($Tests) {
        # If specific tests are provided, filter the config based on those tests
        $testsToRun = $config.Values | Where-Object { $_.TestId -in $Tests }
    } else {
        # If no specific tests are provided, run all tests
        $testsToRun = $config.Values
    }

    # Filter tests by tenant type and execute them
    foreach ($test in $testsToRun) {
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
                Write-PSFMessage "Test function '$testName' not found" -Level Warning
            }
        }
    }
}
