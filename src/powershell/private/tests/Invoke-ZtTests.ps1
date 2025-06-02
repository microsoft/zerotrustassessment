<#
.SYNOPSIS
    Runs all the Zero Trust Assessment tests.
#>

function Invoke-ZtTests {
    [CmdletBinding()]
    param (
        $Database
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

    # Filter tests by tenant type and execute them
    foreach ($test in $config.Values) {
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
