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
        MinimumLicense = ('Azure_Firewall'),
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

    # Q1: List all subscriptions
    Write-ZtProgress -Activity $activity -Status 'Querying subscriptions'

    $subscriptionsPath = '/subscriptions?api-version=2022-12-01'
    $subscriptions = $null

    try {
        $result = Invoke-AzRestMethod -Path $subscriptionsPath -ErrorAction Stop

        if ($result.StatusCode -eq 403) {
            Write-PSFMessage 'The signed in user does not have access to list subscriptions.' -Level Verbose
            Add-ZtTestResultDetail -SkippedBecause NoAzureAccess
            return
        }

        if ($result.StatusCode -ge 400) {
            throw "Subscriptions request failed with status code $($result.StatusCode)"
        }

        # Azure REST list APIs are paginated.
        # Handling nextLink is required to avoid missing subscriptions.
        $allSubscriptions = @()
        $subscriptionsJson = $result.Content | ConvertFrom-Json -ErrorAction Stop

        if ($subscriptionsJson.value) {
            $allSubscriptions += $subscriptionsJson.value
        }

        $nextLink = $subscriptionsJson.nextLink
        try {
            while ($nextLink) {
                $result = Invoke-AzRestMethod -Uri $nextLink -Method GET
                $subscriptionsJson = $result.Content | ConvertFrom-Json -ErrorAction Stop
                if ($subscriptionsJson.value) {
                    $allSubscriptions += $subscriptionsJson.value
                }
                $nextLink = $subscriptionsJson.nextLink
            }
        }
        catch {
            Write-PSFMessage "Failed to retrieve next page of subscriptions: $_. Continuing with collected data." -Level Warning
        }

        $subscriptions = $allSubscriptions | Where-Object { $_.state -eq 'Enabled' }
    }
    catch {
        Write-PSFMessage "Failed to enumerate Azure subscriptions while evaluating Azure Firewall diagnostic logging: $_" -Level Error
        throw
    }

    if ($null -eq $subscriptions -or $subscriptions.Count -eq 0) {
        Write-PSFMessage 'No enabled subscriptions found.' -Level Warning
        Add-ZtTestResultDetail -SkippedBecause NotSupported
        return
    }

    # Collect Azure Firewall resources across all subscriptions
    $allFirewalls = @()
    $firewallQuerySuccess = $false

    foreach ($subscription in $subscriptions) {
        $subscriptionId = $subscription.subscriptionId

        # Q2: List Azure Firewalls
        Write-ZtProgress -Activity $activity -Status "Querying Azure Firewalls in subscription $subscriptionId"

        $firewallListPath = "/subscriptions/$subscriptionId/providers/Microsoft.Network/azureFirewalls?api-version=2025-03-01"

        try {
            $firewallListResult = Invoke-AzRestMethod -Path $firewallListPath -ErrorAction Stop

            if ($firewallListResult.StatusCode -lt 400) {
                $firewallQuerySuccess = $true
                # Azure REST list APIs are paginated.
                # Handling nextLink is required to avoid missing Azure Firewalls.
                $allFirewallsInSub = @()
                $firewallJson = $firewallListResult.Content | ConvertFrom-Json -ErrorAction Stop

                if ($firewallJson.value) {
                    $allFirewallsInSub += $firewallJson.value
                }

                $nextLink = $firewallJson.nextLink
                try {
                    while ($nextLink) {
                        $firewallListResult = Invoke-AzRestMethod -Uri $nextLink -Method GET
                        $firewallJson = $firewallListResult.Content | ConvertFrom-Json -ErrorAction Stop
                        if ($firewallJson.value) {
                            $allFirewallsInSub += $firewallJson.value
                        }
                        $nextLink = $firewallJson.nextLink
                    }
                }
                catch {
                    Write-PSFMessage "Failed to retrieve next page of Azure Firewalls for subscription '$subscriptionId': $_. Continuing with collected data." -Level Warning
                }

                # Filter for active firewalls (provisioningState == Succeeded)
                $activeFirewalls = $allFirewallsInSub | Where-Object { $_.properties.provisioningState -eq 'Succeeded' }
                foreach ($firewall in $activeFirewalls) {
                    $allFirewalls += [PSCustomObject]@{
                        SubscriptionId   = $subscriptionId
                        SubscriptionName = $subscription.displayName
                        Firewall         = $firewall
                    }
                }
            }
        }
        catch {
            Write-PSFMessage "Error querying Azure Firewalls in subscription $subscriptionId : $_" -Level Warning
        }
    }

    # Check if any Azure Firewall resources exist
    if ($allFirewalls.Count -eq 0) {
        if (-not $firewallQuerySuccess) {
            Write-PSFMessage 'Unable to query Azure Firewall resources in any subscription due to access restrictions.' -Level Warning
            Add-ZtTestResultDetail -SkippedBecause NoAzureAccess
            return
        }
        Write-PSFMessage 'No Azure Firewall resources found.' -Tag Test -Level VeryVerbose
        Add-ZtTestResultDetail -SkippedBecause NotLicensedOrNotApplicable
        return
    }

    # Q3: Get diagnostic settings for each Azure Firewall
    Write-ZtProgress -Activity $activity -Status 'Querying diagnostic settings'

    $evaluationResults = @()

    foreach ($fwItem in $allFirewalls) {
        $firewall = $fwItem.Firewall
        $firewallId = $firewall.id
        $firewallName = $firewall.name
        $firewallLocation = $firewall.location
        $firewallSku = "$($firewall.properties.sku.name)/$($firewall.properties.sku.tier)"

        # Q3: Query diagnostic settings
        $diagPath = $firewallId + '/providers/Microsoft.Insights/diagnosticSettings?api-version=2021-05-01-preview'

        $diagSettings = @()
        try {
            $diagResult = Invoke-AzRestMethod -Path $diagPath -ErrorAction Stop

            if ($diagResult.StatusCode -lt 400) {
                $diagSettings = ($diagResult.Content | ConvertFrom-Json -ErrorAction Stop).value
            }
        }
        catch {
            Write-PSFMessage "Error querying diagnostic settings for $firewallName : $_" -Level Warning
        }

        # Evaluate diagnostic settings
        $hasValidDiagSetting = $false
        $destinationType = 'None'
        $enabledCategories = @()
        $diagSettingName = 'None'

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
                    $diagSettingName = $setting.name
                    $destinationType = $destTypes -join ', '
                    $enabledCategories += $settingEnabledCategories
                }
            }
        }

        # Deduplicate enabled categories (multiple settings may enable same categories)
        $enabledCategories = $enabledCategories | Select-Object -Unique

        $status = if ($hasValidDiagSetting) { 'Pass' } else { 'Fail' }

        $evaluationResults += [PSCustomObject]@{
            SubscriptionId         = $fwItem.SubscriptionId
            SubscriptionName       = $fwItem.SubscriptionName
            FirewallName           = $firewallName
            FirewallId             = $firewallId
            Location               = $firewallLocation
            Sku                    = $firewallSku
            DiagnosticSettingCount = $diagSettings.Count
            DiagnosticSettingName  = $diagSettingName
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
