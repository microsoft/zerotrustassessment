function Disconnect-ZtAssessment {
    <#
	.SYNOPSIS
		The command to disconnect from Microsoft Graph, Azure, and other connected services.

	.DESCRIPTION
		Use this command to disconnect from Microsoft Graph, Azure, and other services.

		This command will disconnect from:
		* Microsoft Graph (using Disconnect-MgGraph)
		* Azure (using Disconnect-AzAccount)
		* Exchange Online and Security & Compliance PowerShell (using Disconnect-ExchangeOnline)
		* SharePoint Online (using Disconnect-SPOService)
		* Azure Information Protection (using Disconnect-AipService)

        Optionally, it can also clear cached session state (Graph/Azure caches, test metadata,
        tenant info) and close any open database connections.

	.PARAMETER Service
		The services to disconnect from. Default is 'All'.
		Accepts one or more of: All, Azure, AipService, ExchangeOnline, Graph, SharePointOnline.

    .PARAMETER IncludeCleanup
        When specified, clears cached module/session state and closes open database connections
        after disconnecting from requested services.

	.EXAMPLE
		Disconnect-ZtAssessment

		Disconnects from all connected services.

	.EXAMPLE
		Disconnect-ZtAssessment -Service Graph

		Disconnects from Microsoft Graph only.

	.EXAMPLE
		Disconnect-ZtAssessment -Service Graph, ExchangeOnline

		Disconnects from Microsoft Graph and Exchange Online and Security & Compliance.

	.EXAMPLE
		Disconnect-ZtAssessment -Service Graph -IncludeCleanup

		Disconnects from Microsoft Graph and then clears cached state and database connections.
	#>
    [CmdletBinding()]
    param(
        [ValidateSet('All', 'Azure', 'AipService', 'ExchangeOnline', 'Graph', 'SharePointOnline')]
        [string[]]$Service = 'All',

        [switch]$IncludeCleanup
    )

    #region Service disconnections

    # Map each service key to its display name, disconnect command, and optional extra arguments
    $serviceMap = @(
        @{ Key = 'Graph'; Name = 'Microsoft Graph'; Command = 'Disconnect-MgGraph'; Args = @{} }
        @{ Key = 'Azure'; Name = 'Azure'; Command = 'Disconnect-AzAccount'; Args = @{} }
        @{ Key = 'ExchangeOnline'; Name = 'Exchange Online and Security & Compliance PowerShell'; Command = 'Disconnect-ExchangeOnline'; Args = @{ Confirm = $false } }
        @{ Key = 'SharePointOnline'; Name = 'SharePoint Online'; Command = 'Disconnect-SPOService'; Args = @{} }
        @{ Key = 'AipService'; Name = 'Azure Information Protection'; Command = 'Disconnect-AipService'; Args = @{} }
    )

    $serviceResults = [System.Collections.Generic.List[PSCustomObject]]::new()
    $requestedServices = if ($Service -contains 'All') {
        $serviceMap.Key
    }
    else {
        $Service
    }

    foreach ($svc in $serviceMap) {
        if ($Service -contains $svc.Key -or $Service -contains 'All') {
            Write-Host "`nDisconnecting from $($svc.Name)" -ForegroundColor Yellow
            Write-PSFMessage "Disconnecting from $($svc.Name)"
            $resultStatus = 'Succeeded'
            $resultMessage = $null

            $commandInfo = Get-Command -Name $svc.Command -ErrorAction SilentlyContinue
            if (-not $commandInfo) {
                $resultStatus = 'CommandNotFound'
                $resultMessage = "The module for $($svc.Name) is not installed or $($svc.Command) is not available."
                Write-PSFMessage $resultMessage -Level Warning
            }
            else {
                try {
                    $svcArgs = $svc.Args
                    $null = & $svc.Command @svcArgs -ErrorAction Stop
                    Write-Host "Successfully disconnected from $($svc.Name)" -ForegroundColor Green
                }
                catch {
                    $resultStatus = 'Failed'
                    $resultMessage = "Error disconnecting from $($svc.Name): $($_.Exception.Message)"
                    Write-PSFMessage $resultMessage -Level Warning
                }
            }

            $serviceResults.Add([PSCustomObject]@{
                    Service = $svc.Key
                    Name    = $svc.Name
                    Command = $svc.Command
                    Status  = $resultStatus
                    Message = $resultMessage
                })
        }
    }

    #endregion Service disconnections

    #region Session state cleanup

    $cleanupStatus = 'Skipped'
    $cleanupMessage = 'Cleanup not requested. Use -IncludeCleanup to clear cached state and close database connections.'

    if ($IncludeCleanup) {
        Write-PSFMessage 'Clearing session state and cached data'

        $cleanupStatus = 'Succeeded'
        $cleanupMessage = $null

        # Reset all cached module-level variables (Graph/Azure caches, test metadata, tenant info, etc.)
        try {
            Clear-ZtModuleVariable
        }
        catch {
            $cleanupStatus = 'Failed'
            $cleanupMessage = "Error clearing module variables: $($_.Exception.Message)"
            Write-PSFMessage $cleanupMessage -Level Warning
        }

        # Close any open database connection (DuckDB)
        try {
            Disconnect-Database
        }
        catch {
            $cleanupStatus = 'Failed'
            $dbCleanupMessage = "Error closing database connection: $($_.Exception.Message)"
            if ($cleanupMessage) {
                $cleanupMessage = "$cleanupMessage | $dbCleanupMessage"
            }
            else {
                $cleanupMessage = $dbCleanupMessage
            }
            Write-PSFMessage $dbCleanupMessage -Level Warning
        }
    }

    #endregion Session state cleanup

    $failedServiceCount = ($serviceResults | Where-Object { $_.Status -ne 'Succeeded' }).Count
    $overallStatus = if ($failedServiceCount -eq 0 -and $cleanupStatus -in @('Succeeded', 'Skipped')) {
        'Succeeded'
    }
    else {
        'CompletedWithWarnings'
    }

    if ($overallStatus -eq 'Succeeded') {
        Write-Host "`nDisconnection complete" -ForegroundColor Green
    }
    else {
        Write-Host "`nDisconnection complete with warnings" -ForegroundColor Yellow
    }

    [PSCustomObject]@{
        OverallStatus     = $overallStatus
        RequestedServices = $requestedServices
        ServiceResults    = $serviceResults
        Cleanup           = [PSCustomObject]@{
            Status  = $cleanupStatus
            Message = $cleanupMessage
        }
    }
}
