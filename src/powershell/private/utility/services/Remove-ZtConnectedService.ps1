function Remove-ZtConnectedService {
    <#
    .SYNOPSIS
    Remove an entry from the list of connected services used for testing.

    .DESCRIPTION
    Remove an entry from the list of connected services.
    This is used to skip tests that require a service connection when the service is not connected.

    .PARAMETER Service
    The name of the service to remove from the list of connected services.

    .EXAMPLE
    Remove-ZtConnectedService -Service 'Graph'

    #>
    [CmdletBinding()]
    [OutputType([void])]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateSet('Graph', 'Azure', 'AipService', 'ExchangeOnline', 'SecurityCompliance', 'SharePointOnline')]
        [string]
        $Service
    )

    if ($script:ConnectedService -contains $Service) {
        $script:ConnectedService = $script:ConnectedService.Where{ $_ -ne $Service }
    }

    # Clear the cached initial domain whenever Graph is removed so the next Connect-ZtAssessment
    # call re-resolves it rather than using a stale or missing value.
    if ($Service -eq 'Graph') {
        $script:resolvedInitialDomain = $null
    }
}
