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
		$SkipAzureConnection,

		# The services to connect to such as Azure and ExchangeOnline. Default is Graph.
		[ValidateSet('All', 'Azure', 'AipService', 'ExchangeOnline', 'Graph', 'SecurityCompliance', 'SharePointOnline')]
		[string[]]$Service = 'Graph',

		# The Exchange environment to connect to. Default is O365Default. Supported values include O365China, O365Default, O365GermanyCloud, O365USGovDoD, O365USGovGCCHigh.
		[ValidateSet('O365China', 'O365Default', 'O365GermanyCloud', 'O365USGovDoD', 'O365USGovGCCHigh')]
		[string]$ExchangeEnvironmentName = 'O365Default',

		# The User Principal Name to use for Security & Compliance PowerShell connection.
		[string]$UserPrincipalName,

		# The SharePoint Admin URL to use for SharePoint Online connection.
		[string]$SharePointAdminUrl
	)


	# Ensure ExchangeOnline is included if SecurityCompliance is requested
	if ($Service -contains 'SecurityCompliance' -and $Service -notcontains 'ExchangeOnline' -and $Service -notcontains 'All') {
		Write-Verbose "Adding ExchangeOnline to the list of services to connect to as it is required for SecurityCompliance."
		$Service += 'ExchangeOnline'
	}

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


	$OrderedImport = Get-ModuleImportOrder -Name @('Az.Accounts', 'ExchangeOnlineManagement', 'Microsoft.Graph.Authentication', 'Microsoft.Online.SharePoint.PowerShell', 'AipService')

	Write-Verbose "Import Order: $($OrderedImport.Name -join ', ')"

	switch ($OrderedImport.Name) {
		'Microsoft.Graph.Authentication' {
			if ($Service -contains 'Graph' -or $Service -contains 'All') {
				Write-Host "`nConnecting to Microsoft Graph" -ForegroundColor Yellow
				Write-PSFMessage 'Connecting to Microsoft Graph'

				try {
					Write-PSFMessage "Connecting to Microsoft Graph with params: $($params | Out-String)" -Level Verbose
					Connect-MgGraph @params -ErrorAction Stop
					$contextTenantId = (Get-MgContext).TenantId
				}

				catch {
					Stop-PSFFunction -Message "Failed to authenticate to Graph" -ErrorRecord $_ -EnableException $true -Cmdlet $PSCmdlet
				}

				try {
					Write-Verbose "Verifying Zero Trust context and permissions..."
					Test-ZtContext
				}
				catch {
					Stop-PSFFunction -Message "Authenticated to Graph, but the requirements for the ZeroTrustAssessment are not met by the established session:`n$_" -ErrorRecord $_ -EnableException $true -Cmdlet $PSCmdlet
				}
			}
		}

		'Az.Accounts' {
			if ($SkipAzureConnection) {
				continue
			}

			if ($Service -contains 'Azure' -or $Service -contains 'All') {
				Write-Host "`nConnecting to Azure" -ForegroundColor Yellow
				Write-PSFMessage 'Connecting to Azure'

				$azEnvironment = 'AzureCloud'
				if ($Environment -eq 'China') {
					$azEnvironment = Get-AzEnvironment -Name AzureChinaCloud
				}
				elseif ($Environment -in 'USGov', 'USGovDoD') {
					$azEnvironment = 'AzureUSGovernment'
				}

				$tenantParam = $TenantId
				if (-not $tenantParam) {
					if ($contextTenantId) {
						$tenantParam = $contextTenantId
					}
				}

				$azParams = @{
					UseDeviceAuthentication = $UseDeviceCode
					Environment             = $azEnvironment
					Tenant                  = $tenantParam
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
		}

		'ExchangeOnlineManagement' {
			if ($Service -contains 'ExchangeOnline' -or $Service -contains 'All') {
				Write-Verbose 'Connecting to Microsoft Exchange Online'
				try {
					if ($UseDeviceCode -and $PSVersionTable.PSEdition -eq 'Desktop') {
						Write-Host 'The Exchange Online module in Windows PowerShell does not support device code flow authentication.' -ForegroundColor Red
						Write-Host '💡Please use the Exchange Online module in PowerShell Core.' -ForegroundColor Yellow
					}
					elseif ($UseDeviceCode) {
						Connect-ExchangeOnline -ShowBanner:$false -Device:$UseDeviceCode -ExchangeEnvironmentName $ExchangeEnvironmentName
					}
					else {
						Connect-ExchangeOnline -ShowBanner:$false -ExchangeEnvironmentName $ExchangeEnvironmentName
					}

					# Fix for Get-Label visibility in other scopes
					if (Get-Command Get-Label -ErrorAction SilentlyContinue) {
						$module = Get-Command Get-Label | Select-Object -ExpandProperty Module
						if ($module -and $module.Name -like 'tmp_*') {
							Import-Module $module -Global -Force
						}
					}
				}
				catch {
					Write-Host "`nFailed to connect to Exchange Online: $_" -ForegroundColor Red
				}
			}

			if ($Service -contains 'SecurityCompliance' -or $Service -contains 'All') {
				$Environments = @{
					'O365China'        = @{
						ConnectionUri    = 'https://ps.compliance.protection.partner.outlook.cn/powershell-liveid'
						AuthZEndpointUri = 'https://login.chinacloudapi.cn/common'
					}
					'O365GermanyCloud' = @{
						ConnectionUri    = 'https://ps.compliance.protection.outlook.com/powershell-liveid/'
						AuthZEndpointUri = 'https://login.microsoftonline.com/common'
					}
					'O365Default'      = @{
						ConnectionUri    = 'https://ps.compliance.protection.outlook.com/powershell-liveid/'
						AuthZEndpointUri = 'https://login.microsoftonline.com/common'
					}
					'O365USGovGCCHigh' = @{
						ConnectionUri    = 'https://ps.compliance.protection.office365.us/powershell-liveid/'
						AuthZEndpointUri = 'https://login.microsoftonline.us/common'
					}
					'O365USGovDoD'     = @{
						ConnectionUri    = 'https://l5.ps.compliance.protection.office365.us/powershell-liveid/'
						AuthZEndpointUri = 'https://login.microsoftonline.us/common'
					}
					Default            = @{
						ConnectionUri    = 'https://ps.compliance.protection.outlook.com/powershell-liveid/'
						AuthZEndpointUri = 'https://login.microsoftonline.com/common'
					}
				}
				Write-Verbose 'Connecting to Microsoft Security & Compliance PowerShell'

				if ($UseDeviceCode) {
					Write-Host "`nThe Security & Compliance module does not support device code flow authentication." -ForegroundColor Red
				}
				else {
					# Get UPN from Exchange connection or Graph context
					$ExoUPN = $UserPrincipalName

					# Attempt to resolve UPN before any connection to avoid token acquisition failures without identity
					$connectionInformation = $null
					try {
						$connectionInformation = Get-ConnectionInformation
					}
					catch {
						# Intentionally swallow errors here; fall back to provided UPN if any
						$connectionInfoError = $_
						Write-Verbose "Get-ConnectionInformation failed; falling back to provided UserPrincipalName if available. Error: $($connectionInfoError.Exception.Message)"
					}

					if (-not $ExoUPN) {
						$ExoUPN = $connectionInformation | Where-Object { $_.IsEopSession -ne $true -and $_.State -eq 'Connected' } | Select-Object -ExpandProperty UserPrincipalName -First 1 -ErrorAction SilentlyContinue
					}

					if (-not $ExoUPN) {
						Write-Host "`nUnable to determine a UserPrincipalName for Security & Compliance. Please supply -UserPrincipalName or connect to Exchange Online first." -ForegroundColor Yellow
						continue
					}

					try {
						$ippSessionParams = @{
							BypassMailboxAnchoring = $true
							UserPrincipalName      = $ExoUPN
							ShowBanner             = $false
							ErrorAction            = 'Stop'
						}

						# Only override endpoints for non-default clouds to reduce token acquisition failures in Default
						if ($ExchangeEnvironmentName -ne 'O365Default') {
							$ippSessionParams.ConnectionUri = $Environments[$ExchangeEnvironmentName].ConnectionUri
							$ippSessionParams.AzureADAuthorizationEndpointUri = $Environments[$ExchangeEnvironmentName].AuthZEndpointUri
						}

						Write-Verbose "Connecting to Security & Compliance with UPN: $ExoUPN"
						Connect-IPPSSession @ippSessionParams
					}

					catch {
						$exception = $_
						$methodNotFoundException = $null

						# Detect DLL conflict via a specific MissingMethodException, preferring the inner exception when present
						if ($exception.Exception.InnerException -is [System.MissingMethodException]) {
							$methodNotFoundException = $exception.Exception.InnerException
						}
						elseif ($exception.Exception -is [System.MissingMethodException]) {
							$methodNotFoundException = $exception.Exception
						}

						if ($methodNotFoundException -and $methodNotFoundException.Message -like "*Microsoft.Identity.Client*") {
							Write-Warning "DLL Conflict detected (Method not found in Microsoft.Identity.Client). This usually happens if Microsoft.Graph is loaded before ExchangeOnlineManagement."
							Write-Warning "Please RESTART your PowerShell session and run Connect-ZtAssessment again."
						}

						Write-Host "`nFailed to connect to the Security & Compliance PowerShell: $exception" -ForegroundColor Red
					}
				}

				# Fix for Get-Label visibility in other scopes
				if (Get-Command Get-Label -ErrorAction SilentlyContinue) {
					$module = Get-Command Get-Label | Select-Object -ExpandProperty Module
					if ($module -and $module.Name -like 'tmp_*') {
						Import-Module $module -Global -Force
					}
				}
			}
		}

		'Microsoft.Online.SharePoint.PowerShell' {
			if ($Service -contains 'SharePointOnline' -or $Service -contains 'All') {
				try {
					# Import module with compatibility if needed
					if ($PSVersionTable.PSEdition -ne 'Desktop') {
						# Assume module is installed in Windows PowerShell as per instructions
						Import-Module Microsoft.Online.SharePoint.PowerShell -UseWindowsPowerShell -WarningAction SilentlyContinue -ErrorAction Stop -Global
					}
					else {
						Import-Module Microsoft.Online.SharePoint.PowerShell -ErrorAction Stop -Global
					}
				}
				catch {
					# Provide clearer guidance when import fails, especially under PowerShell Core
					if ($PSVersionTable.PSEdition -ne 'Desktop') {
						$message = "Failed to import SharePoint Online module. When running in PowerShell Core, 'Microsoft.Online.SharePoint.PowerShell' must be installed in Windows PowerShell 5.1 (Desktop) for -UseWindowsPowerShell to work. Underlying error: $_"
					}
					else {
						$message = "Failed to import SharePoint Online module: $_"
					}
					Write-Host "`n$message" -ForegroundColor Red
					Write-PSFMessage $message -Level Error
				}
			}
		}

		'AipService' {
			if ($Service -contains 'AipService' -or $Service -contains 'All') {
				try {
					# Import module with compatibility if needed
					if ($PSVersionTable.PSEdition -ne 'Desktop') {
						# Assume module is installed in Windows PowerShell as per instructions
						Import-Module AipService -UseWindowsPowerShell -WarningAction SilentlyContinue -ErrorAction Stop -Global
					}
					else {
						Import-Module AipService -ErrorAction Stop -Global
					}
				}
				catch {
					# Provide clearer guidance when import fails, especially under PowerShell Core
					if ($PSVersionTable.PSEdition -ne 'Desktop') {
						$message = "Failed to import AipService module. When running in PowerShell Core, 'AipService' must be installed in Windows PowerShell 5.1 (Desktop) for -UseWindowsPowerShell to work. Underlying error: $_"
					}
					else {
						$message = "Failed to import AipService module: $_"
					}
					Write-Host "`n$message" -ForegroundColor Red
					Write-PSFMessage $message -Level Error
				}
			}
		}
	}

	if ($Service -contains 'SharePointOnline' -or $Service -contains 'All') {
		Write-Host "`nConnecting to SharePoint Online" -ForegroundColor Yellow
		Write-PSFMessage 'Connecting to SharePoint Online'

		# Determine Admin URL
		$adminUrl = $SharePointAdminUrl
		if (-not $adminUrl) {
			# Try to infer from Graph context
			if ($contextTenantId) {
				try {
					$org = Invoke-ZtGraphRequest -RelativeUri 'organization'
					$initialDomain = $org.verifiedDomains | Where-Object { $_.isInitial } | Select-Object -ExpandProperty name -First 1
					if ($initialDomain) {
						$tenantName = $initialDomain.Split('.')[0]
						$adminUrl = "https://$tenantName-admin.sharepoint.com"
						Write-Verbose "Inferred SharePoint Admin URL: $adminUrl"
					}
				}
				catch {
					Write-Verbose "Failed to infer SharePoint Admin URL from Graph: $_"
				}
			}
		}

		if (-not $adminUrl) {
			Write-Warning "SharePoint Admin URL not provided and could not be inferred. Skipping SharePoint connection."
		}
		else {
			try {
				Connect-SPOService -Url $adminUrl -ErrorAction Stop
				Write-Verbose "Successfully connected to SharePoint Online."
			}
			catch {
				Write-Host "`nFailed to connect to SharePoint Online: $_" -ForegroundColor Red
				Write-PSFMessage "Failed to connect to SharePoint Online: $_" -Level Error
			}
		}
	}

	if ($Service -contains 'AipService' -or $Service -contains 'All') {
		Write-Host "`nConnecting to Azure Information Protection" -ForegroundColor Yellow
		Write-PSFMessage 'Connecting to Azure Information Protection'

		try {
			Connect-AipService -ErrorAction Stop
			Write-Verbose "Successfully connected to Azure Information Protection."
		}
		catch {
			Write-Host "`nFailed to connect to Azure Information Protection: $_" -ForegroundColor Red
			Write-PSFMessage "Failed to connect to Azure Information Protection: $_" -Level Error
		}
	}
}
