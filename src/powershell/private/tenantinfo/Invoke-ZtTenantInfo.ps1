<#
.SYNOPSIS
    Runs all the cmdlets to gather tenant information.
#>

function Invoke-ZtTenantInfo {
    [CmdletBinding()]
    param (
        # The folder that has the test data
        [Parameter(Mandatory = $true)]
        $Database
    )

    Add-ZtOverviewCaMfa -Database $Database
}
