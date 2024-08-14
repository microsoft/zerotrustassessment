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
    }

    if (!$validContext) {
        throw $message
    }
    return $validContext
}
