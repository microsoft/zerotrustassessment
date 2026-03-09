<#
.SYNOPSIS
    Checks that Global Secure Access logs are integrated with a Log Analytics workspace for security monitoring.

.DESCRIPTION
    Verifies that diagnostic settings are configured to send Global Secure Access log categories
    (NetworkAccessTrafficLogs, EnrichedOffice365AuditLogs, RemoteNetworkHealthLogs, NetworkAccessAlerts,
    NetworkAccessConnectionEvents, NetworkAccessGenerativeAIInsights) to a Log Analytics workspace
    for Microsoft Sentinel integration and threat detection.

.NOTES
    Test ID: 25419
    Category: Global Secure Access
    Required API: Azure Monitor Diagnostic Settings API (management.azure.com)
#>

function Test-Assessment-25419 {
    [ZtTest(
        Category = 'Global Secure Access',
        ImplementationCost = 'Low',
        MinimumLicense = ('AAD_PREMIUM', 'Entra_Premium_Internet_Access', 'Entra_Premium_Private_Access'),
        Pillar = 'Network',
        RiskLevel = 'Medium',
        SfiPillar = 'Monitor and detect cyberthreats',
        TenantType = ('Workforce'),
        TestId = 25419,
        Title = 'Network access activity is visible to security operations for threat detection and response',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose
    $activity = 'Checking Global Secure Access diagnostic settings for security monitoring'

    # Check if connected to Azure
    Write-ZtProgress -Activity $activity -Status 'Checking Azure connection'

    $azContext = Get-AzContext -ErrorAction SilentlyContinue
    if (-not $azContext) {
        Write-PSFMessage 'Not connected to Azure.' -Level Warning
        Add-ZtTestResultDetail -SkippedBecause NotConnectedAzure
        return
    }

    # Check the supported environment, 'AzureCloud' in (Get-AzContext).Environment.Name maps to 'Global' in (Get-MgContext).Environment
    Write-ZtProgress -Activity $activity -Status 'Checking Azure environment'

    if ($azContext.Environment.Name -ne 'AzureCloud') {
        Write-PSFMessage 'This test is only applicable to the AzureCloud environment.' -Tag Test -Level VeryVerbose
        Add-ZtTestResultDetail -SkippedBecause NotSupported
        return
    }

    # Query diagnostic settings for Microsoft Entra
    Write-ZtProgress -Activity $activity -Status 'Querying Microsoft Entra diagnostic settings'

    $resourceManagementUrl = $azContext.Environment.ResourceManagerUrl
    $diagnosticSettingsUri = $resourceManagementUrl + 'providers/microsoft.aadiam/diagnosticsettings?api-version=2017-04-01-preview'

    try {
        $result = Invoke-AzRestMethod -Method GET -Uri $diagnosticSettingsUri -ErrorAction Stop

        if ($result.StatusCode -eq 403) {
            Write-PSFMessage 'The signed in user does not have access to check diagnostic settings.' -Level Verbose
            Add-ZtTestResultDetail -SkippedBecause NoAzureAccess
            return
        }

        if ($result.StatusCode -ge 400) {
            throw "Diagnostic settings request failed with status code $($result.StatusCode)"
        }
    }
    catch {
        # Only catches actual exceptions (network errors, etc.), not HTTP status codes
        throw
    }

    $diagnosticSettings = ($result.Content | ConvertFrom-Json).value
    #endregion Data Collection

    #region Assessment Logic
    # Define required Global Secure Access log categories
    $requiredLogCategories = @(
        'NetworkAccessTrafficLogs',
        'EnrichedOffice365AuditLogs',
        'RemoteNetworkHealthLogs',
        'NetworkAccessAlerts',
        'NetworkAccessConnectionEvents',
        'NetworkAccessGenerativeAIInsights'
    )

    $passed = $false
    $testResultMarkdown = ''

    if ($null -eq $diagnosticSettings -or $diagnosticSettings.Count -eq 0) {
        $testResultMarkdown = "❌ No diagnostic settings are configured for Microsoft Entra. Global Secure Access logs are not being exported to any destination.`n`n%TestResult%"
    }
    else {
        # Find settings that have all required categories enabled and sent to a workspace
        $settingsWithAllCategories = @()
        foreach ($setting in $diagnosticSettings) {
            $hasWorkspace = -not [string]::IsNullOrEmpty($setting.properties.workspaceId)
            $enabledLogs = $setting.properties.logs | Where-Object { $_.enabled -eq $true } | Select-Object -ExpandProperty category
            $hasAllCategories = ($requiredLogCategories | Where-Object { $_ -in $enabledLogs }).Count -eq $requiredLogCategories.Count

            if ($hasWorkspace -and $hasAllCategories) {
                $settingsWithAllCategories += $setting
            }
        }

        $passed = $settingsWithAllCategories.Count -gt 0

        if ($passed) {
            $testResultMarkdown = "✅ All required Global Secure Access log categories are integrated with a Log Analytics workspace for security monitoring and threat detection.`n`n%TestResult%"
        }
        else {
            $testResultMarkdown = "❌ Global Secure Access logs are not properly integrated with a Log Analytics workspace for security operations visibility.`n`n%TestResult%"
        }
    }
    #endregion Assessment Logic

    #region Report Generation
    $mdInfo = ''

    if ($diagnosticSettings.Count -gt 0) {
        $mdInfo += "`n## [Diagnostic settings configuration](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ActiveDirectoryMenuBlade/~/DiagnosticSettings)`n`n"

        # Build pivoted table: Log Categories as rows, Diagnostic Settings as columns
        # Header row with diagnostic setting names
        $headerRow = '| Log category |'
        $separatorRow = '| :--- |'
        foreach ($setting in $diagnosticSettings) {
            $headerRow += " $(Get-SafeMarkdown $setting.name) |"
            $separatorRow += ' :---: |'
        }
        $mdInfo += "$headerRow`n"
        $mdInfo += "$separatorRow`n"

        # One row per log category
        foreach ($category in $requiredLogCategories) {
            $row = "| $category |"
            foreach ($setting in $diagnosticSettings) {
                $enabledLogs = $setting.properties.logs | Where-Object { $_.enabled -eq $true } | Select-Object -ExpandProperty category
                $isEnabled = $category -in $enabledLogs
                $statusValue = if ($isEnabled) { '✅ Enabled' } else { '❌ Disabled' }
                $row += " $statusValue |"
            }
            $mdInfo += "$row`n"
        }

        # Workspace row at the bottom
        $workspaceRow = '| Workspace |'
        foreach ($setting in $diagnosticSettings) {
            $workspaceId = $setting.properties.workspaceId
            $hasWorkspace = -not [string]::IsNullOrEmpty($workspaceId)
            if ($hasWorkspace) {
                $workspaceName = ($workspaceId -split '/')[-1]
                $workspaceLink = "https://portal.azure.com/#resource$($workspaceId)/overview"
                $workspaceValue = "✅ [$(Get-SafeMarkdown $workspaceName)]($workspaceLink)"
            }
            else {
                $workspaceValue = '❌ Not configured'
            }
            $workspaceRow += " $workspaceValue |"
        }
        $mdInfo += "$workspaceRow`n"

        # Summary section
        $mdInfo += "`n**Summary:**`n`n"

        $mdInfo += "- Total diagnostic settings: $($diagnosticSettings.Count)`n"
        $mdInfo += "- Diagnostic settings passing criteria (all six categories + workspace): $($settingsWithAllCategories.Count)`n"
    }

    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '25419'
        Title  = 'Network access activity is visible to security operations for threat detection and response'
        Status = $passed
        Result = $testResultMarkdown
    }

    # Add test result details
    Add-ZtTestResultDetail @params
}
