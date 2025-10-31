<#
.SYNOPSIS
    Validates the MgContext to ensure a valid connection to Microsoft Graph including the required permissions.
#>

function Test-ZtContext {
    [CmdletBinding()]
    [OutputType([bool])]
    param ()

    $validContext = $true
    if (!(Get-MgContext)) {
        $message = "Not connected to Microsoft Graph. Please use 'Connect-ZTAssessment'. For more information, use 'Get-Help Connect-ZTAssessment'."
        $validContext = $false
    } else {
        $requiredScopes = Get-ZtGraphScope
        $currentScopes = Get-MgContext | Select-Object -ExpandProperty Scopes
        $missingScopes = $requiredScopes | Where-Object { $currentScopes -notcontains $_ }

        if ($missingScopes) {
            $message = "These Graph permissions are missing in the current connection => ($($missingScopes))."
            $authType = (Get-MgContext).AuthType
            if ($authType -eq  'Delegated') {
                $message += " Please use 'Connect-ZTAssessment'. For more information, use 'Get-Help Connect-ZTAssessment'."
            } else {
                $clientId = (Get-MgContext).ClientId
                $urlTemplate = "https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/CallAnAPI/appId/$clientId/isMSAApp~/false"
                $message += " Add the missing 'Application' permissions in the Microsoft Entra portal and grant consent. You will also need to Disconnect-Graph to refresh the permissions."
                $message += " Click here to open the 'API Permissions' blade for this app: $urlTemplate"
            }
            $validContext = $false
        }

        # Check if user has Global Reader or Global Administrator role activated (for delegated auth)
        $authType = (Get-MgContext).AuthType
        if ($authType -eq 'Delegated' -and $validContext) {
            try {
                $userId = (Get-MgContext).Account

                # Get user's app role assignments to check for activated directory roles
                $roleAssignments = Invoke-ZtGraphRequest -RelativeUri "me/transitiveMemberOf/microsoft.graph.directoryRole" -DisableCache

                # Check if user has either Global Reader or Global Administrator role assigned
                $hasRequiredRole = $roleAssignments | Where-Object {
                    $_.displayName -in @('Global Reader', 'Global Administrator')
                }

                if (-not $hasRequiredRole) {
                    $message = "The currently logged in user does not have the Global Reader or Global Administrator role activated. Please ensure you have one of these roles assigned and activated."
                    # Also disconnect the context to avoid using cache
                    Disconnect-MgGraph -ErrorAction SilentlyContinue | Out-Null
                    $validContext = $false
                }
            } catch {
                Write-Warning "Unable to verify user roles: $($_.Exception.Message)"
            }
        }
    }

    if (!$validContext) {
        throw $message
    }
    return $validContext
}
