<#
.SYNOPSIS
    Validates that network access logs are retained for security analysis
    and compliance requirements.

.DESCRIPTION
    This test evaluates diagnostic settings for Microsoft Entra to ensure
    Global Secure Access log categories are enabled with appropriate
    retention periods (minimum 90 days) in Log Analytics workspaces.

.NOTES
    Test ID: 25420
    Category: Global Secure Access
    Required APIs: Azure Management REST API (diagnostic settings, workspaces)
#>

function Test-Assessment-25420 {

    [ZtTest(
        Category = 'Global Secure Access',
        ImplementationCost = 'Low',
        MinimumLicense = ('AAD_PREMIUM', 'Entra_Premium_Internet_Access', 'Entra_Premium_Private_Access'),
        Pillar = 'Network',
        RiskLevel = 'High',
        SfiPillar = 'Monitor and detect cyberthreats',
        TenantType = ('Workforce'),
        TestId = 25420,
        Title = 'Network access logs are retained for security analysis and compliance requirements',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    # Minimum retention period in days for compliance
    $MINIMUM_RETENTION_DAYS = 90

    # Required Global Secure Access log categories
    $REQUIRED_LOG_CATEGORIES = @(
        'AuditLogs',                          # Audit logs for configuration changes to Global Secure Access
        'NetworkAccessTrafficLogs',           # Network traffic logs
        'EnrichedOffice365AuditLogs',         # Enriched Office 365 audit logs with network context
        'RemoteNetworkHealthLogs',            # Remote network health logs
        'NetworkAccessAlerts',                # Security alerts
        'NetworkAccessConnectionEvents',     # Connection event logs
        'NetworkAccessGenerativeAIInsights'  # AI-generated insights and security recommendations
    )

    #region Data Collection

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose
    $activity = 'Evaluating network access log retention configuration'

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
    Write-ZtProgress -Activity $activity -Status 'Querying diagnostic settings'

    $resourceManagementUrl = $azContext.Environment.ResourceManagerUrl
    $diagnosticSettingsUri = $resourceManagementUrl + 'providers/microsoft.aadiam/diagnosticsettings?api-version=2017-04-01-preview'

    $diagnosticSettings = $null
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

        $diagnosticSettings = ($result.Content | ConvertFrom-Json).value
    }
    catch {
        # Only catches actual exceptions (network errors, etc.), not HTTP status codes
        throw
    }

    # Query Q2: Retrieve Log Analytics workspace retention settings for each configured workspace
    $workspaceDetails = @{}

    if ($null -ne $diagnosticSettings -and $diagnosticSettings.Count -gt 0) {

        Write-ZtProgress -Activity $activity -Status 'Checking workspace retention settings'

        $workspaceIds = $diagnosticSettings |
            Where-Object { $_.properties.workspaceId } |
            Select-Object -ExpandProperty properties |
            Select-Object -ExpandProperty workspaceId -Unique

        foreach ($workspaceId in $workspaceIds) {
            try {
                $workspaceUri = $resourceManagementUrl.TrimEnd('/') + $workspaceId + '?api-version=2023-09-01'
                $workspaceResponse = Invoke-AzRestMethod -Method GET -Uri $workspaceUri -ErrorAction Stop

                if ($workspaceResponse.StatusCode -ge 400) {
                    Write-PSFMessage "Failed to query workspace $workspaceId with status code $($workspaceResponse.StatusCode)" -Level Warning
                    $workspaceDetails[$workspaceId] = $null
                }
                else {
                    $workspaceDetails[$workspaceId] = ($workspaceResponse.Content | ConvertFrom-Json)
                }
            }
            catch {
                Write-PSFMessage "Error querying workspace $workspaceId : $_" -Level Warning
                $workspaceDetails[$workspaceId] = $null
            }
        }
    }

    #endregion Data Collection

    #region Assessment Logic

    # Initialize evaluation containers
    $passed              = $false
    $testResultMarkdown  = ''
    $diagResults         = @()
    $logCategoryStatus   = @{}
    $hasAdequateRetention      = $false
    $hasAllRequiredCategories  = $false
    $passingSettingFound       = $false

    # Step 1: Check if any diagnostic settings exist
    if ($null -eq $diagnosticSettings -or $diagnosticSettings.Count -eq 0) {

        $passed = $false
        $testResultMarkdown = "❌ No diagnostic settings are configured for Microsoft Entra. Global Secure Access logs are retained for only 30 days (default in-portal retention) which is insufficient for security investigations.`n`n%TestResult%"

    }
    else {

        Write-ZtProgress -Activity $activity -Status 'Evaluating log categories and retention'

        # Initialize log category tracking
        foreach ($category in $REQUIRED_LOG_CATEGORIES) {
            $logCategoryStatus[$category] = @{
                Enabled         = $false
                DestinationType = 'None'
                RetentionDays   = $null
                MeetsMinimum    = $false
            }
        }

        foreach ($setting in $diagnosticSettings) {

            $workspaceId      = $setting.properties.workspaceId
            $storageAccountId = $setting.properties.storageAccountId
            $logs             = $setting.properties.logs

            # Step 2: Determine destination type (Workspace, Storage, or both)
            $destinationType = 'None'
            if ($workspaceId -and $storageAccountId) {
                $destinationType = 'Workspace & Storage'
            }
            elseif ($workspaceId) {
                $destinationType = 'Workspace'
            }
            elseif ($storageAccountId) {
                $destinationType = 'Storage'
            }

            # Step 3: Get workspace retention if applicable
            $retentionDays  = $null
            $workspaceName  = $null
            if ($workspaceId -and $workspaceDetails.ContainsKey($workspaceId) -and $workspaceDetails[$workspaceId]) {
                $workspace     = $workspaceDetails[$workspaceId]
                $retentionDays = $workspace.properties.retentionInDays
                $workspaceName = $workspace.name
            }

            # Step 4: Evaluate if this setting meets minimum retention criteria
            $meetsMinimum = $false
            if ($retentionDays -ge $MINIMUM_RETENTION_DAYS) {
                $meetsMinimum = $true
            }
            elseif ($storageAccountId) {
                # Storage account retention cannot be queried via this API; assume meets minimum, flag for manual review
                $meetsMinimum = $true
            }

            $enabledCategories = @()

            # Step 5: Process log categories for this setting and track best configuration
            foreach ($log in $logs) {
                $categoryName = $log.category
                $isEnabled    = $log.enabled

                if ($categoryName -in $REQUIRED_LOG_CATEGORIES -and $isEnabled) {
                    $enabledCategories += $categoryName

                    # Update global category status if this is a better configuration
                    # Prioritize: 1) configs that meet minimum, 2) higher retention days
                    $currentStatus = $logCategoryStatus[$categoryName]
                    $shouldUpdate = $false

                    if (-not $currentStatus.Enabled) {
                        $shouldUpdate = $true
                    }
                    elseif ($meetsMinimum -and -not $currentStatus.MeetsMinimum) {
                        # New config meets minimum but current doesn't - always prefer
                        $shouldUpdate = $true
                    }
                    elseif ($meetsMinimum -eq $currentStatus.MeetsMinimum) {
                        # Both meet or both don't meet minimum - compare retention days
                        if ($retentionDays -and (-not $currentStatus.RetentionDays -or $retentionDays -gt $currentStatus.RetentionDays)) {
                            $shouldUpdate = $true
                        }
                    }

                    if ($shouldUpdate) {
                        $logCategoryStatus[$categoryName] = @{
                            Enabled         = $true
                            DestinationType = $destinationType
                            RetentionDays   = $retentionDays
                            MeetsMinimum    = $meetsMinimum
                        }
                    }
                }
            }

            # Step 6: Check if this setting has all required categories AND meets retention criteria
            $settingHasAllCategories = ($enabledCategories.Count -eq $REQUIRED_LOG_CATEGORIES.Count)
            if ($settingHasAllCategories -and $meetsMinimum) {
                $passingSettingFound = $true
            }

            # Determine per-setting status
            # Storage-only settings require manual review since retention policies cannot be queried via this API
            $settingStatus = if ($storageAccountId -and -not $workspaceId) {
                'Manual review'
            } elseif ($settingHasAllCategories -and $meetsMinimum) {
                'Adequate'
            } else {
                'Insufficient'
            }

            $diagResults += [PSCustomObject]@{
                SettingName       = $setting.name
                WorkspaceId       = $workspaceId
                WorkspaceName     = $workspaceName
                StorageAccountId  = $storageAccountId
                DestinationType   = $destinationType
                RetentionDays     = $retentionDays
                MeetsMinimum      = $meetsMinimum
                EnabledCategories = $enabledCategories
                Status            = $settingStatus
            }
        }

        # Step 7: Verify all required Global Secure Access log categories are enabled (across all settings)
        $enabledCategoryCount = ($logCategoryStatus.GetEnumerator() | Where-Object { $_.Value.Enabled }).Count
        $hasAllRequiredCategories = ($enabledCategoryCount -eq $REQUIRED_LOG_CATEGORIES.Count)

        # Step 8: Check if any category meets minimum retention (used for summary reporting)
        # Note: Pass/fail is determined by $passingSettingFound which requires ALL categories in ONE setting
        $hasAdequateRetention = ($logCategoryStatus.GetEnumerator() | Where-Object { $_.Value.MeetsMinimum }).Count -gt 0

        # Step 9: Determine overall test result
        if ($passingSettingFound) {

            $passed = $true
            $testResultMarkdown = "✅ Global Secure Access logs are retained for at least $MINIMUM_RETENTION_DAYS days, supporting security analysis and compliance requirements`n`n%TestResult%"

        }
        else {

            $passed = $false
            $testResultMarkdown = "❌ Global Secure Access logs are not retained for adequate duration to support security investigations and compliance obligations`n`n%TestResult%"

        }
    }

    #endregion Assessment Logic

    #region Report Generation

    # Calculate summary metrics
    $settingsWithLongTermDest = ($diagResults | Where-Object { $_.WorkspaceId -or $_.StorageAccountId }).Count
    $workspaceRetentions = $diagResults | Where-Object { $_.RetentionDays } | Select-Object -ExpandProperty RetentionDays
    $avgRetention = if ($workspaceRetentions.Count -gt 0) {
        [math]::Round(($workspaceRetentions | Measure-Object -Average).Average, 0) # Round to whole days for compliance reporting
    } else { $null }
    $minRetention = if ($workspaceRetentions.Count -gt 0) {
        ($workspaceRetentions | Measure-Object -Minimum).Minimum
    } else { $null }

    $mdInfo = "`n## [Diagnostic settings configuration](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ActiveDirectoryMenuBlade/~/DiagnosticSettings)`n`n"

    # Log Retention Status table
    if ($logCategoryStatus.Count -gt 0) {
        $tableRows = ""
        $formatTemplate = @'
### Log retention status

| Log category | Enabled | Destination type | Retention period | Meets minimum (90 days) |
| :--- | :--- | :--- | :--- | :--- |
{0}

'@
        foreach ($category in $REQUIRED_LOG_CATEGORIES) {
            $status       = $logCategoryStatus[$category]
            $enabledText  = if ($status.Enabled) { 'Yes' } else { 'No' }
            $destType     = if ($status.Enabled) { $status.DestinationType } else { 'None' }

            # For storage-only destinations, retention cannot be queried via API
            $isStorageOnly = $status.DestinationType -eq 'Storage'
            $retention = if ($status.RetentionDays) {
                "$($status.RetentionDays) days"
            } elseif ($isStorageOnly) {
                'Manual verification required'
            } else {
                'Not configured'
            }
            $meetsMinText = if ($status.MeetsMinimum) { 'Yes' } else { 'No' }

            $tableRows   += "| $category | $enabledText | $destType | $retention | $meetsMinText |`n"
        }
        $mdInfo += $formatTemplate -f $tableRows
    }

    # Destination Details table
    if ($diagResults.Count -gt 0) {
        $tableRows = ""
        $formatTemplate = @'
### Destination details

| Destination type | Resource name | Default retention | Status |
| :--- | :--- | :--- | :--- |
{0}

'@
        foreach ($diag in $diagResults) {
            # Add hyperlink to destination type based on type
            $destType = if ($diag.WorkspaceName -and $diag.StorageAccountId) {
                "[Log Analytics workspace](https://portal.azure.com/?feature.msaljs=true#browse/Microsoft.OperationalInsights%2Fworkspaces) & [Storage Account](https://portal.azure.com/?feature.msaljs=true#view/Microsoft_Azure_StorageHub/StorageHub.MenuView/~/StorageAccountsBrowse)"
            }
            elseif ($diag.WorkspaceName) {
                "[Log Analytics workspace](https://portal.azure.com/?feature.msaljs=true#browse/Microsoft.OperationalInsights%2Fworkspaces)"
            }
            elseif ($diag.StorageAccountId) {
                "[Storage account](https://portal.azure.com/?feature.msaljs=true#view/Microsoft_Azure_StorageHub/StorageHub.MenuView/~/StorageAccountsBrowse)"
            }
            else { 'None' }
            $resourceName = if ($diag.WorkspaceName) { Get-SafeMarkdown $diag.WorkspaceName }
                           elseif ($diag.StorageAccountId) { Get-SafeMarkdown ($diag.StorageAccountId.Split('/')[-1]) }
                           else { 'N/A' }
            $retention = if ($diag.RetentionDays) { "$($diag.RetentionDays) days" }
                        elseif ($diag.StorageAccountId) { 'Manual verification required' }
                        else { 'N/A' }
            $tableRows += "| $destType | $resourceName | $retention | $($diag.Status) |`n"
        }
        $mdInfo += $formatTemplate -f $tableRows
    }

    # Summary table (per spec format)
    $mdInfo += "### Summary`n`n"
    $mdInfo += "| Metric | Value |`n| :--- | :--- |`n"
    $mdInfo += "| Total diagnostic settings | $($diagnosticSettings.Count) |`n"
    $mdInfo += "| Settings with long-term destination | $settingsWithLongTermDest |`n"
    $mdInfo += "| Average retention period | $(if ($avgRetention) { "$avgRetention days" } else { 'N/A' }) |`n"
    $mdInfo += "| Minimum retention found | $(if ($minRetention) { "$minRetention days" } else { 'N/A' }) |`n"
    $mdInfo += "| Meets 90-day minimum | $(if ($hasAdequateRetention) { 'Yes' } else { 'No' }) |`n"

    # Replace the placeholder with detailed information
    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo

    #endregion Report Generation

    $params = @{
        TestId = '25420'
        Title  = 'Network access logs are retained for security analysis and compliance requirements'
        Status = $passed
        Result = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
