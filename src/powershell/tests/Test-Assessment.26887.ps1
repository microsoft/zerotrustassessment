<#
.SYNOPSIS
    Validates that diagnostic logging is enabled for Azure Firewall.

.DESCRIPTION
    This test evaluates diagnostic settings for Azure Firewall resources to ensure
    log categories are enabled with a valid destination configured (Log Analytics,
    Storage Account, or Event Hub).

.NOTES
    Test ID: 26887
    Category: Azure Network Security
    Required APIs: Azure Management REST API (subscriptions, firewalls, diagnostic settings)
#>

function Test-Assessment-26887 {

    [ZtTest(
        Category = 'Azure Network Security',
        ImplementationCost = 'Low',
        MinimumLicense = ('Azure_Firewall_Standard', 'Azure_Firewall_Premium'),
        Pillar = 'Network',
        RiskLevel = 'High',
        SfiPillar = 'Monitor and detect cyberthreats',
        TenantType = ('Workforce'),
        TestId = 26887,
        Title = 'Diagnostic logging is enabled in Azure Firewall',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose
    $activity = 'Evaluating Azure Firewall diagnostic logging configuration'

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

    # Q1 & Q2: Query Azure Firewalls using Azure Resource Graph
    Write-ZtProgress -Activity $activity -Status 'Querying Azure Firewalls via Resource Graph'

    $argQuery = @"
resources
| where type =~ 'microsoft.network/azurefirewalls'
| where properties.provisioningState =~ 'Succeeded'
| join kind=leftouter (
    resourcecontainers
    | where type =~ 'microsoft.resources/subscriptions'
    | project subscriptionName=name, subscriptionId
) on subscriptionId
| project
    FirewallName=name,
    FirewallId=id,
    Location=location,
    SkuName=tostring(properties.sku.name),
    SkuTier=tostring(properties.sku.tier),
    SubscriptionId=subscriptionId,
    SubscriptionName=subscriptionName
"@

    $allFirewalls = @()
    try {
        $allFirewalls = @(Invoke-ZtAzureResourceGraphRequest -Query $argQuery)
        Write-PSFMessage "ARG Query returned $($allFirewalls.Count) Azure Firewall(s)" -Tag Test -Level VeryVerbose
    }
    catch {
        Write-PSFMessage "Azure Resource Graph query failed: $($_.Exception.Message)" -Tag Test -Level Warning
        Add-ZtTestResultDetail -SkippedBecause NotSupported
        return
    }

    # Check if any Azure Firewall resources exist
    if ($allFirewalls.Count -eq 0) {
        Write-PSFMessage 'No Azure Firewall resources found.' -Tag Test -Level VeryVerbose
        Add-ZtTestResultDetail -SkippedBecause NotApplicable
        return
    }

    # Q3: Get diagnostic settings for each Azure Firewall
    Write-ZtProgress -Activity $activity -Status 'Querying diagnostic settings'

    $evaluationResults = @()

    foreach ($firewall in $allFirewalls) {
        $firewallId = $firewall.FirewallId
        $firewallName = $firewall.FirewallName
        $firewallLocation = $firewall.Location
        $firewallSku = "$($firewall.SkuName)/$($firewall.SkuTier)"

        # Q3: Query diagnostic settings using Invoke-ZtAzureRequest
        $diagPath = $firewallId + '/providers/Microsoft.Insights/diagnosticSettings?api-version=2021-05-01-preview'

        $diagSettings = @()
        try {
            $diagSettings = @(Invoke-ZtAzureRequest -Path $diagPath)
        }
        catch {
            Write-PSFMessage "Error querying diagnostic settings for $firewallName : $_" -Level Warning
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
            SubscriptionId         = $firewall.SubscriptionId
            SubscriptionName       = $firewall.SubscriptionName
            FirewallName           = $firewallName
            FirewallId             = $firewallId
            Location               = $firewallLocation
            Sku                    = $firewallSku
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
        $testResultMarkdown = "✅ Diagnostic logging is enabled for Azure Firewall with active log collection configured.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "❌ Diagnostic logging is not enabled for Azure Firewall, preventing security monitoring and threat detection.`n`n%TestResult%"
    }

    #endregion Assessment Logic

    #region Report Generation

    # Portal link variables
    $portalFirewallBrowseLink = 'https://portal.azure.com/#browse/Microsoft.Network%2FazureFirewalls'
    $portalSubscriptionBaseLink = 'https://portal.azure.com/#resource/subscriptions'
    $portalResourceBaseLink = 'https://portal.azure.com/#resource'

    $mdInfo = "`n## [Azure Firewall diagnostic logging status]($portalFirewallBrowseLink)`n`n"

    # Azure Firewall Status table
    if ($evaluationResults.Count -gt 0) {
        $tableRows = ""
        $formatTemplate = @'
| Subscription | Firewall name | Location | Diagnostic settings count | Destination configured | Enabled log categories | Status |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
{0}

'@

        # Limit display to first 5 items if there are many firewalls
        $maxItemsToDisplay = 5
        $displayResults = $evaluationResults
        $hasMoreItems = $false
        if ($evaluationResults.Count -gt $maxItemsToDisplay) {
            $displayResults = $evaluationResults | Select-Object -First $maxItemsToDisplay
            $hasMoreItems = $true
        }

        foreach ($result in $displayResults) {
            $subscriptionLink = "[$(Get-SafeMarkdown $result.SubscriptionName)]($portalSubscriptionBaseLink/$($result.SubscriptionId)/overview)"
            $firewallLink = "[$(Get-SafeMarkdown $result.FirewallName)]($portalResourceBaseLink$($result.FirewallId)/diagnostics)"
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

            $tableRows += "| $subscriptionLink | $firewallLink | $($result.Location) | $diagCount | $destConfigured | $enabledCategories | $statusText |`n"
        }

        # Add note if more items exist
        if ($hasMoreItems) {
            $remainingCount = $evaluationResults.Count - $maxItemsToDisplay
            $tableRows += "`n... and $remainingCount more. [View all Azure Firewalls in the portal]($portalFirewallBrowseLink)`n"
        }

        $mdInfo += $formatTemplate -f $tableRows
    }

    # Summary
    $mdInfo += "**Summary:**`n`n"
    $mdInfo += "- Total Azure Firewalls evaluated: $($evaluationResults.Count)`n"
    $mdInfo += "- Firewalls with diagnostic logging enabled: $($passedItems.Count)`n"
    $mdInfo += "- Firewalls without diagnostic logging: $($failedItems.Count)`n"

    # Replace the placeholder with detailed information
    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo

    #endregion Report Generation

    $params = @{
        TestId = '26887'
        Title  = 'Diagnostic logging is enabled in Azure Firewall'
        Status = $passed
        Result = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
