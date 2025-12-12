function Connect-ZtAssessment {
	<#
	.SYNOPSIS
		Helper method to connect to Microsoft Graph using Connect-MgGraph with the required scopes.

	.DESCRIPTION
		Use this cmdlet to connect to Microsoft Graph using Connect-MgGraph.

		This command is completely optional if you are already connected to Microsoft Graph and other services using Connect-MgGraph with the required scopes.

		```
		Connect-MgGraph -Scopes (Get-ZtGraphScope)
		```

	.PARAMETER UseDeviceCode
		If specified, the cmdlet will use the device code flow to authenticate to Graph and Azure.
		This will open a browser window to prompt for authentication and is useful for non-interactive sessions and on Windows when SSO is not desired.

	.PARAMETER Environment
		The environment to connect to. Default is Global.

	.PARAMETER UseTokenCache
		Uses Graph Powershell's cached authentication tokens.

	.PARAMETER TenantId
		The tenant ID to connect to. If not specified, the default tenant will be used.

	.PARAMETER ClientId
		If specified, connects using a custom application identity. See https://learn.microsoft.com/powershell/microsoftgraph/authentication-commands

	.PARAMETER Certificate
		The certificate to use for the connection(s).
		Use this to authenticate in Application mode, rather than in Delegate (user) mode.
		The application will need to be configured to have the matching Application scopes, compared to the Delegate scopes and may need to be added into roles.
		If this certificate is also used for connecting to Azure, it must come from a certificate store on the local computer.

	.PARAMETER SkipAzureConnection
		If specified, skips connecting to Azure and only connects to Microsoft Graph.

	.EXAMPLE
		PS C:\> Connect-ZtAssessment

		Connects to Microsoft Graph using Connect-MgGraph with the required scopes.

	.EXAMPLE
		PS C:\> Connect-ZtAssessment -UseDeviceCode

		Connects to Microsoft Graph and Azure using the device code flow. This will open a browser window to prompt for authentication.

	.EXAMPLE
		PS C:\> Connect-ZtAssessment -SkipAzureConnection

		Connects to Microsoft Graph only, skipping the Azure connection. The tests that require Azure connectivity will be skipped.

	.EXAMPLE
		PS C:\> Connect-ZtAssessment -ClientID $clientID -TenantID $tenantID -Certificate 'CN=ZeroTrustAssessment'

		Connects to Microsoft Graph and Azure using the specified client/application ID & tenant ID, using the latest, valid certificate available with the subject 'CN=ZeroTrustAssessment'.
		This assumes the correct scopes and permissions are assigned to the application used.
	#>
	[CmdletBinding()]
	param(
		[switch]
		$UseDeviceCode,

		[ValidateSet('China', 'Germany', 'Global', 'USGov', 'USGovDoD')]
		[string]
		$Environment = 'Global',

		[switch]
		$UseTokenCache,

		[string]
		$TenantId,

		[string]
		$ClientId,

		[PSFramework.Parameter.CertificateParameter]
		$Certificate,

		[switch]
		$SkipAzureConnection
	)

	Write-Host "`nConnecting to Microsoft Graph" -ForegroundColor Yellow
	Write-PSFMessage 'Connecting to Microsoft Graph'

	$params = $PSBoundParameters | ConvertTo-PSFHashtable -Include UseDeviceCode, Environment, TenantId, ClientId
	$params.NoWelcome = $true
	if ($Certificate) {
		$params.Certificate = $Certificate
	}
	else {
		$params.Scopes = Get-ZtGraphScope
	}
	if (-not $UseTokenCache) {
		$params.ContextScope = 'Process'
	}

	try {
		Write-PSFMessage "Connecting to Microsoft Graph with params: $($params | Out-String)" -Level Verbose
		Connect-MgGraph @params -ErrorAction Stop
		$contextTenantId = (Get-MgContext).TenantId
	}
	catch {
		Stop-PSFFunction -Message "Failed to authenticate to Graph" -ErrorRecord $_ -EnableException $true -Cmdlet $PSCmdlet
	}

	try {
		Test-ZtContext
	}
	catch {
		Stop-PSFFunction -Message "Authenticated to Graph, but the requirements for the ZeroTrustAssessment are not met by the established session:`n$_" -ErrorRecord $_ -EnableException $true -Cmdlet $PSCmdlet
	}

	if ($SkipAzureConnection) {
		return
	}

	Write-Host "`nConnecting to Azure" -ForegroundColor Yellow
	Write-PSFMessage 'Connecting to Azure'

	$azEnvironment = 'AzureCloud'
	if ($Environment -eq 'China') {
		$azEnvironment = Get-AzEnvironment -Name AzureChinaCloud
	}
	elseif ($Environment -in 'USGov', 'USGovDoD') {
		$azEnvironment = 'AzureUSGovernment'
	}

	$azParams = @{
		UseDeviceAuthentication = $UseDeviceCode
		Environment             = $azEnvironment
		Tenant                  = $TenantId ? $TenantId : $contextTenantId
	}
	if ($ClientId -and $Certificate) {
		$azParams.ApplicationId = $ClientId
		$azParams.CertificateThumbprint = $Certificate.Certificate.Thumbprint
	}

	try {
		Connect-AzAccount @azParams -ErrorAction Stop
	}
	catch {
		Stop-PSFFunction -Message "Failed to authenticate to Azure: $_" -ErrorRecord $_ -EnableException $true -Cmdlet $PSCmdlet
	}
}
