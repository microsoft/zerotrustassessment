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

    Write-Host "`nDisconnecting from Security & Compliance PowerShell" -ForegroundColor Yellow
    Write-PSFMessage 'Disconnecting from Security & Compliance PowerShell'
    try
    {
        Disconnect-IPPSSession -Confirm:$false -ErrorAction SilentlyContinue | Out-Null
        Write-Host "Successfully disconnected from Security & Compliance PowerShell" -ForegroundColor Green
    }
    catch [Management.Automation.CommandNotFoundException]
    {
        Write-PSFMessage "The Exchange Online Management module is not installed or Disconnect-IPPSSession is not available." -Level Warning
    }
    catch
    {
        Write-PSFMessage "Error disconnecting from Security & Compliance PowerShell: $($_.Exception.Message)" -Level Warning
    }

    Write-Host "`nDisconnecting from Exchange Online" -ForegroundColor Yellow
    Write-PSFMessage 'Disconnecting from Exchange Online'
    try
    {
        Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue | Out-Null
        Write-Host "Successfully disconnected from Exchange Online" -ForegroundColor Green
    }
    catch [Management.Automation.CommandNotFoundException]
    {
        Write-PSFMessage "The Exchange Online Management module is not installed or Disconnect-ExchangeOnline is not available." -Level Warning
    }
    catch
    {
        Write-PSFMessage "Error disconnecting from Exchange Online: $($_.Exception.Message)" -Level Warning
    }

    Write-Host "`nDisconnecting from SharePoint Online" -ForegroundColor Yellow
    Write-PSFMessage 'Disconnecting from SharePoint Online'
    try
    {
        Disconnect-SPOService -ErrorAction SilentlyContinue | Out-Null
        Write-Host "Successfully disconnected from SharePoint Online" -ForegroundColor Green
    }
    catch [Management.Automation.CommandNotFoundException]
    {
        Write-PSFMessage "The SharePoint Online Management module is not installed or Disconnect-SPOService is not available." -Level Warning
    }
    catch
    {
        Write-PSFMessage "Error disconnecting from SharePoint Online: $($_.Exception.Message)" -Level Warning
    }

    Write-Host "`nDisconnecting from Azure Information Protection" -ForegroundColor Yellow
    Write-PSFMessage 'Disconnecting from Azure Information Protection'
    try
    {
        Disconnect-AipService -ErrorAction SilentlyContinue | Out-Null
        Write-Host "Successfully disconnected from Azure Information Protection" -ForegroundColor Green
    }
    catch [Management.Automation.CommandNotFoundException]
    {
        Write-PSFMessage "The AipService module is not installed or Disconnect-AipService is not available." -Level Warning
    }
    catch
    {
        Write-PSFMessage "Error disconnecting from Azure Information Protection: $($_.Exception.Message)" -Level Warning
    }

    Write-Host "`nDisconnection complete" -ForegroundColor Green
}
