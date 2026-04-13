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


	.EXAMPLE
		PS C:\> Connect-ZtAssessment

		Connects to Microsoft Graph and other services using Connect-MgGraph with the required scopes and other services.
		By default, on Windows, this connects to Graph, Azure, Exchange Online, Security & Compliance, SharePoint Online, and Azure Information Protection.
		On other platforms, this connects to Graph, Azure, Exchange and Security & Compliance (where supported).

	.EXAMPLE
		PS C:\> Connect-ZtAssessment -UseDeviceCode

		Connects to Microsoft Graph and Azure using the device code flow. This will open a browser window to prompt for authentication.

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
		$UseTokenCache,

		[string]
		$TenantId,

		[string]
		$ClientId,

		[PSFramework.Parameter.CertificateParameter]
		$Certificate,

		# The services to connect to such as Azure and ExchangeOnline. Default is All.
		[ValidateSet('All', 'Graph', 'Azure', 'AipService', 'ExchangeOnline', 'SecurityCompliance', 'SharePointOnline')]
		[string[]]
		$Service = 'All',

		# The Exchange environment to connect to. Default is O365Default. Supported values include O365China, O365Default, O365GermanyCloud, O365USGovDoD, O365USGovGCCHigh.
		[ValidateSet('O365China', 'O365Default', 'O365GermanyCloud', 'O365USGovDoD', 'O365USGovGCCHigh')]
		[string]
		$ExchangeEnvironmentName = 'O365Default',

		# The User Principal Name to use for Security & Compliance PowerShell connection.
		[string]
		$UserPrincipalName,

		# The SharePoint Admin URL to use for SharePoint Online connection.
		[string]
		$SharePointAdminUrl,

		# When specified, forces reconnection to services even if an existing connection is detected.
		# This is useful to refresh the connection context and permissions.
		[switch]
		$Force
	)

	if (-not (Test-ZtLanguageMode)) {
		Stop-PSFFunction -Message "PowerShell is running in Constrained Language Mode, which is not supported." -EnableException $true -Cmdlet $PSCmdlet
		return
	}

	# Set up container environment compatibility (xdg-open shim for browser auth, etc.)
	Initialize-ZtContainerEnvironment

	if ($Service -contains 'All') {
		$Service = [string[]]@('Graph', 'Azure', 'AipService', 'ExchangeOnline', 'SecurityCompliance', 'SharePointOnline')
	}
	elseif ($Service -notcontains 'Graph' -and $script:ConnectedService -notcontains 'Graph') {
		# If not already connected, always connect Graph.
		$Service += 'Graph'
	}

	#TODO: UseDeviceCode does not work with ExchangeOnline

	#region Validate Services
	$Service = $Service | Select-Object -Unique
	$resolvedRequiredModules = Resolve-ZtServiceRequiredModule -Service $Service
	Write-Host -Object ('🔑 Authentication to {0}.' -f ($Service -join ', ')) -ForegroundColor DarkGray
	Write-Host -Object ('During the next steps, you may be prompted to authenticate separately for several services.') -ForegroundColor DarkGray
	$resolvedRequiredModules.ServiceAvailable.ForEach{
		Write-PSFMessage -Message ("Service '{0}' is available with its required modules:" -f $_) -Level Debug
		$resolvedRequiredModules.($_).Foreach{
			Write-PSFMessage -Message (" - {0} v{1}" -f $_.Name,$_.Version) -Level Debug
		}
	}

	$resolvedRequiredModules.ServiceUnavailable.ForEach{
		$serviceName = $_
		Write-Host -Object (' ⚠️ Service "{0}" is not available due to missing required modules: {1}.' -f $serviceName, ($resolvedRequiredModules.Errors.Where({ $_.Service -eq $serviceName }).ModuleSpecification -join ', ')) -ForegroundColor Yellow
	}

	#endregion

	# For services where their requiredModules are available, attempt to import and connect.
	# If errors occurs, mark them as service unavailable and continue with the rest, instead of stopping the entire connection process.
	# if the connection is successful, add them to service available (module scope).
	switch ($resolvedRequiredModules.ServiceAvailable) {
		'Graph' {
			Write-Host -Object "`nConnecting to Microsoft Graph" -ForegroundColor Cyan
			Write-PSFMessage -Message 'Connecting to Microsoft Graph' -Level Verbose
			try {
				#region loading graph modules
				Write-PSFMessage -Message ('Loading graph required modules: {0}' -f ($resolvedRequiredModules.Graph.Name -join ', ')) -Level Verbose
				$loadedGraphModules = $resolvedRequiredModules.Graph.ForEach{
					$_ | Import-Module -Global -ErrorAction Stop -PassThru
				}

				$loadedGraphModules.ForEach{
					Write-Debug -Message ('Module ''{0}'' v{1} loaded for Graph.' -f $_.Name, $_.Version)
				}
				#endregion

				#region is Graph connected?

				# Assume we're not connected and we need to connect.
				[bool] $isGraphConnected = $false
				$context = Get-MgContext -ErrorAction Ignore
				if ($null -ne $context) {
					Write-PSFMessage -Message ('A connection to Microsoft Graph is already established with account "{0}".' -f $context.Account) -Level Debug
					$isGraphConnected = $true
					Write-PSFMessage -Message "Testing connection with ClientId ({0}), tenant ({1}) account ({2}) and Force ({3})." -Level Debug -StringValues @($context.ClientId, $context.TenantId, $context.Account, $Force.IsPresent)
				}
				else {
					Write-PSFMessage -Message "No existing connection to Microsoft Graph found." -Level Debug
				}

				#endregion

				# Graph might be connected, but:
				#   - with the wrong ClientId,
				#   - to the wrong tenant,
				#   - with the wrong Certificate,
				#   - without the required scopes/permissions for the assessment,
				# so we need to validate the context.
				# Validate the existing context separately so that missing scopes/roles trigger a reconnect
				# instead of causing the outer Graph connection logic to treat it as a fatal error.
				$isContextValid = $true
				if ($isGraphConnected) {
					try {
						$isContextValid = Test-ZtContext -ErrorAction Stop
					}
					catch {
						Write-PSFMessage -Message "Existing Graph context is invalid or missing required permissions. A reconnect will be attempted." -Level Debug
						$isContextValid = $false
					}
				}

				if ( #Comparing connection with parameters to determine if we can reuse the existing connection or need to reconnect.
					($isGraphConnected -and $Force.IsPresent) -or # If -Force is specified, ignore the existing context and reconnect regardless of parameters
					(
						$isGraphConnected -and
						(
							($PSBoundParameters.ContainsKey('ClientId') -and $context.ClientId -ne $ClientId) -or
							($PSBoundParameters.ContainsKey('TenantId') -and $context.TenantId -ne $TenantId) -or
							($PSBoundParameters.ContainsKey('Certificate') -and [string]::IsNullOrEmpty($context.Certificate.Thumbprint))
							#TODO: compare certificate thumbprint & Subject if possible
						)
					) -or
					($isGraphConnected -and -not $isContextValid) # if missing permission, reconnect to ask for the permissions needed for the assessment
				) {
					Write-PSFMessage -Message "Disconnecting from ClientId ({0}), tenant ({1}) account ({2})." -Level Debug -StringValues @($context.ClientId, $context.TenantId, $context.Account)
					#TODO: Disconnect ZtAssessment is not quiet enough
					$null = Disconnect-MgGraph -ErrorAction Ignore
					# Disconnect-ZtAssessment -Service Graph -InformationAction Ignore
					Remove-ZtConnectedService -Service 'Graph'
				}
				elseif ($isGraphConnected) { # if it's connected, and everything is ok.
					# Test the existing context to ensure it has the required permissions and is valid for use in the assessment. If not, disconnect and reconnect with the correct parameters.
					Write-PSFMessage -Message "Connected to Graph with the same info as specified in parameters." -Level Debug
					Add-ZtConnectedService -Service 'Graph'
					Write-Host -Object "   ✅ Already connected." -ForegroundColor Green
					$contextTenantId = $context.TenantId
					continue
				}

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

				# In container environments, auto-switch to device code flow if browser auth isn't viable
				if (-not $connectMgGraphParams.UseDeviceCode) {
					$useDeviceCodeFromContainer = Resolve-ZtContainerAuthMethod -DeviceLoginUrl 'https://microsoft.com/devicelogin'
					if ($useDeviceCodeFromContainer) {
						$connectMgGraphParams.UseDeviceCode = $true
					}
				}

				Write-PSFMessage -Message "Connecting to Microsoft Graph with params: $($connectMgGraphParams | Out-String)" -Level Verbose
				$null = Connect-MgGraph @connectMgGraphParams -ErrorAction Stop

				$mgContext = Get-MgContext
				if ($null -eq $mgContext) {
					$hint = Get-ZtContainerAuthFailureHint
					Stop-PSFFunction -Message $hint -EnableException $true -Cmdlet $PSCmdlet
				}

				$contextTenantId = $mgContext.TenantId
				Write-Host -Object "   ✅ Connected" -ForegroundColor Green
				Add-ZtConnectedService -Service 'Graph'
			}
			catch {
				$graphException = $_
				Write-PSFMessage -Message ("Failed to authenticate to Graph: {0}" -f $graphException.Message) -Level Error -ErrorRecord $_
				# Remove service from the connected list.
				Remove-ZtConnectedService -Service 'Graph'
				Write-Host -Object "   ❌ Failed to connect." -ForegroundColor Yellow
				Write-Host -Object "       Tests requiring Microsoft Graph cannot be executed." -ForegroundColor Yellow
				Write-Host -Object "       Graph is critical to the ZeroTrustAssessment report. Aborting." -ForegroundColor Yellow
				$methodNotFound = $null
				if ($graphException.Exception.InnerException -is [System.MissingMethodException]) {
					$methodNotFound = $graphException.Exception.InnerException
				}
				elseif ($graphException.Exception -is [System.MissingMethodException]) {
					$methodNotFound = $graphException.Exception
				}

				if ($methodNotFound -and $methodNotFound.Message -like '*Microsoft.Identity*') {
					Write-Warning -Message "DLL conflict detected (MissingMethodException in Microsoft.Identity). This typically occurs when incompatible versions of Microsoft.Identity.Client or Microsoft.IdentityModel.Abstractions are loaded."
					Write-Warning -Message "Please RESTART your PowerShell session and run Connect-ZtAssessment again, ensuring no other Microsoft modules are imported first."
				}

				Stop-PSFFunction -Message "Failed to authenticate to Graph. The requirements for the ZeroTrustAssessment are not met by the established session:`n$graphException" -ErrorRecord $graphException -EnableException $true -Cmdlet $PSCmdlet
			}

			try {
				if ($script:ConnectedService -contains 'Graph') {
					Write-PSFMessage -Message "Verifying Graph connection and permissions..." -Level Debug
					$null = Test-ZtContext
					Write-PSFMessage -Message "Ok." -Level Debug
				}
			}
			catch {
				Remove-ZtConnectedService -Service 'Graph'
				Stop-PSFFunction -Message "Authenticated to Graph, but the requirements for the ZeroTrustAssessment are not met by the established session:`n$_" -ErrorRecord $_ -EnableException $true -Cmdlet $PSCmdlet
			}
		}

		'Azure' {
			Write-Host -Object "`nConnecting to Azure" -ForegroundColor Cyan
			Write-PSFMessage -Message 'Connecting to Azure' -Level Verbose
			try {
				#region Load Azure Modules
				Write-PSFMessage -Message ('Loading Azure required modules: {0}' -f ($resolvedRequiredModules.Azure.Name -join ', ')) -Level Verbose
				$loadedAzureModules = $resolvedRequiredModules.Azure.ForEach{
					$_ | Import-Module -Global -ErrorAction Stop -PassThru
				}

				$loadedAzureModules.ForEach{
					Write-Debug -Message ('Module ''{0}'' v{1} loaded for Azure.' -f $_.Name, $_.Version)
				}
				#endregion

				$azEnvironment = 'AzureCloud'
				if ($Environment -eq 'China') {
					$azEnvironment = Get-AzEnvironment -Name AzureChinaCloud
				}
				elseif ($Environment -in 'USGov', 'USGovDoD') {
					$azEnvironment = 'AzureUSGovernment'
				}

				# Grab the Tenant ID from parameters if specified, otherwise from Graph context if available, otherwise rely on default tenant.
				$isAzureConnected = $false
				$azContext = Get-AzContext -ErrorAction Ignore
				if ($null -ne $azContext) {
					Write-PSFMessage -Message ('A connection to Azure is already established with account "{0}".' -f $azContext.Account) -Level Debug
					$isAzureConnected = $true
				}
				else {
					Write-PSFMessage -Message "No existing connection to Azure found." -Level Debug
				}

				# Determine whether Azure will use service principal authentication
				# (both ClientId and Certificate supplied).
				$useAzureServicePrincipalAuth = $PSBoundParameters.ContainsKey('ClientId') -and $PSBoundParameters.ContainsKey('Certificate')

				# Azure might be connected, but:
				#   - with the wrong ClientId,
				#   - to the wrong tenant,
				#   - with the wrong Certificate,
				#   - without the required scopes/permissions for the assessment,
				# so we need to validate the context.
				if (
					($isAzureConnected -and $Force.IsPresent) -or
					(
						$isAzureConnected -and
						(
							(
								$PSBoundParameters.ContainsKey('TenantId') -and
								$azContext.Tenant.Id -ne $TenantId
							) -or
							(
								$useAzureServicePrincipalAuth -and
								$PSBoundParameters.ContainsKey('ClientId') -and
								$azContext.Account.Id -ne $ClientId
							) -or
							(
								$useAzureServicePrincipalAuth -and
								$PSBoundParameters.ContainsKey('Certificate') -and
								[string]::IsNullOrEmpty($azContext.Account.CertificateThumbprint)
							)
						)
					)
				) {
					Write-PSFMessage -Message "Current connection with TenantId ({0}) and Account ({1}) is different than the one specified in parameters." -Level Debug -StringValues @($azContext.Tenant.Id, $azContext.Account.Id)
					$null = Disconnect-AzAccount -ErrorAction Ignore
					$isAzureConnected = $false
					Remove-ZtConnectedService -Service 'Azure'
				}
				elseif ($isAzureConnected) {
					Write-PSFMessage -Message "Connected to Azure with the same info as specified in parameters." -Level Debug
					Add-ZtConnectedService -Service 'Azure'
					Write-Host -Object "   ✅ Already connected." -ForegroundColor Green
					continue
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

				Write-Verbose -Message ("Connecting to Azure with parameters: {0}" -f ($azParams | Out-String))
				$null = Connect-AzAccount @azParams -ErrorAction Stop
				Write-Host -Object "   ✅ Connected" -ForegroundColor Green
				Add-ZtConnectedService -Service 'Azure'
			}
			catch {
				Write-PSFMessage -Message ("Failed to authenticate to Azure: {0}" -f $_) -Level Debug -ErrorRecord $_
				Remove-ZtConnectedService -Service 'Azure'
				Write-Host -Object "   ❌ Failed to connect." -ForegroundColor Yellow
				Write-Host -Object "      Tests requiring Azure will be skipped." -ForegroundColor Yellow
				Write-Host -Object ("       Error details: {0}" -f $_) -ForegroundColor Red
			}
		}

		'AipService' {
			Write-Host -Object "`nConnecting to Azure Information Protection" -ForegroundColor Cyan
			Write-PSFMessage -Message 'Connecting to Azure Information Protection' -Level Verbose
			try {
				Write-PSFMessage -Message ('Loading Azure Information Protection required modules: {0}' -f ($resolvedRequiredModules.AipService.Name -join ', ')) -Level Verbose
				$loadedAipServiceModules = $resolvedRequiredModules.AipService.ForEach{
					#TODO: only add -UseWindowsPowerShell for the modules in WindowsRequiredModules based on module manifest.
					$_ | Import-Module -Global -ErrorAction Stop -PassThru -UseWindowsPowerShell -WarningAction SilentlyContinue
				}

				$loadedAipServiceModules.ForEach{
					Write-Debug -Message ('Module ''{0}'' v{1} loaded for Azure Information Protection.' -f $_.Name, $_.Version)
				}

			}
			catch {
				Write-Host -Object "   ❌ Failed to load Azure Information Protection modules." -ForegroundColor Yellow
				Write-Host -Object "       Tests requiring Azure Information Protection will be skipped." -ForegroundColor Yellow
				Write-Host -Object ("       Error details: {0}" -f $_) -ForegroundColor Red
				Write-PSFMessage -Message ("Error loading AipService Module in WindowsPowerShell: {0}" -f $_) -Level Debug -ErrorRecord $_
				# Mark service as unavailable and skip connection attempt.
				Remove-ZtConnectedService -Service 'AipService'
				continue
			}

			try {
					Write-PSFMessage -Message "Connecting to Azure Information Protection" -Level Verbose
					# Connect-AipService does not have parameters for non-interactive auth, so it will use the existing Graph connection context if available, or prompt if not.
					$null = Connect-AipService -ErrorAction Stop
					Write-Host -Object "   ✅ Connected" -ForegroundColor Green
					Add-ZtConnectedService -Service 'AipService'
			}
			catch {
				Write-Host -Object "   ❌ Failed to connect." -ForegroundColor Yellow
				Write-Host -Object "       Tests requiring Azure Information Protection will be skipped." -ForegroundColor Yellow
				Write-Host -Object ("       Error details: {0}" -f $_) -ForegroundColor Red
				Write-PSFMessage -Message ("Failed to connect to Azure Information Protection: {0}" -f $_) -Level Debug -ErrorRecord $_
				# Mark service as unavailable.
				Remove-ZtConnectedService -Service 'AipService'
			}
		}

		'ExchangeOnline' {
			Write-Host -Object "`nConnecting to Exchange Online" -ForegroundColor Cyan
			try {
				Write-PSFMessage -Message ('Loading Exchange Online required modules: {0}' -f ($resolvedRequiredModules.ExchangeOnline.Name -join ', ')) -Level Verbose
				$loadedExoModules = $resolvedRequiredModules.ExchangeOnline.ForEach{
					#TODO: only add -UseWindowsPowerShell for the modules in WindowsRequiredModules based on module manifest.
					$_ | Import-Module -Global -ErrorAction Stop -PassThru -WarningAction SilentlyContinue
				}

				$loadedExoModules.ForEach{
					Write-Debug -Message ('Module ''{0}'' v{1} loaded for Exchange Online.' -f $_.Name, $_.Version)
				}

				Write-Verbose -Message 'Connecting to Microsoft Exchange Online'
				if ($UseDeviceCode) {
					$null = Connect-ExchangeOnline -ShowBanner:$false -Device:$UseDeviceCode -ExchangeEnvironmentName $ExchangeEnvironmentName -ErrorAction Stop
				}
				else {
					$null = Connect-ExchangeOnline -ShowBanner:$false -ExchangeEnvironmentName $ExchangeEnvironmentName -ErrorAction Stop
				}

				# Fix for Get-Label visibility in other scopes
				if (Get-Command -Name Get-Label -ErrorAction Ignore) {
					$module = Get-Command -Name Get-Label | Select-Object -ExpandProperty Module
					if ($module -and $module.Name -like 'tmp_*') {
						Import-Module $module -Global #-Force
					}
				}

				Write-Host -Object "   ✅ Connected" -ForegroundColor Green
				Add-ZtConnectedService -Service 'ExchangeOnline'
			}
			catch {
				Write-Host -Object "   ❌ Failed to connect." -ForegroundColor Yellow
				Write-Host -Object "      Tests requiring Exchange Online will be skipped." -ForegroundColor Yellow
				Write-Host -Object ("       Error details: {0}" -f $_) -ForegroundColor Red
				Write-PSFMessage -Message ("Failed to connect to Exchange Online: {0}" -f $_) -Level Debug -ErrorRecord $_
				Remove-ZtConnectedService -Service 'ExchangeOnline'
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

			$exoSnCModulesLoaded = $false
			try {
				$loadedExoSnCModules = $resolvedRequiredModules.SecurityCompliance.ForEach{
					#TODO: only add -UseWindowsPowerShell for the modules in WindowsRequiredModules based on module manifest.
					$_ | Import-Module -Global -ErrorAction Stop -PassThru -WarningAction SilentlyContinue
				}

				$loadedExoSnCModules.ForEach{
					Write-PSFMessage -Message ('Module ''{0}'' v{1} loaded for Security & Compliance.' -f $_.Name, $_.Version) -Level Debug
				}

				$exoSnCModulesLoaded = $true
			}
			catch {
				Write-Host -Object "   ❌ Failed to load required modules for Security & Compliance." -ForegroundColor Yellow
				Write-Host -Object "      Tests requiring Security & Compliance will be skipped." -ForegroundColor Yellow
				Write-Host -Object ("       Error details: {0}" -f $_) -ForegroundColor Red
				Remove-ZtConnectedService -Service 'SecurityCompliance'
				Write-PSFMessage -Message "Failed to load required modules for Security & Compliance: $_" -Level Debug -ErrorRecord $_
			}

			if ($UseDeviceCode) {
				Write-Host -Object "`nThe Security & Compliance module does not support device code flow authentication." -ForegroundColor Red
			}
			elseif ($exoSnCModulesLoaded) {
				try {
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
						throw "`nUnable to determine a UserPrincipalName for Security & Compliance. Please supply -UserPrincipalName or connect to Exchange Online first."
					}

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

					# Fix for Get-Label visibility in other scopes
					if (Get-Command -Name Get-Label -ErrorAction Ignore) {
						$module = Get-Command -Name Get-Label | Select-Object -ExpandProperty Module
						if ($module -and $module.Name -like 'tmp_*') {
							Import-Module $module -Global #-Force
						}
					}

					Add-ZtConnectedService -Service 'SecurityCompliance'
				}
				catch {
					Write-Host -Object "   ❌ Failed to connect." -ForegroundColor Yellow
					Write-Host -Object "      Tests requiring Security & Compliance will be skipped." -ForegroundColor Yellow
					Write-Host -Object ("       Error details: {0}" -f $_.Exception.Message) -ForegroundColor Red
					Write-PSFMessage -Message ("Failed to connect to Security & Compliance PowerShell: {0}" -f $_.Exception.Message) -Level Debug -ErrorRecord $_

					Remove-ZtConnectedService -Service 'SecurityCompliance'
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
				}
			}
		}

		'SharePointOnline' {
			Write-Host -Object "`nConnecting to SharePoint Online" -ForegroundColor Cyan
			try {
				Write-PSFMessage -Message ('Loading SharePoint Online required modules: {0}' -f ($resolvedRequiredModules.SharePointOnline.Name -join ', ')) -Level Verbose
				$loadedSharePointOnlineModules = $resolvedRequiredModules.SharePointOnline.ForEach{
					#TODO: only add -UseWindowsPowerShell for the modules in WindowsRequiredModules based on module manifest.
					$_ | Import-Module -Global -ErrorAction Stop -PassThru -UseWindowsPowerShell -WarningAction SilentlyContinue
					# Import-Module Microsoft.Online.SharePoint.PowerShell -UseWindowsPowerShell -WarningAction SilentlyContinue -ErrorAction Stop -Global
				}

				$loadedSharePointOnlineModules.ForEach{
					Write-Debug -Message ('Module ''{0}'' v{1} loaded for SharePoint Online.' -f $_.Name, $_.Version)
				}
			}
			catch {
				Write-Host -Object "   ❌ Failed to load required modules for SharePoint Online." -ForegroundColor Yellow
				Write-Host -Object "      Tests requiring SharePoint Online will be skipped." -ForegroundColor Yellow
				Write-Host -Object ("       Error details: {0}" -f $_.Exception.Message) -ForegroundColor Red
				Write-PSFMessage -Message ("Failed to load required modules for SharePoint Online: {0}" -f $_) -Level Debug -ErrorRecord $_
				# Mark service as unavailable
				Remove-ZtConnectedService -Service 'SharePointOnline'
				continue
			}

			[string] $adminUrl = $null
			if (-not [string]::IsNullOrEmpty($SharePointAdminUrl)) {
				Write-Verbose -Message "Using provided SharePoint Admin URL: $SharePointAdminUrl"
				$adminUrl = $SharePointAdminUrl # Attempt to read from parameter
			}
			elseif (-not $adminUrl  -and (Get-Command -Name Get-MgContext -ErrorAction Ignore) -and ($graphContext = Get-MgContext -ErrorAction Ignore)) {
				# Try to infer from Graph context
				if ($graphContext.TenantId) {
					try {
						$org = Invoke-ZtGraphRequest -RelativeUri 'organization'
						$initialDomain = $org.verifiedDomains | Where-Object { $_.isInitial } | Select-Object -ExpandProperty name -First 1
						if ($initialDomain) {
							$tenantName = $initialDomain.Split('.')[0]
							$adminUrl = "https://$tenantName-admin.sharepoint.com"
							Write-Verbose -Message "Inferred SharePoint Admin URL from Graph: $adminUrl"
						}
					}
					catch {
						Write-Verbose -Message "Failed to infer SharePoint Admin URL from Graph: $($_.Exception.Message)"
					}
				}
			}
			elseif(-not $adminUrl) {
				Write-Verbose -Message "No Graph context available to infer SharePoint Admin URL."
				# We don't want to let the service 'Graph' be marked as connected, it's not.
				Remove-ZtConnectedService -Service 'Graph'
			}

			if (-not $adminUrl -and (Get-Command -Name Get-AzTenant -ErrorAction Ignore) -and ($tenantDetails = Get-AzTenant -ErrorAction Ignore)) {
				# Try to infer from Azure context
				try {
					# initial domain are <tenantName>.onmicrosoft.com as per https://learn.microsoft.com/en-us/entra/fundamentals/add-custom-domain
					$initialDomain = $tenantDetails.Domains.Where({ $_ -match '^[^.]+\.onmicrosoft\.com$' }, 1) | Select-Object -First 1
					if ($initialDomain) {
						$tenantName = $initialDomain.Split('.')[0]
						$adminUrl = "https://$tenantName-admin.sharepoint.com"
						Write-Verbose -Message "Inferred SharePoint Admin URL from Azure context: $adminUrl"
					}
				}
				catch {
					Write-Verbose -Message "Failed to infer SharePoint Admin URL from Azure context: $($_.Exception.Message)"
				}
			}
			elseif (-not $adminUrl) {
				Write-Verbose -Message "No Azure context available to infer SharePoint Admin URL."
				Remove-ZtConnectedService -Service 'Azure'
			}

			if (-not $adminUrl) {
				Write-Host -Object "   ❌ SharePoint Admin URL not provided and could not be inferred." -ForegroundColor Red
				Write-Host -Object "       The SharePoint tests will be skipped." -ForegroundColor Red
				Write-PSFMessage -Message "SharePoint Admin URL not provided and could not be inferred. Skipping SharePoint connection." -Level debug
				Remove-ZtConnectedService -Service 'SharePointOnline'
			}
			else {
				try {
					Connect-SPOService -Url $adminUrl -ErrorAction Stop
					Write-Host -Object "   ✅ Connected" -ForegroundColor Green
					Add-ZtConnectedService -Service 'SharePointOnline'
				}
				catch {
					Write-PSFMessage -Message ('Failed to connect to SharePoint Online: {0}' -f $_.Exception.Message) -Level Debug -ErrorRecord $_
					Write-Host -Object "   ❌ Failed to connect." -ForegroundColor Yellow
					Write-Host -Object "      Tests requiring SharePoint Online will be skipped." -ForegroundColor Yellow
					Write-Host -Object ("       Error details: {0}" -f $_.Exception.Message) -ForegroundColor Red
					Remove-ZtConnectedService -Service 'SharePointOnline'
				}
			}
		}
	}
}
