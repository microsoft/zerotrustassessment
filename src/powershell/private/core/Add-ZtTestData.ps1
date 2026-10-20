<#
.SYNOPSIS
    Publish structured data from a check so that composite dashboards can consume it.

.DESCRIPTION
    Roll-up test results only carry a Pass/Fail verdict. Dashboards that aggregate several
    checks (for example the Private Access funnel) need the per-item rows a check already
    computed. This stores those rows in threadsafe module state so they survive the parallel
    test runspaces and can be read during the tenant information stage.

.EXAMPLE
    Add-ZtTestData -Name 'PrivateAccessSegmentation' -Value $appResults

    Publishes the per-application segmentation rows for later aggregation.
#>

function Add-ZtTestData {
    [CmdletBinding()]
    param(
        # The unique name for this data set.
        [Parameter(Mandatory = $true)]
        [string] $Name,

        # The value to publish.
        $Value
    )

    $script:__ZtSession.TestData.Value[$Name] = $Value
}
