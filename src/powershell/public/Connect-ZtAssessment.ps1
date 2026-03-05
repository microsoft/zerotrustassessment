function Connect-ZtAssessment {
	<#
	.SYNOPSIS
		Helper method to connect to Microsoft Graph and other services with the appropriate parameters
		and scopes for the Zero Trust Assessment.

	.DESCRIPTION
		Use this cmdlet to connect to Microsoft Graph and other services using the appropriate parameters and scopes
		for the Zero Trust Assessment.
		This cmdlet will import the necessary modules and establish connections based on the specified parameters.

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
		If specified, skips connecting to Azure and only connects to other services.

	.EXAMPLE
		PS C:\> Connect-ZtAssessment

		Connects to Microsoft Graph and other services using Connect-MgGraph with the required scopes and other services.
		By default, on Windows, this connects to Graph, Azure, Exchange Online, Security & Compliance, SharePoint Online, and Azure Information Protection.
		On other platforms, this connects to Graph, Azure, Exchange and Security & Compliance (where supported).

	.EXAMPLE
		PS C:\> Connect-ZtAssessment -UseDeviceCode

		Connects to Microsoft Graph and Azure using the device code flow. This will open a browser window to prompt for authentication.

	.EXAMPLE
		PS C:\> Connect-ZtAssessment -SkipAzureConnection

		Connects to services but skipping the Azure connection. The tests that require Azure connectivity will be skipped.

	.EXAMPLE
		PS C:\> Connect-ZtAssessment -ClientID $clientID -TenantID $tenantID -Certificate 'CN=ZeroTrustAssessment' -Service Graph,Azure

		Connects to Microsoft Graph and Azure using the specified client/application ID & tenant ID, using the latest, valid certificate available with the subject 'CN=ZeroTrustAssessment'.
		This assumes the correct scopes and permissions are assigned to the application used.
	#>
	[CmdletBinding()]
	param (
		[switch]
		$UseDeviceCode,

		[ValidateSet('China', 'Germany', 'Global', 'USGov', 'USGovDoD')]
		[string]
		$Environment = 'Global',

		[Parameter(DontShow)]
		[switch]
		$UseTokenCache, # Latest Graph module broke it...

		[string]
		$TenantId,

		[string]
		$ClientId,

		[PSFramework.Parameter.CertificateParameter]
		$Certificate,

		# The services to connect to such as Azure and ExchangeOnline. Default is All.
		[ValidateSet('All', 'Graph', 'Azure', 'AipService', 'ExchangeOnline', 'SecurityCompliance', 'SharePointOnline')]
		[string[]]$Service = 'All',

		# The Exchange environment to connect to. Default is O365Default. Supported values include O365China, O365Default, O365GermanyCloud, O365USGovDoD, O365USGovGCCHigh.
		[ValidateSet('O365China', 'O365Default', 'O365GermanyCloud', 'O365USGovDoD', 'O365USGovGCCHigh')]
		[string]$ExchangeEnvironmentName = 'O365Default',

		# The User Principal Name to use for Security & Compliance PowerShell connection.
		[string]$UserPrincipalName,

		# The SharePoint Admin URL to use for SharePoint Online connection.
		[string]$SharePointAdminUrl
	)

	if (-not (Test-ZtLanguageMode)) {
		Stop-PSFFunction -Message "PowerShell is running in Constrained Language Mode, which is not supported." -EnableException $true -Cmdlet $PSCmdlet
		return
	}

	if ($Service -contains 'All') {
		$Service = [string[]]@('Graph', 'Azure', 'AipService', 'ExchangeOnline', 'SecurityCompliance', 'SharePointOnline')
	}
	else
	{
		# Connecting to Graph is mandatory or the report will fail.
		$Service += 'Graph'
	}

	#TODO: UseDeviceCode does not work with ExchangeOnline

	#region Validate Services
	$Service = $Service | Select-Object -Unique
	$resolvedRequiredModules = Resolve-ZtServiceRequiredModule -Service $Service
	$resolvedRequiredModules.ServiceAvailable.ForEach{
		# TODO: When we display, add the module details (Name, version, etc.) for the available modules for each service.
		Write-PSFMessage -Message ("Service '{0}' is available with its required modules:" -f $_) -Level Debug
		$resolvedRequiredModules.($_).Foreach{
			Write-PSFMessage -Message (" - {0} v{1}" -f $_.Name,$_.Version) -Level Debug
		}
	}

	$resolvedRequiredModules.ServiceUnavailable.ForEach{
		Write-Host -Object (' ⚠️ Service "{0}" is not available due to missing required modules: {1}.' -f $_, ($resolvedRequiredModules.Errors.Where({ $_.Service -eq $_ }).ModuleSpecification -join ', ')) -ForegroundColor Yellow
	}

	#endregion

	# For services where their requiredModules are available, attempt to import and connect.
	# If errors occurs, mark them as service unavailable and continue with the rest, instead of stopping the entire connection process.
	# if the connection is successful, add them to service available (module scope).
	switch ($resolvedRequiredModules.ServiceAvailable) {
		'Graph' {
			Write-Debug -Message ('Loading graph required modules: {0}' -f ($resolvedRequiredModules.Graph.Name -join ', '))
			$loadedGraphModules = $resolvedRequiredModules.Graph.ForEach{
				$_ | Import-Module -Global -ErrorAction Stop -PassThru
			}

			$loadedGraphModules.ForEach{
				Write-Debug -Message ('Module ''{0}'' v{1} loaded for Graph.' -f $_.Name, $_.Version)
			}

			Write-Host -Object "`nConnecting to Microsoft Graph" -ForegroundColor Cyan
			Write-PSFMessage -Message 'Connecting to Microsoft Graph'

			try {
				$connectMgGraphParams = @{
					NoWelcome = $true
					UseDeviceCode = $UseDeviceCode.IsPresent
					Environment = $Environment
					# TenantId = $TenantId
					# ClientId = $ClientId
				}

				if ($ClientId) {
					$connectMgGraphParams.ClientId = $ClientId
				}

				if ($TenantId) {
					$connectMgGraphParams.TenantId = $TenantId
				}

				if ($Certificate) {
					$connectMgGraphParams.Certificate = $Certificate
				}
				else {
					$connectMgGraphParams.Scopes = Get-ZtGraphScope
				}

				if (-not $UseTokenCache) {
					$connectMgGraphParams.ContextScope = 'Process'
				}

				Write-PSFMessage -Message "Connecting to Microsoft Graph with params: $($connectMgGraphParams | Out-String)" -Level Verbose
				$null = Connect-MgGraph @connectMgGraphParams -ErrorAction Stop -InformationAction SilentlyContinue
				$contextTenantId = (Get-MgContext).TenantId
				Write-Host -Object "   ✅ Connected" -ForegroundColor Green
				$script:ConnectedService += 'Graph'
			}
			catch {
				# TODO: Remove service from available.
				$graphException = $_
				$methodNotFound = $null
				if ($graphException.Exception.InnerException -is [System.MissingMethodException]) {
					$methodNotFound = $graphException.Exception.InnerException
				}
				elseif ($graphException.Exception -is [System.MissingMethodException]) {
					$methodNotFound = $graphException.Exception
				}

				Write-Host -Object "   ❌ Failed to connect." -ForegroundColor Yellow
				Write-Host -Object "       Tests requiring Microsoft Graph will not be executed." -ForegroundColor Yellow
				if ($methodNotFound -and $methodNotFound.Message -like '*Microsoft.Identity*') {
					Write-Warning -Message "DLL conflict detected (MissingMethodException in Microsoft.Identity). This typically occurs when incompatible versions of Microsoft.Identity.Client or Microsoft.IdentityModel.Abstractions are loaded."
					Write-Warning -Message "Please RESTART your PowerShell session and run Connect-ZtAssessment again, ensuring no other Microsoft modules are imported first."
				}

				Stop-PSFFunction -Message "Failed to authenticate to Graph" -ErrorRecord $graphException -EnableException $true -Cmdlet $PSCmdlet
			}

			try {
				Write-Verbose "Verifying Zero Trust context and permissions..."
				$null = Test-ZtContext
			}
			catch {
				# TODO: Remove service from available.
				$script:ConnectedService = $script:ConnectedService.Where{ $_ -ne 'Graph' }
				Stop-PSFFunction -Message "Authenticated to Graph, but the requirements for the ZeroTrustAssessment are not met by the established session:`n$_" -ErrorRecord $_ -EnableException $true -Cmdlet $PSCmdlet
			}
		}

		'Azure' {
			$loadedAzureModules = $resolvedRequiredModules.Azure.ForEach{
				$_ | Import-Module -Global -ErrorAction Stop -PassThru
			}

			$loadedAzureModules.ForEach{
				Write-Debug -Message ('Module ''{0}'' v{1} loaded for Azure.' -f $_.Name, $_.Version)
			}

			Write-Host "`nConnecting to Azure" -ForegroundColor Cyan
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
				# Tenant                  = $tenantParam
			}

			if ($tenantParam) {
				Write-Verbose -Message ("Using tenant ID '{0}' for Azure connection." -f $tenantParam)
				$azParams.Tenant = $tenantParam
			}

			if ($ClientId -and $Certificate) {
				$azParams.ApplicationId = $ClientId
				$azParams.CertificateThumbprint = $Certificate.Certificate.Thumbprint
			}

			try {
				Write-Verbose -Message ("Connecting to Azure with parameters: {0}" -f ($azParams | Out-String))
				$null = Connect-AzAccount @azParams -ErrorAction Stop -InformationAction Ignore
				Write-Host -Object "   ✅ Connected" -ForegroundColor Green
				$script:ConnectedService += 'Azure'
			}
			catch {
				Write-Host -Object "   ❌ Failed to connect." -ForegroundColor Yellow
				Write-Host -Object "       Tests requiring Azure will not be executed." -ForegroundColor Yellow
				$script:ConnectedService = $script:ConnectedService.Where{ $_ -ne 'Azure' }
				Stop-PSFFunction -Message "Failed to authenticate to Azure: $_" -ErrorRecord $_ -EnableException $true -Cmdlet $PSCmdlet
			}
		}

		'AipService' {
			Write-Host -Object "`nConnecting to Azure Information Protection" -ForegroundColor Cyan
			try {
				$loadedAipServiceModules = $resolvedRequiredModules.AipService.ForEach{
					#TODO: only add -UseWindowsPowerShell for the modules in WindowsRequiredModules based on module manifest.
					$_ | Import-Module -Global -ErrorAction Stop -PassThru -UseWindowsPowerShell -WarningAction SilentlyContinue
				}

				$loadedAipServiceModules.ForEach{
					Write-Debug -Message ('Module ''{0}'' v{1} loaded for Azure Information Protection.' -f $_.Name, $_.Version)
				}
			}
			catch {
				Write-Host -Object "Error loading AipService Module in WindowsPowerShell. $_" -ForegroundColor Red
				Write-PSFMessage $_ -Level Error
				#TODO: Mark service as unavailable and skip connection attempt.
			}

			try {
				$null = Connect-AipService -ErrorAction Stop
				Write-Host -Object "   ✅ Connected" -ForegroundColor Green
				$script:ConnectedService += 'AipService'
			}
			catch {
				Write-Host -Object "   ❌ Failed to connect." -ForegroundColor Yellow
				Write-Host -Object "       Tests requiring Microsoft Graph will not be executed." -ForegroundColor Yellow
				Write-Host "`nFailed to connect to Azure Information Protection: $_" -ForegroundColor Red
				Write-PSFMessage "Failed to connect to Azure Information Protection: $_" -Level Error
				#TODO: Mark service as unavailable.
				$script:ConnectedService = $script:ConnectedService.Where{ $_ -ne 'AipService' }
			}
		}

		'ExchangeOnline' {
			Write-Host -Object "`nConnecting to Exchange Online" -ForegroundColor Cyan
			try {
				$loadedExoModules = $resolvedRequiredModules.ExchangeOnline.ForEach{
					#TODO: only add -UseWindowsPowerShell for the modules in WindowsRequiredModules based on module manifest.
					$_ | Import-Module -Global -ErrorAction Stop -PassThru -WarningAction SilentlyContinue
					# Import-Module -Name ExchangeOnlineManagement -ErrorAction Stop -Global
				}

				$loadedExoModules.ForEach{
					Write-Debug -Message ('Module ''{0}'' v{1} loaded for Exchange Online.' -f $_.Name, $_.Version)
				}

				Write-Verbose -Message 'Connecting to Microsoft Exchange Online'


				if ($UseDeviceCode) {
					Connect-ExchangeOnline -ShowBanner:$false -Device:$UseDeviceCode -ExchangeEnvironmentName $ExchangeEnvironmentName
				}
				else {
					Connect-ExchangeOnline -ShowBanner:$false -ExchangeEnvironmentName $ExchangeEnvironmentName
				}

				# Fix for Get-Label visibility in other scopes
				if (Get-Command -Name Get-Label -ErrorAction Ignore) {
					$module = Get-Command -Name Get-Label | Select-Object -ExpandProperty Module
					if ($module -and $module.Name -like 'tmp_*') {
						Import-Module $module -Global -Force
					}
				}

				Write-Host -Object "   ✅ Connected" -ForegroundColor Green
				$script:ConnectedService += 'ExchangeOnline'
			}
			catch {
				Write-Host -Object "   ❌ Failed to connect." -ForegroundColor Yellow
				Write-Host -Object "       Tests requiring Exchange Online will not be executed." -ForegroundColor Yellow
				$script:ConnectedService = $script:ConnectedService.Where{ $_ -ne 'ExchangeOnline' }
			}
		}

		'SecurityCompliance' {
			Write-Host -Object "`nConnecting to Microsoft Security & Compliance PowerShell" -ForegroundColor Cyan
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

			try {
				$loadedExoSnPModules = $resolvedRequiredModules.SecurityCompliance.ForEach{
					#TODO: only add -UseWindowsPowerShell for the modules in WindowsRequiredModules based on module manifest.
					$_ | Import-Module -Global -ErrorAction Stop -PassThru
					# Import-Module -Name ExchangeOnlineManagement -ErrorAction Stop -Global
				}

				$loadedExoSnPModules.ForEach{
					Write-PSFMessage -Message ('Module ''{0}'' v{1} loaded for Security & Compliance.' -f $_.Name, $_.Version) -Level Debug
				}

			}
			catch {
				Write-Host -Object "   ❌ Failed to load required modules for Security & Compliance." -ForegroundColor Yellow
				Write-Host -Object "       Tests requiring Security & Compliance will not be executed." -ForegroundColor Yellow
				$script:ConnectedService = $script:ConnectedService.Where{ $_ -ne 'SecurityCompliance' }
				Write-PSFMessage -Message "Failed to load required modules for Security & Compliance: $_" -Level Error
			}

			if ($UseDeviceCode) {
				Write-Host -Object "`nThe Security & Compliance module does not support device code flow authentication." -ForegroundColor Red
			}
			else {
				# Get UPN from Exchange connection or Graph context
				#TODO: is that a nice to have or a hard dependency?
				$ExoUPN = $UserPrincipalName

				# Attempt to resolve UPN before any connection to avoid token acquisition failures without identity
				$connectionInformation = $null
				try {
					$connectionInformation = Get-ConnectionInformation
				}
				catch {
					# Intentionally swallow errors here; fall back to provided UPN if any
					$connectionInfoError = $_
					Write-Verbose -Message "Get-ConnectionInformation failed; falling back to provided UserPrincipalName if available. Error: $($connectionInfoError.Exception.Message)"
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

					Write-Verbose -Message "Connecting to Security & Compliance with UPN: $ExoUPN"
					Connect-IPPSSession @ippSessionParams
					Write-Host -Object "   ✅ Connected" -ForegroundColor Green
					$script:ConnectedService += 'SecurityCompliance'
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
					$script:ConnectedService = $script:ConnectedService.Where{ $_ -ne 'SecurityCompliance' }
				}
			}

			# Fix for Get-Label visibility in other scopes
			if (Get-Command -Name Get-Label -ErrorAction Ignore) {
				$module = Get-Command -Name Get-Label | Select-Object -ExpandProperty Module
				if ($module -and $module.Name -like 'tmp_*') {
					Import-Module $module -Global -Force
				}
			}
		}

		'SharePointOnline' {
			Write-Host -Object "`nConnecting to SharePoint Online" -ForegroundColor Cyan
			try {
				# TODO: Use resolved module to load.
				$loadedSharePointOnlineModules = $resolvedRequiredModules.SharePointOnline.ForEach{
					#TODO: only add -UseWindowsPowerShell for the modules in WindowsRequiredModules based on module manifest.
					$_ | Import-Module -Global -ErrorAction Stop -PassThru -UseWindowsPowerShell -WarningAction SilentlyContinue
					# Import-Module Microsoft.Online.SharePoint.PowerShell -UseWindowsPowerShell -WarningAction SilentlyContinue -ErrorAction Stop -Global
					# Import-Module -Name ExchangeOnlineManagement -ErrorAction Stop -Global
				}

				$loadedSharePointOnlineModules.ForEach{
					Write-Debug -Message ('Module ''{0}'' v{1} loaded for SharePoint Online.' -f $_.Name, $_.Version)
				}
			}
			catch {
				Write-Host "$_" -ForegroundColor Red
				Write-PSFMessage $_ -Level Error
				#TODO: Mark service as unavailable
			}

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
					Write-Host -Object "   ✅ Connected" -ForegroundColor Green
					$script:ConnectedService += 'SharePointOnline'
				}
				catch {
					Write-Host "`nFailed to connect to SharePoint Online: $_" -ForegroundColor Red
					Write-PSFMessage "Failed to connect to SharePoint Online: $_" -Level Error
					$script:ConnectedService = $script:ConnectedService.Where{ $_ -ne 'SharePointOnline' }
				}
			}
		}
	}
}
