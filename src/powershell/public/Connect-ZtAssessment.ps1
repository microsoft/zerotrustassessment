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
		Supported for Graph, Azure, ExchangeOnline, SecurityCompliance, and SharePointOnline via Certificate-Based Authentication (CBA).
		AipService does not support app-only certificate-based authentication and will be skipped when this parameter is used.
		The certificate with its private key must be installed in the local certificate store on the machine running the assessment.

	.PARAMETER IgnoreLanguageMode
		When specified, bypasses the Constrained Language Mode safety check and allows the connection to
		proceed even when PowerShell reports a non-Full language mode (e.g. in WDAC-managed environments
		where the module's signing certificate is trusted by policy).
		WARNING: Some functionality may fail if CLM restrictions are truly in effect.


	.EXAMPLE
		PS C:\> Connect-ZtAssessment

		Connects to Microsoft Graph and other services using Connect-MgGraph with the required scopes and other services.
		By default, on Windows, this connects to Graph, Azure, Exchange Online, Security & Compliance, SharePoint Online, and Azure Information Protection.
		On other platforms, this connects to Graph, Azure, Exchange and Security & Compliance (where supported).

	.EXAMPLE
		PS C:\> Connect-ZtAssessment -UseDeviceCode

		Connects to Microsoft Graph and Azure using the device code flow. This will open a browser window to prompt for authentication.

	.EXAMPLE
		PS C:\> Connect-ZtAssessment -ClientID $clientID -TenantID $tenantID -Certificate 'CN=ZeroTrustAssessment' -Service All

		Connects to all supported services using app-only Certificate-Based Authentication (CBA) with the specified client/application ID & tenant ID,
		using the latest, valid certificate available with the subject 'CN=ZeroTrustAssessment'.
		This assumes the application has the required Application permissions and Exchange/SharePoint admin roles assigned.
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
		$Force,

		# When specified, bypasses the Constrained Language Mode check. Use only in WDAC-managed environments
		# where the session reports CLM but the module is trusted and runs with full capability.
		[switch]
		$IgnoreLanguageMode
	)

	if (-not (Test-ZtLanguageMode -IgnoreLanguageMode:$IgnoreLanguageMode)) {
		Stop-PSFFunction -Message "PowerShell is running in Constrained Language Mode, which is not supported." -EnableException $true -Cmdlet $PSCmdlet
		return
	}
	if ($IgnoreLanguageMode) { $script:IgnoreLanguageMode = $true }

	if ($Certificate -and (-not $ClientId -or -not $TenantId)) {
		Stop-PSFFunction -Message "When -Certificate is specified, both -ClientId and -TenantId are required for app-only authentication." -EnableException $true -Cmdlet $PSCmdlet
		return
	}

	if ($Service -contains 'All') {
		$Service = [string[]]@('Graph', 'Azure', 'AipService', 'ExchangeOnline', 'SecurityCompliance', 'SharePointOnline')
	}
	elseif ($Service -notcontains 'Graph' -and $script:ConnectedService -notcontains 'Graph') {
		# If not already connected, always connect Graph first so downstream services (e.g. SPO)
		# can infer tenant details from the Graph context. Prepend to ensure ordering.
		$Service = [string[]]@('Graph') + $Service
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
					# Resolve the initial domain even for existing connections so EXO, S&C, and SPO can use it.
					try {
						$resolvedOrg = Invoke-ZtGraphRequest -RelativeUri 'organization' -ErrorAction Stop
						$script:resolvedInitialDomain = $resolvedOrg.verifiedDomains | Where-Object { $_.isInitial } | Select-Object -ExpandProperty name -First 1
					}
					catch {
						Write-Verbose -Message "Failed to resolve initial domain from existing Graph connection: $($_.Exception.Message)"
					}
					continue
				}

				$connectMgGraphParams = @{
					NoWelcome = $true
					Environment = $Environment
					# TenantId = $TenantId
					# ClientId = $ClientId
				}

				if ($UseDeviceCode) {
					$connectMgGraphParams.UseDeviceCode = $true
				}

				if ($ClientId) {
					$connectMgGraphParams.ClientId = $ClientId
				}

				if ($TenantId) {
					$connectMgGraphParams.TenantId = $TenantId
				}

				if ($Certificate) {
					$connectMgGraphParams.Certificate = $Certificate.Certificate
				}
				else {
					$connectMgGraphParams.Scopes = Get-ZtGraphScope
				}

				if (-not $UseTokenCache) {
					$connectMgGraphParams.ContextScope = 'Process'
				}

				Write-PSFMessage -Message "Connecting to Microsoft Graph with params: $($connectMgGraphParams | Out-String)" -Level Verbose
				$null = Connect-MgGraph @connectMgGraphParams -ErrorAction Stop
				$contextTenantId = (Get-MgContext).TenantId
				Write-Host -Object "   ✅ Connected" -ForegroundColor Green
				Add-ZtConnectedService -Service 'Graph'
				# Resolve the initial domain once here so EXO, S&C, and SPO can reuse it without redundant Graph calls.
				try {
					$resolvedOrg = Invoke-ZtGraphRequest -RelativeUri 'organization' -ErrorAction Stop
					$script:resolvedInitialDomain = $resolvedOrg.verifiedDomains | Where-Object { $_.isInitial } | Select-Object -ExpandProperty name -First 1
				}
				catch {
					Write-Verbose -Message "Failed to resolve initial domain after Graph connect: $($_.Exception.Message)"
				}
				if (-not $script:resolvedInitialDomain) {
					Write-PSFMessage -Message "Could not resolve the initial tenant domain from Graph. EXO, S&C, and SPO CBA connections may fail." -Level Warning
				}
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
					Environment             = $azEnvironment
					# Tenant                  = $tenantParam
				}

				if ($UseDeviceCode) {
					$azParams.UseDeviceAuthentication = $true
				}

				if ($tenantParam) {
					Write-Verbose -Message ("Using tenant ID '{0}' for Azure connection." -f $tenantParam)
					$azParams.Tenant = $tenantParam
				}

				if ($ClientId -and $Certificate) {
					$azParams.ApplicationId = $ClientId
					$azParams.CertificateThumbprint = $Certificate.Certificate.Thumbprint
					$azParams.ServicePrincipal = $true
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
					if ($ClientId -and $Certificate) {
						# Connect-AipService does not support app-only certificate-based authentication.
						# The -ApplicationId / -CertificateThumbprint / -ServicePrincipal parameters exist
						# but silently fail regardless of permissions. Skip to avoid triggering browser auth.
						Write-Host -Object "   ⚠️ AipService does not support app-only (certificate) authentication." -ForegroundColor Yellow
						Write-Host -Object "      AIP tests will be skipped." -ForegroundColor Yellow
						Remove-ZtConnectedService -Service 'AipService'
						continue
					}
					# Connect-AipService does not support certificate-based authentication via an X509Certificate2
					# object or app-only service principal flow. Connect using the existing authenticated session;
					# it will use the Graph/Az context or prompt interactively if needed.
					$null = Connect-AipService -ErrorAction Stop
					Write-Host -Object "   ✅ Connected" -ForegroundColor Green
					Add-ZtConnectedService -Service 'AipService'
			}
			catch {
				Write-Host -Object "   ❌ Failed to connect." -ForegroundColor Yellow
				Write-Host -Object "       Tests requiring Azure Information Protection will be skipped." -ForegroundColor Yellow
				Write-Host -Object ("       Error details: {0}" -f $_.Exception.Message) -ForegroundColor Red
				Write-PSFMessage -Message ("Failed to connect to Azure Information Protection: {0}" -f $_.Exception.Message) -Level Debug -ErrorRecord $_
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
				if ($ClientId -and $Certificate) {
					# App-only CBA: requires -AppId, -Certificate, and -Organization (primary *.onmicrosoft.com domain, not a GUID).
					$exoOrganization = $script:resolvedInitialDomain
					if (-not $exoOrganization) {
						Write-Host -Object "   ❌ Unable to determine the organization domain for Exchange Online CBA." -ForegroundColor Red
						Write-Host -Object "       The Exchange Online tests will be skipped." -ForegroundColor Red
						Write-PSFMessage -Message "Unable to determine the organization domain for Exchange Online CBA. Skipping Exchange Online connection." -Level Debug
						Remove-ZtConnectedService -Service 'ExchangeOnline'
						continue
					}
					Write-PSFMessage -Message "Using app-only CBA for Exchange Online with AppId '{0}' and organization '{1}'." -Level Verbose -StringValues @($ClientId, $exoOrganization)
					$null = Connect-ExchangeOnline `
						-ShowBanner:$false `
						-AppId $ClientId `
						-Certificate $Certificate.Certificate `
						-Organization $exoOrganization `
						-ExchangeEnvironmentName $ExchangeEnvironmentName `
						-ErrorAction Stop
				}
				elseif ($UseDeviceCode) {
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
				Write-Host -Object ("       Error details: {0}" -f $_.Exception.Message) -ForegroundColor Red
				Write-PSFMessage -Message ("Failed to connect to Exchange Online: {0}" -f $_.Exception.Message) -Level Debug -ErrorRecord $_
				Remove-ZtConnectedService -Service 'ExchangeOnline'

				$exoConflictException = @($_.Exception.InnerException, $_.Exception) |
					Where-Object { $_ -is [System.MissingMethodException] -or $_ -is [System.IO.FileLoadException] } |
					Select-Object -First 1
				if ($exoConflictException -and ($exoConflictException.Message -like '*Microsoft.Identity.Client*' -or $exoConflictException.Message -like '*Microsoft.IdentityModel.Abstractions*')) {
					Write-Warning "DLL Conflict detected ($($exoConflictException.GetType().Name)). This usually happens if Microsoft.Graph is loaded before ExchangeOnlineManagement."
					Write-Warning "Please RESTART your PowerShell session and run Connect-ZtAssessment again."
				}
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
					if ($ClientId -and $Certificate) {
						# App-only CBA: requires -AppId, -Certificate, and -Organization (primary *.onmicrosoft.com domain, not a GUID).
						$ippsOrganization = $script:resolvedInitialDomain
						if (-not $ippsOrganization) {
							Write-Host -Object "   ❌ Unable to determine the organization domain for Security & Compliance CBA." -ForegroundColor Red
							Write-Host -Object "       The Security & Compliance tests will be skipped." -ForegroundColor Red
							Write-PSFMessage -Message "Unable to determine the organization domain for Security & Compliance CBA. Skipping Security & Compliance connection." -Level Debug
							Remove-ZtConnectedService -Service 'SecurityCompliance'
							continue
						}
						Write-PSFMessage -Message "Using app-only CBA for Security & Compliance with AppId '{0}' and organization '{1}'." -Level Verbose -StringValues @($ClientId, $ippsOrganization)
						$ippSessionParams = @{
							AppId        = $ClientId
							Certificate  = $Certificate.Certificate
							Organization = $ippsOrganization
							ShowBanner   = $false
							ErrorAction  = 'Stop'
						}
						if ($ExchangeEnvironmentName -ne 'O365Default') {
							$ippSessionParams.ConnectionUri = $Environments[$ExchangeEnvironmentName].ConnectionUri
							$ippSessionParams.AzureADAuthorizationEndpointUri = $Environments[$ExchangeEnvironmentName].AuthZEndpointUri
						}
						Write-Verbose -Message "Connecting to Security & Compliance with CBA for organization: $ippsOrganization"
						Connect-IPPSSession @ippSessionParams
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
					}
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

					$sncConflictException = @($_.Exception.InnerException, $_.Exception) |
						Where-Object { $_ -is [System.MissingMethodException] -or $_ -is [System.IO.FileLoadException] } |
						Select-Object -First 1
					if ($sncConflictException -and ($sncConflictException.Message -like '*Microsoft.Identity.Client*' -or $sncConflictException.Message -like '*Microsoft.IdentityModel.Abstractions*')) {
						Write-Warning "DLL Conflict detected ($($sncConflictException.GetType().Name)). This usually happens if Microsoft.Graph is loaded before ExchangeOnlineManagement."
						Write-Warning "Please RESTART your PowerShell session and run Connect-ZtAssessment again."
					}
				}
			}
		}

		'SharePointOnline' {
			Write-Host -Object "`nConnecting to SharePoint Online" -ForegroundColor Cyan
			try {
				Write-PSFMessage -Message ('Loading SharePoint Online required modules: {0}' -f ($resolvedRequiredModules.SharePointOnline.Name -join ', ')) -Level Verbose
				# Microsoft.Online.SharePoint.PowerShell is a Windows-only module. Always load via -UseWindowsPowerShell
				# (WinPS implicit remoting). Loading it natively in PS7 breaks certificate-based authentication.
				$loadedSharePointOnlineModules = $resolvedRequiredModules.SharePointOnline.ForEach{
					#TODO: only add -UseWindowsPowerShell for the modules in WindowsRequiredModules based on module manifest.
					$_ | Import-Module -Global -ErrorAction Stop -PassThru -UseWindowsPowerShell -WarningAction SilentlyContinue
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

			[string] $adminUrl = $SharePointAdminUrl

			# Try to infer from the already-resolved initial domain (cached after Graph connected)
			if (-not $adminUrl -and $script:resolvedInitialDomain) {
				$tenantName = $script:resolvedInitialDomain.Split('.')[0]
				$spoSuffix = switch ($Environment) {
					'USGov'    { 'sharepoint.us' }
					'USGovDoD' { 'sharepoint.us' }
					'China'    { 'sharepoint.cn' }
					default    { 'sharepoint.com' }
				}
				$adminUrl = "https://$tenantName-admin.$spoSuffix"
				Write-Verbose -Message "Inferred SharePoint Admin URL from Graph: $adminUrl"
			}

			if (-not $adminUrl) {
				Write-Host -Object "   ❌ SharePoint Admin URL not provided and could not be inferred from the tenant domain." -ForegroundColor Red
				Write-Host -Object "       Use -SharePointAdminUrl to specify the URL directly. The SharePoint tests will be skipped." -ForegroundColor Red
				Write-PSFMessage -Message "SharePoint Admin URL not provided and could not be inferred from the tenant domain. Skipping SharePoint connection." -Level Debug
				Remove-ZtConnectedService -Service 'SharePointOnline'
			}
			else {
				try {
					if ($ClientId -and $TenantId -and $Certificate) {
						Write-PSFMessage -Message "Using app-only CBA for SharePoint Online with ClientId '{0}'." -Level Verbose -StringValues @($ClientId)
						# Connect-SPOService is loaded via WinPS5 implicit remoting. The -CertificateThumbprint parameter
						# searches Cert:\CurrentUser\My inside the WinPS5 process which may not see the current session's
						# cert store. Export the cert to a temp PFX and pass its path + password to bypass store lookup.
						$tempPfxPath = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), [System.IO.Path]::GetRandomFileName() + '.pfx')
						$tempPassword = [System.Convert]::ToBase64String([System.Security.Cryptography.RandomNumberGenerator]::GetBytes(32))
						$tempSecurePassword = ConvertTo-SecureString $tempPassword -AsPlainText -Force
						try {
							$pfxBytes = $Certificate.Certificate.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Pfx, $tempPassword)
							[System.IO.File]::WriteAllBytes($tempPfxPath, $pfxBytes)
							$pfxBytes = $null  # Limit plaintext private key material in memory
							Connect-SPOService -Url $adminUrl -ClientId $ClientId -TenantId $TenantId -CertificatePath $tempPfxPath -CertificatePassword $tempSecurePassword -ErrorAction Stop
						}
						catch [System.Security.Cryptography.CryptographicException] {
							Write-Host -Object "   ❌ Failed to export the certificate private key for SharePoint Online." -ForegroundColor Red
							Write-Host -Object "      The certificate's private key must be marked as exportable." -ForegroundColor Yellow
							Write-Host -Object "      Re-import the certificate with 'Mark this key as exportable' enabled and try again." -ForegroundColor Yellow
							Write-PSFMessage -Message ("Failed to export certificate private key for SharePoint Online CBA: {0}" -f $_.Exception.Message) -Level Debug -ErrorRecord $_
							Remove-ZtConnectedService -Service 'SharePointOnline'
							continue
						}
						finally {
							if (Test-Path $tempPfxPath -ErrorAction SilentlyContinue) {
								Remove-Item $tempPfxPath -Force -ErrorAction SilentlyContinue
							}
						}
					}
					else {
						Connect-SPOService -Url $adminUrl -ErrorAction Stop
					}
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
