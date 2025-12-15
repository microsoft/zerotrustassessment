function Test-ZtContext {
	<#
	.SYNOPSIS
		Validates the MgContext to ensure a valid connection to Microsoft Graph including the required permissions.

	.DESCRIPTION
		Validates the MgContext to ensure a valid connection to Microsoft Graph including the required permissions.

		What is needed?
		- Connected: The MS Graph API requires authenticated access
		- Scopes: Some scopes must be associated with the connection. Get-ZtGraphScope gives the list of what is needed.
		- Roles: When in user mode, must be connected as "Global Reader" or "Global Administrator"

	.EXAMPLE
		PS C:\> Test-ZtContext

		Validates the MgContext to ensure a valid connection to Microsoft Graph including the required permissions.
	#>
	[CmdletBinding()]
	[OutputType([bool])]
	param ()

	$validContext = $true
	$context = Get-MgContext
	if (-not $context) {
		throw "Not connected to Microsoft Graph. Please use 'Connect-ZTAssessment'. For more information, use 'Get-Help Connect-ZTAssessment'."
		return $false
	}

	$requiredScopes = Get-ZtGraphScope
	$currentScopes = $context.Scopes
	$missingScopes = $requiredScopes | Where-Object { $currentScopes -notcontains $_ }

	if ($missingScopes) {
		$message = "These Graph permissions are missing in the current connection => ($($missingScopes))."
		if ($context.AuthType -eq 'Delegated') {
			$message += " Please use 'Connect-ZTAssessment'. For more information, use 'Get-Help Connect-ZTAssessment'."
		}
		else {
			$clientId = $context.ClientId
			$urlTemplate = "https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/CallAnAPI/appId/$clientId/isMSAApp~/false"
			$message += " Add the missing 'Application' permissions in the Microsoft Entra portal and grant consent. You will also need to Disconnect-Graph to refresh the permissions."
			$message += " Click here to open the 'API Permissions' blade for this app: $urlTemplate"
		}
		$validContext = $false
	}

	# Check if user has Global Reader or Global Administrator role activated (for delegated auth)
	if ($context.AuthType -eq 'Delegated' -and $validContext) {
		try {
			# Get user's app role assignments to check for activated directory roles
			$roleAssignments = Invoke-ZtGraphRequest -RelativeUri "me/transitiveMemberOf/microsoft.graph.directoryRole" -DisableCache

			# Check if user has either Global Reader or Global Administrator role assigned
			$hasRequiredRole = $roleAssignments | Where-Object displayName -in 'Global Reader', 'Global Administrator'

			if (-not $hasRequiredRole) {
				$message = "The currently logged in user does not have the Global Reader or Global Administrator role activated. Please ensure you have one of these roles assigned and activated."
				# Also disconnect the context to avoid using cache
				Disconnect-MgGraph -ErrorAction SilentlyContinue | Out-Null
				$validContext = $false
			}
		}
		catch {
			Write-PSFMessage -Level Warning -Message "Unable to verify user roles" -ErrorRecord $_
		}
	}

	if (-not $validContext) {
		throw $message
	}
	return $validContext
}
