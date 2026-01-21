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
        MinimumLicense = 'Entra_Premium_Internet_Access',
        Pillar = 'Network',
        RiskLevel = 'High',
        SfiPillar = 'Monitor and detect cyberthreats',
        TenantType = 'Workforce',
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
        'NetworkAccessTrafficLogs',
        'RemoteNetworkHealthLogs',
        'NetworkAccessAlerts',
        'NetworkAccessConnectionEvents'
    )

    #region Data Collection

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose
    $activity = 'Evaluating network access log retention configuration'
    Write-ZtProgress -Activity $activity -Status 'Checking Azure connection'

    # Check for Azure authentication
    try {
        $accessToken = Get-AzAccessToken -AsSecureString -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
    }
    catch [Management.Automation.CommandNotFoundException] {
        Write-PSFMessage $_.Exception.Message -Tag Test -Level Error
    }

    if (!$accessToken) {
        Write-PSFMessage "Azure authentication token not found." -Level Warning
        Add-ZtTestResultDetail -SkippedBecause NotConnectedAzure
        return
    }

    Write-ZtProgress -Activity $activity -Status 'Querying diagnostic settings'

    # Query Q1: Retrieve diagnostic settings for Microsoft Entra
    $diagnosticSettings = $null
    try {
        $uri = 'https://management.azure.com/providers/microsoft.aadiam/diagnosticsettings?api-version=2017-04-01-preview'
        $response = Invoke-AzRestMethod -Uri $uri -Method GET -ErrorAction Stop
        $diagnosticSettings = ($response.Content | ConvertFrom-Json).value
    }
    catch {
        Write-PSFMessage "Error querying diagnostic settings: $_" -Level Error
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
                $workspaceUri = "https://management.azure.com$workspaceId`?api-version=2023-09-01"
                $workspaceResponse = Invoke-AzRestMethod -Uri $workspaceUri -Method GET -ErrorAction Stop
                $workspaceDetails[$workspaceId] = ($workspaceResponse.Content | ConvertFrom-Json)
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
    $customStatus        = $null
    $testResultMarkdown  = ''
    $diagResults         = @()
    $logCategoryStatus   = @{}
    $hasAdequateRetention      = $false
    $hasAllRequiredCategories  = $false
    $settingsWithStorageOnly   = @()
    $passingSettingFound       = $false

    # Step 1: Check if any diagnostic settings exist
    if ($null -eq $diagnosticSettings -or $diagnosticSettings.Count -eq 0) {

        $passed = $false
        $testResultMarkdown =
            "❌ No diagnostic settings are configured for Microsoft Entra. Global Secure Access logs are retained for only 30 days (default in-portal retention) which is insufficient for security investigations.`n`n%TestResult%"

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

            $settingName      = $setting.name
            $workspaceId      = $setting.properties.workspaceId
            $storageAccountId = $setting.properties.storageAccountId
            $logs             = $setting.properties.logs

            # Step 2: Determine destination type
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
            # Per spec: workspace ≥ 90 days OR storage account configured = meets minimum
            $meetsMinimum = $false
            if ($retentionDays -ge $MINIMUM_RETENTION_DAYS) {
                $meetsMinimum = $true
            }
            elseif ($storageAccountId) {
                # Storage account configured = meets minimum per spec
                $meetsMinimum = $true
            }

            # Track storage-only settings for reporting purposes
            if ($storageAccountId -and -not $workspaceId) {
                $settingsWithStorageOnly += $settingName
            }

            $enabledCategories = @()

            # Step 5: Process log categories for this setting
            foreach ($log in $logs) {
                $categoryName = $log.category
                $isEnabled    = $log.enabled

                if ($categoryName -in $REQUIRED_LOG_CATEGORIES -and $isEnabled) {
                    $enabledCategories += $categoryName

                    # Update global category status if this is a better configuration
                    $currentStatus = $logCategoryStatus[$categoryName]
                    if (-not $currentStatus.Enabled -or
                        ($retentionDays -and $retentionDays -gt $currentStatus.RetentionDays)) {
                        $logCategoryStatus[$categoryName] = @{
                            Enabled         = $true
                            DestinationType = $destinationType
                            RetentionDays   = $retentionDays
                            MeetsMinimum    = $meetsMinimum
                        }
                    }
                }
            }

            # Step 6: Check if THIS setting has all 4 categories AND meets retention criteria
            # Per spec: "If any diagnostic setting has: All four log categories enabled AND
            # Either workspace with ≥ 90 day retention OR storage account configured → Pass"
            $settingHasAllCategories = ($enabledCategories.Count -eq $REQUIRED_LOG_CATEGORIES.Count)
            if ($settingHasAllCategories -and $meetsMinimum) {
                $passingSettingFound = $true
            }

            # Determine per-setting status
            $settingStatus = if ($settingHasAllCategories -and $meetsMinimum) {
                'Adequate'
            } elseif ($storageAccountId -and -not $workspaceId) {
                'Manual Review'
            } else {
                'Insufficient'
            }

            $diagResults += [PSCustomObject]@{
                SettingName       = $settingName
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

        # Step 7: Check if all required categories are enabled (across all settings)
        $enabledCategoryCount     = ($logCategoryStatus.GetEnumerator() | Where-Object { $_.Value.Enabled }).Count
        $hasAllRequiredCategories = ($enabledCategoryCount -eq $REQUIRED_LOG_CATEGORIES.Count)

        # Step 8: Check if any configuration meets minimum retention
        $hasAdequateRetention = ($logCategoryStatus.GetEnumerator() | Where-Object { $_.Value.MeetsMinimum }).Count -gt 0

        # Step 9: Determine overall test result
        # Per spec: Pass if ANY single diagnostic setting has all 4 categories AND meets retention
        if ($passingSettingFound) {

            $passed = $true
            $testResultMarkdown =
                "✅ Global Secure Access logs are retained for at least $MINIMUM_RETENTION_DAYS days, supporting security analysis and compliance requirements`n`n%TestResult%"

        }
        elseif (-not $hasAllRequiredCategories) {

            $passed = $false
            $testResultMarkdown =
                "❌ Not all Global Secure Access log categories are enabled. Security investigations require complete log coverage across all four categories`n`n%TestResult%"

        }
        else {

            $passed = $false
            $testResultMarkdown =
                "❌ Global Secure Access logs are not retained for adequate duration to support security investigations and compliance obligations`n`n%TestResult%"

        }
    }

    #endregion Assessment Logic

    #region Report Generation

    # Calculate summary metrics per spec
    $settingsWithLongTermDest = ($diagResults | Where-Object { $_.WorkspaceId -or $_.StorageAccountId }).Count
    $workspaceRetentions = $diagResults | Where-Object { $_.RetentionDays } | Select-Object -ExpandProperty RetentionDays
    $avgRetention = if ($workspaceRetentions.Count -gt 0) {
        [math]::Round(($workspaceRetentions | Measure-Object -Average).Average, 0)
    } else { $null }
    $minRetention = if ($workspaceRetentions.Count -gt 0) {
        ($workspaceRetentions | Measure-Object -Minimum).Minimum
    } else { $null }

    # Build report in spec order:
    # 1. Diagnostic Settings Configuration (heading)
    # 2. Log Retention Status table
    # 3. Destination Details table
    # 4. Summary table

    $mdInfo = "`n## [Diagnostic settings configuration](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ActiveDirectoryMenuBlade/~/DiagnosticSettings)`n`n"

    # Log Retention Status table
    if ($logCategoryStatus.Count -gt 0) {
        $tableRows = ""
        $formatTemplate = @'
### Log retention status

| Log category | Enabled | Destination type | Retention period | Meets minimum (90 days) |
|---|---|---|---|---|
{0}

'@
        foreach ($category in $REQUIRED_LOG_CATEGORIES) {
            $status       = $logCategoryStatus[$category]
            $enabledText  = if ($status.Enabled) { 'Yes' } else { 'No' }
            $destType     = if ($status.Enabled) { $status.DestinationType } else { 'None' }
            $retention    = if ($status.RetentionDays) { "$($status.RetentionDays) days" } else { 'Not configured' }
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
|---|---|---|---|
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
            $resourceName = if ($diag.WorkspaceName) { $diag.WorkspaceName }
                           elseif ($diag.StorageAccountId) { $diag.StorageAccountId.Split('/')[-1] }
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
    $mdInfo += "| Metric | Value |`n|---|---|`n"
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

    # Add CustomStatus if status is 'Investigate'
    if ($null -ne $customStatus) {
        $params.CustomStatus = $customStatus
    }

    # Add test result details
    Add-ZtTestResultDetail @params
}
