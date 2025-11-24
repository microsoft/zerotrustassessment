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

.EXAMPLE
    Connect-ZtAssessment -SkipAzureConnection

    Connects to Microsoft Graph only, skipping the Azure connection. The tests that require Azure connectivity will be skipped.

.EXAMPLE
    Connect-ZtAssessment -ClientId "12345678-1234-1234-1234-123456789012"

    Connects to Microsoft Graph using a specific client ID (application ID) for authentication.

# .EXAMPLE
    Connect-ZtAssessment -ClientId "12345678-1234-1234-1234-123456789012" -ClientSecret "your-client-secret" -TenantId "your-tenant-id"

    Connects to Microsoft Graph using client credentials (application authentication) with client ID and client secret. For improved security, retrieve the secret from a vault (e.g. SecretManagement) rather than hard-coding.
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
        [switch]$UseTokenCache,

        # The tenant ID to connect to. If not specified, the default tenant will be used.
        [string]$TenantId,

        # If specified, skips connecting to Azure and only connects to Microsoft Graph.
        [switch]$SkipAzureConnection,

        # The client ID (application ID) to use for authentication. If not specified, the default client ID will be used.
        [string]$ClientId
,

        # The client secret to use for authentication. Used together with ClientId for application authentication.
        [string]$ClientSecret
    ,
        # Internal/testing: Skip actual connection and just build parameter set
        [Parameter(DontShow=$true)]
        [switch]$NoConnect
    )

    Write-Host "`nConnecting to Microsoft Graph" -ForegroundColor Yellow
    Write-PSFMessage 'Connecting to Microsoft Graph'
    try
    {
        # If using client secret, use app-only auth: omit Scopes and build credential
        $params = @{
            NoWelcome   = $true
            Environment = $Environment
        }

        if (-not $ClientSecret) {
            $params['Scopes'] = (Get-ZtGraphScope)
        }

        if ($UseDeviceCode) {
            $params['UseDeviceCode'] = $true
        }

        # If force use -ContextScope Process to force re-authentication
        if (!$UseTokenCache) {
            $params['ContextScope'] = 'Process'
        }

        if ($TenantId) {
            $params['TenantId'] = $TenantId
        }

        if ($ClientSecret) {
            if (-not $TenantId) {
                Write-PSFMessage 'TenantId is required when using ClientSecret for app-only authentication.' -Level Error
                throw 'TenantId is required when using ClientSecret.'
            }
            $secureSecret = if ($ClientSecret -is [System.Security.SecureString]) { $ClientSecret } else { ConvertTo-SecureString -String $ClientSecret -AsPlainText -Force }
            $params['ClientSecretCredential'] = New-Object System.Management.Automation.PSCredential ($ClientId, $secureSecret)
        }
        elseif ($ClientId) {
            # Only set ClientId for interactive/device flows
            $params['ClientId'] = $ClientId
        }

        if ($NoConnect) {
            return $params
        }

        Write-PSFMessage "Connecting to Microsoft Graph with params: $(($params | Out-String))" -Level Verbose
        Connect-MgGraph @params
        $contextTenantId = (Get-MgContext).TenantId
    }
    catch [Management.Automation.CommandNotFoundException]
    {
        Write-Host "`nThe Graph PowerShell module is not installed. Please install the module using the following command. For more information see https://learn.microsoft.com/powershell/microsoftgraph/installation" -ForegroundColor Red
        Write-Host "`Install-Module Microsoft.Graph -Scope CurrentUser`n" -ForegroundColor Yellow
    }

    if (!$SkipAzureConnection)
    {
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

            $azParams = @{
                UseDeviceAuthentication = $UseDeviceCode
                Environment = $azEnvironment
                Tenant = if ($TenantId) { $TenantId } else { $contextTenantId }
            }

            Connect-AzAccount @azParams
        }
        catch [Management.Automation.CommandNotFoundException]
        {
            Write-Host "`nThe Azure PowerShell module is not installed. Please install the module using the following command." -ForegroundColor Red
            Write-Host "`Install-Module Az.Accounts -Scope CurrentUser`n" -ForegroundColor Yellow
        }
    }
}
