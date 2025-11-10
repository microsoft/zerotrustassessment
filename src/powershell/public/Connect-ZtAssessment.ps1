<#
.SYNOPSIS
   Helper method to connect to Microsoft Graph using Connect-MgGraph with the required scopes.

.DESCRIPTION
   Use this cmdlet to connect to Microsoft Graph using Connect-MgGraph.

   This command is completely optional if you are already connected to Microsoft Graph and other services using Connect-MgGraph with the required scopes.

   ```
   Connect-MgGraph -Scopes (Get-ZtGraphScope)
   ```

.EXAMPLE
   Connect-ZtAssessment

   Connects to Microsoft Graph using Connect-MgGraph with the required scopes.


.EXAMPLE
   Connect-ZtAssessment -UseDeviceCode

   Connects to Microsoft Graph and Azure using the device code flow. This will open a browser window to prompt for authentication.

#>

function Connect-ZtAssessment
{
    [CmdletBinding()]
    param(
        # If specified, the cmdlet will use the device code flow to authenticate to Graph and Azure.
        # This will open a browser window to prompt for authentication and is useful for non-interactive sessions and on Windows when SSO is not desired.
        [switch] $UseDeviceCode,

        # The environment to connect to. Default is Global.
        [ValidateSet('China', 'Germany', 'Global', 'USGov', 'USGovDoD')]
        [string]$Environment = 'Global',

        # Uses Graph Powershell's cached authentication tokens.
        [switch]$UseTokenCache
    )

    Write-Host "`nConnecting to Microsoft Graph" -ForegroundColor Yellow
    Write-PSFMessage 'Connecting to Microsoft Graph'
    try
    {
        $params = @{
            Scopes       = (Get-ZtGraphScope)
            NoWelcome    = $true
            Environment  = $Environment
        }

        if ($UseDeviceCode) {
            $params['UseDeviceCode'] = $true
        }

        # If force use -ContextScope Process to force re-authentication
        if (!$UseTokenCache) {
            $params['ContextScope'] = 'Process'
        }

        Write-PSFMessage "Connecting to Microsoft Graph with params: $($params | Out-String)" -Level Verbose
        Connect-MgGraph @params
        $tenantId = (Get-MgContext).TenantId
    }
    catch [Management.Automation.CommandNotFoundException]
    {
        Write-Host "`nThe Graph PowerShell module is not installed. Please install the module using the following command. For more information see https://learn.microsoft.com/powershell/microsoftgraph/installation" -ForegroundColor Red
        Write-Host "`Install-Module Microsoft.Graph -Scope CurrentUser`n" -ForegroundColor Yellow
    }

    Write-Host "`nConnecting to Azure" -ForegroundColor Yellow
    Write-PSFMessage 'Connecting to Azure'
    try
    {
        $azEnvironment = 'AzureCloud'
        if($Environment -eq 'China') {
            $azEnvironment = Get-AzEnvironment -Name AzureChinaCloud
        }
        elseif($Environment -in 'USGov', 'USGovDoD') {
            $azEnvironment = 'AzureUSGovernment'
        }
        Connect-AzAccount -UseDeviceAuthentication:$UseDeviceCode -Environment $azEnvironment -Tenant $tenantId
    }
    catch [Management.Automation.CommandNotFoundException]
    {
        Write-Host "`nThe Azure PowerShell module is not installed. Please install the module using the following command." -ForegroundColor Red
        Write-Host "`Install-Module Az.Accounts -Scope CurrentUser`n" -ForegroundColor Yellow
    }
}
