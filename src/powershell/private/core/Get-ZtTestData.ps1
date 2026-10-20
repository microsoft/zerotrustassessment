<#
.SYNOPSIS
    Read structured data published by a check via Add-ZtTestData.

.DESCRIPTION
    Returns $null when the check did not run, was skipped, or published nothing.

.EXAMPLE
    Get-ZtTestData -Name 'PrivateAccessSegmentation'
#>

function Get-ZtTestData {
    [CmdletBinding()]
    param(
        # The unique name of the data set to read.
        [Parameter(Mandatory = $true)]
        [string] $Name
    )

    $script:__ZtSession.TestData.Value[$Name]
}
