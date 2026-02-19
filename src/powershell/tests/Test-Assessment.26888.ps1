<#
.SYNOPSIS
    Validates that diagnostic logging is enabled for Application Gateway WAF.

.DESCRIPTION
    This test evaluates diagnostic settings for Azure Application Gateway resources with WAF SKU
    to ensure log categories are enabled with a valid destination configured (Log Analytics,
    Storage Account, or Event Hub).

.NOTES
    Test ID: 26888
    Category: Azure Network Security
    Required APIs: Azure Management REST API (subscriptions, application gateways, diagnostic settings)
#>

function Test-Assessment-26888 {

    [ZtTest(
        Category = 'Azure Network Security',
        ImplementationCost = 'Low',
        MinimumLicense = ('Azure_Application_Gateway_WAF'),
        Pillar = 'Network',
        RiskLevel = 'High',
        SfiPillar = 'Monitor and detect cyberthreats',
        TenantType = ('Workforce'),
        TestId = 26888,
        Title = 'Diagnostic logging is enabled in Application Gateway WAF',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose
    $activity = 'Evaluating Application Gateway WAF diagnostic logging configuration'

    # Check if connected to Azure
    Write-ZtProgress -Activity $activity -Status 'Checking Azure connection'

    $azContext = Get-AzContext -ErrorAction SilentlyContinue
    if (-not $azContext) {
        Write-PSFMessage 'Not connected to Azure.' -Level Warning
        Add-ZtTestResultDetail -SkippedBecause NotConnectedAzure
        return
    }

    # Check the supported environment
    Write-ZtProgress -Activity $activity -Status 'Checking Azure environment'

    if ($azContext.Environment.Name -ne 'AzureCloud') {
        Write-PSFMessage 'This test is only applicable to the AzureCloud environment.' -Tag Test -Level VeryVerbose
        Add-ZtTestResultDetail -SkippedBecause NotSupported
        return
    }

    # Check Azure access token
    try {
        $accessToken = Get-AzAccessToken -AsSecureString -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
    }
    catch {
        Write-PSFMessage $_.Exception.Message -Tag Test -Level Error
    }

    if (-not $accessToken) {
        Write-PSFMessage 'Azure authentication token not found.' -Tag Test -Level Warning
        Add-ZtTestResultDetail -SkippedBecause NotConnectedAzure
        return
    }

    # Q1 & Q2: Query Application Gateways with WAF SKU using Azure Resource Graph
    Write-ZtProgress -Activity $activity -Status 'Querying Application Gateways via Resource Graph'

    $argQuery = @"
resources
| where type =~ 'microsoft.network/applicationgateways'
| where properties.provisioningState =~ 'Succeeded'
| where properties.sku.tier in~ ('WAF', 'WAF_v2')
| join kind=leftouter (
    resourcecontainers
    | where type =~ 'microsoft.resources/subscriptions'
    | project subscriptionName=name, subscriptionId
) on subscriptionId
| project
    GatewayName=name,
    GatewayId=id,
    Location=location,
    SkuTier=tostring(properties.sku.tier),
    SubscriptionId=subscriptionId,
    SubscriptionName=subscriptionName
"@

    $allAppGateways = @()
    try {
        $allAppGateways = @(Invoke-ZtAzureResourceGraphRequest -Query $argQuery)
        Write-PSFMessage "ARG Query returned $($allAppGateways.Count) Application Gateway WAF(s)" -Tag Test -Level VeryVerbose
    }
    catch {
        Write-PSFMessage "Azure Resource Graph query failed: $($_.Exception.Message)" -Tag Test -Level Warning
        Add-ZtTestResultDetail -SkippedBecause NotSupported
        return
    }

    # Check if any Application Gateway WAF resources exist
    if ($allAppGateways.Count -eq 0) {
        Write-PSFMessage 'No Application Gateway WAF resources found.' -Tag Test -Level VeryVerbose
        Add-ZtTestResultDetail -SkippedBecause NotApplicable
        return
    }

    # Q3: Get diagnostic settings for each Application Gateway WAF
    Write-ZtProgress -Activity $activity -Status 'Querying diagnostic settings'

    $evaluationResults = @()

    foreach ($appGateway in $allAppGateways) {
        $appGatewayId = $appGateway.GatewayId
        $appGatewayName = $appGateway.GatewayName
        $appGatewayLocation = $appGateway.Location
        $appGatewaySkuTier = $appGateway.SkuTier

        # Q3: Query diagnostic settings using Invoke-ZtAzureRequest
        $diagPath = $appGatewayId + '/providers/Microsoft.Insights/diagnosticSettings?api-version=2021-05-01-preview'

        $diagSettings = @()
        try {
            $diagSettings = @(Invoke-ZtAzureRequest -Path $diagPath)
        }
        catch {
            Write-PSFMessage "Error querying diagnostic settings for $appGatewayName : $_" -Level Warning
        }

        # Evaluate diagnostic settings
        $hasValidDiagSetting = $false
        $allDestinationTypes = @()
        $enabledCategories = @()
        $diagSettingNames = @()

        foreach ($setting in $diagSettings) {
            $workspaceId = $setting.properties.workspaceId
            $storageAccountId = $setting.properties.storageAccountId
            $eventHubAuthRuleId = $setting.properties.eventHubAuthorizationRuleId

            # Check if destination is configured
            $hasDestination = $workspaceId -or $storageAccountId -or $eventHubAuthRuleId

            if ($hasDestination) {
                # Determine destination type
                $destTypes = @()
                if ($workspaceId) { $destTypes += 'Log Analytics' }
                if ($storageAccountId) { $destTypes += 'Storage' }
                if ($eventHubAuthRuleId) { $destTypes += 'Event Hub' }

                # Collect all enabled log categories from this setting
                $logs = $setting.properties.logs
                $settingEnabledCategories = @()
                foreach ($log in $logs) {
                    if ($log.enabled) {
                        # Handle both category and categoryGroup (per spec)
                        $categoryName = if ($log.category) { $log.category } else { $log.categoryGroup }
                        if ($categoryName) {
                            $settingEnabledCategories += $categoryName
                        }
                    }
                }

                # If this setting has destination AND enabled logs, it's valid
                if ($settingEnabledCategories.Count -gt 0) {
                    $hasValidDiagSetting = $true
                    $diagSettingNames += $setting.name
                    $allDestinationTypes += $destTypes
                    $enabledCategories += $settingEnabledCategories
                }
            }
        }

        # Deduplicate enabled categories and destination types (multiple settings may have same values)
        $enabledCategories = $enabledCategories | Select-Object -Unique
        $destinationType = if ($allDestinationTypes.Count -gt 0) { ($allDestinationTypes | Select-Object -Unique) -join ', ' } else { 'None' }

        $status = if ($hasValidDiagSetting) { 'Pass' } else { 'Fail' }

        $evaluationResults += [PSCustomObject]@{
            SubscriptionId         = $appGateway.SubscriptionId
            SubscriptionName       = $appGateway.SubscriptionName
            GatewayName            = $appGatewayName
            GatewayId              = $appGatewayId
            Location               = $appGatewayLocation
            SkuTier                = $appGatewaySkuTier
            DiagnosticSettingCount = $diagSettings.Count
            DiagnosticSettingName  = ($diagSettingNames | Select-Object -Unique) -join ', '
            DestinationType        = $destinationType
            EnabledCategories      = $enabledCategories -join ', '
            Status                 = $status
        }
    }

    #endregion Data Collection

    #region Assessment Logic

    $passedItems = $evaluationResults | Where-Object { $_.Status -eq 'Pass' }
    $failedItems = $evaluationResults | Where-Object { $_.Status -eq 'Fail' }

    $passed = ($failedItems.Count -eq 0) -and ($passedItems.Count -gt 0)

    if ($passed) {
        $testResultMarkdown = "✅ Diagnostic logging is enabled for Application Gateway WAF with active log collection configured.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "❌ Diagnostic logging is not enabled for Application Gateway WAF, preventing security monitoring and threat detection.`n`n%TestResult%"
    }

    #endregion Assessment Logic

    #region Report Generation

    # Portal link variables
    $portalAppGatewayBrowseLink = 'https://portal.azure.com/#browse/Microsoft.Network%2FapplicationGateways'
    $portalSubscriptionBaseLink = 'https://portal.azure.com/#resource/subscriptions'
    $portalResourceBaseLink = 'https://portal.azure.com/#resource'

    $mdInfo = "`n## [Application Gateway WAF diagnostic logging status]($portalAppGatewayBrowseLink)`n`n"

    # Application Gateway WAF Status table
    if ($evaluationResults.Count -gt 0) {
        $tableRows = ""
        $formatTemplate = @'
| Subscription | Gateway name | Location | SKU tier | Diagnostic settings count | Destination configured | Enabled log categories | Status |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
{0}

'@

        # Limit display to first 5 items if there are many gateways
        $maxItemsToDisplay = 5
        $displayResults = $evaluationResults
        $hasMoreItems = $false
        if ($evaluationResults.Count -gt $maxItemsToDisplay) {
            $displayResults = $evaluationResults | Select-Object -First $maxItemsToDisplay
            $hasMoreItems = $true
        }

        foreach ($result in $displayResults) {
            $subscriptionLink = "[$(Get-SafeMarkdown $result.SubscriptionName)]($portalSubscriptionBaseLink/$($result.SubscriptionId)/overview)"
            $gatewayLink = "[$(Get-SafeMarkdown $result.GatewayName)]($portalResourceBaseLink$($result.GatewayId)/diagnostics)"
            $diagCount = $result.DiagnosticSettingCount
            $destConfigured = if ($result.DestinationType -eq 'None') { 'No' } else { 'Yes' }
            $enabledCategories = if ($result.DiagnosticSettingCount -eq 0) {
                'No diagnostic settings'
            } elseif ($result.EnabledCategories) {
                $result.EnabledCategories
            } else {
                'None'
            }
            $statusText = if ($result.Status -eq 'Pass') { '✅ Pass' } else { '❌ Fail' }

            $tableRows += "| $subscriptionLink | $gatewayLink | $($result.Location) | $($result.SkuTier) | $diagCount | $destConfigured | $enabledCategories | $statusText |`n"
        }

        # Add note if more items exist
        if ($hasMoreItems) {
            $remainingCount = $evaluationResults.Count - $maxItemsToDisplay
            $tableRows += "`n... and $remainingCount more. [View all Application Gateways in the portal]($portalAppGatewayBrowseLink)`n"
        }

        $mdInfo += $formatTemplate -f $tableRows
    }

    # Summary
    $mdInfo += "**Summary:**`n`n"
    $mdInfo += "- Total Application Gateways with WAF evaluated: $($evaluationResults.Count)`n"
    $mdInfo += "- Gateways with diagnostic logging enabled: $($passedItems.Count)`n"
    $mdInfo += "- Gateways without diagnostic logging: $($failedItems.Count)`n"

    # Replace the placeholder with detailed information
    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo

    #endregion Report Generation

    $params = @{
        TestId = '26888'
        Title  = 'Diagnostic logging is enabled in Application Gateway WAF'
        Status = $passed
        Result = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
