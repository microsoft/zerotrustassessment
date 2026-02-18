<#
.SYNOPSIS
   Helper method to disconnect from Microsoft Graph, Azure, and other connected services.

.DESCRIPTION
   Use this cmdlet to disconnect from Microsoft Graph, Azure, and other services.

   This command will disconnect from:
   - Microsoft Graph (using Disconnect-MgGraph)
   - Azure (using Disconnect-AzAccount)
   - Exchange Online (using Disconnect-ExchangeOnline)
   - Security & Compliance PowerShell (using Disconnect-IPPSSession)
   - SharePoint Online (using Disconnect-SPOService)
   - Azure Information Protection (using Disconnect-AipService)

.EXAMPLE
   Disconnect-ZtAssessment

   Disconnects from all connected services.

#>

function Disconnect-ZtAssessment
{
    [CmdletBinding()]
    param()

    Write-Host "`nDisconnecting from Microsoft Graph" -ForegroundColor Yellow
    Write-PSFMessage 'Disconnecting from Microsoft Graph'
    try
    {
        Disconnect-MgGraph -ErrorAction SilentlyContinue | Out-Null
        Write-Host "Successfully disconnected from Microsoft Graph" -ForegroundColor Green
    }
    catch [Management.Automation.CommandNotFoundException]
    {
        Write-PSFMessage "The Graph PowerShell module is not installed or Disconnect-MgGraph is not available." -Level Warning
    }
    catch
    {
        Write-PSFMessage "Error disconnecting from Microsoft Graph: $($_.Exception.Message)" -Level Warning
    }

    Write-Host "`nDisconnecting from Azure" -ForegroundColor Yellow
    Write-PSFMessage 'Disconnecting from Azure'
    try
    {
        Disconnect-AzAccount -ErrorAction SilentlyContinue | Out-Null
        Write-Host "Successfully disconnected from Azure" -ForegroundColor Green
    }
    catch [Management.Automation.CommandNotFoundException]
    {
        Write-PSFMessage "The Azure PowerShell module is not installed or Disconnect-AzAccount is not available." -Level Warning
    }
    catch
    {
        Write-PSFMessage "Error disconnecting from Azure: $($_.Exception.Message)" -Level Warning
    }

    function Invoke-DisconnectService {
        param (
            [Parameter(Mandatory = $true)]
            [string]
            $ServiceName,

            [Parameter(Mandatory = $true)]
            [scriptblock]
            $DisconnectScript,

            [Parameter(Mandatory = $true)]
            [string]
            $MissingModuleMessage,

            [Parameter(Mandatory = $true)]
            [string]
            $ErrorPrefix
        )

        Write-Host "`nDisconnecting from $ServiceName" -ForegroundColor Yellow
        Write-PSFMessage "Disconnecting from $ServiceName"
        try {
            & $DisconnectScript
            Write-Host "Successfully disconnected from $ServiceName" -ForegroundColor Green
        }
        catch [Management.Automation.CommandNotFoundException] {
            Write-PSFMessage $MissingModuleMessage -Level Warning
        }
        catch {
            Write-PSFMessage "$ErrorPrefix $($_.Exception.Message)" -Level Warning
        }
    }

    Invoke-DisconnectService `
        -ServiceName 'Security & Compliance PowerShell' `
        -DisconnectScript { Disconnect-IPPSSession -Confirm:$false -ErrorAction SilentlyContinue | Out-Null } `
        -MissingModuleMessage 'The Exchange Online Management module is not installed or Disconnect-IPPSSession is not available.' `
        -ErrorPrefix 'Error disconnecting from Security & Compliance PowerShell:'

    Invoke-DisconnectService `
        -ServiceName 'Exchange Online' `
        -DisconnectScript { Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue | Out-Null } `
        -MissingModuleMessage 'The Exchange Online Management module is not installed or Disconnect-ExchangeOnline is not available.' `
        -ErrorPrefix 'Error disconnecting from Exchange Online:'

    Invoke-DisconnectService `
        -ServiceName 'SharePoint Online' `
        -DisconnectScript { Disconnect-SPOService -ErrorAction SilentlyContinue | Out-Null } `
        -MissingModuleMessage 'The SharePoint Online Management module is not installed or Disconnect-SPOService is not available.' `
        -ErrorPrefix 'Error disconnecting from SharePoint Online:'

    Invoke-DisconnectService `
        -ServiceName 'Azure Information Protection' `
        -DisconnectScript { Disconnect-AipService -ErrorAction SilentlyContinue | Out-Null } `
        -MissingModuleMessage 'The AipService module is not installed or Disconnect-AipService is not available.' `
        -ErrorPrefix 'Error disconnecting from Azure Information Protection:'
    Write-Host "`nDisconnection complete" -ForegroundColor Green
}
