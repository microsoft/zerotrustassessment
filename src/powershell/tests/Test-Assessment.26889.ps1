<#
.SYNOPSIS
    Validates that diagnostic logging is enabled for Azure Front Door WAF.

.DESCRIPTION
    This test evaluates diagnostic settings for Azure Front Door profiles to ensure
    WAF log categories are enabled with a valid destination configured (Log Analytics,
    Storage Account, or Event Hub).

.NOTES
    Test ID: 26889
    Category: Azure Network Security
    Required APIs: Azure Management REST API (subscriptions, profiles, WAF policies, diagnostic settings)
#>

function Test-Assessment-26889 {

    [ZtTest(
        Category = 'Azure Network Security',
        ImplementationCost = 'Low',
        MinimumLicense = ('Azure_FrontDoor_Standard', 'Azure_FrontDoor_Premium'),
        Pillar = 'Network',
        RiskLevel = 'High',
        SfiPillar = 'Monitor and detect cyberthreats',
        TenantType = ('Workforce'),
        TestId = 26889,
        Title = 'Diagnostic logging is enabled in Azure Front Door WAF',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    # Required log categories for comprehensive Azure Front Door WAF monitoring
    $REQUIRED_LOG_CATEGORIES = @(
        'FrontDoorAccessLog',
        'FrontDoorWebApplicationFirewallLog',
        'FrontDoorHealthProbeLog'
    )

    # WAF log category to check for pass/fail criteria (per spec)
    $WAF_LOG_CATEGORY = 'FrontDoorWebApplicationFirewallLog'

    # Valid Azure Front Door SKUs
    $VALID_FRONT_DOOR_SKUS = @('Standard_AzureFrontDoor', 'Premium_AzureFrontDoor')

    #region Data Collection

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose
    $activity = 'Evaluating Azure Front Door WAF diagnostic logging configuration'

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
        $subscriptionsJson = $result.Content | ConvertFrom-Json

        if ($subscriptionsJson.value) {
            $allSubscriptions += $subscriptionsJson.value
        }

        $nextLink = $subscriptionsJson.nextLink
        try {
            while ($nextLink) {
                $result = Invoke-AzRestMethod -Uri $nextLink -Method GET
                $subscriptionsJson = $result.Content | ConvertFrom-Json
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
        Write-PSFMessage "Failed to enumerate Azure subscriptions while evaluating Front Door WAF diagnostic logging: $_" -Level Error
        throw
    }

    if ($null -eq $subscriptions -or $subscriptions.Count -eq 0) {
        Write-PSFMessage 'No enabled subscriptions found.' -Level Warning
        Add-ZtTestResultDetail -SkippedBecause NotSupported
        return
    }

    # Collect Front Door resources and WAF policies across all subscriptions
    $allAfdResources = @()
    $allWafPolicies = @()
    $frontDoorQuerySuccess = $false
    $wafQuerySuccess = $false

    foreach ($subscription in $subscriptions) {
        $subscriptionId = $subscription.subscriptionId

        # Q2: List Azure Front Door resources
        Write-ZtProgress -Activity $activity -Status "Querying Front Door resources in subscription $subscriptionId"

        $afdListPath = "/subscriptions/$subscriptionId/providers/Microsoft.Cdn/profiles?api-version=2024-02-01"

        try {
            $afdListResult = Invoke-AzRestMethod -Path $afdListPath -ErrorAction Stop

            if ($afdListResult.StatusCode -lt 400) {
                $frontDoorQuerySuccess = $true
                # Azure REST list APIs are paginated.
                # Handling nextLink is required to avoid missing Front Door profiles.
                $allCdnResources = @()
                $cdnJson = $afdListResult.Content | ConvertFrom-Json

                if ($cdnJson.value) {
                    $allCdnResources += $cdnJson.value
                }

                $nextLink = $cdnJson.nextLink
                try {
                    while ($nextLink) {
                        $afdListResult = Invoke-AzRestMethod -Uri $nextLink -Method GET
                        $cdnJson = $afdListResult.Content | ConvertFrom-Json
                        if ($cdnJson.value) {
                            $allCdnResources += $cdnJson.value
                        }
                        $nextLink = $cdnJson.nextLink
                    }
                }
                catch {
                    Write-PSFMessage "Failed to retrieve next page of Front Door profiles for subscription '$subscriptionId': $_. Continuing with collected data." -Level Warning
                }

                # Filter for Standard/Premium Azure Front Door SKUs
                $afdResources = $allCdnResources | Where-Object { $_.sku.name -in $VALID_FRONT_DOOR_SKUS }
                foreach ($afdResource in $afdResources) {
                    $allAfdResources += [PSCustomObject]@{
                        SubscriptionId    = $subscriptionId
                        SubscriptionName  = $subscription.displayName
                        FrontDoor         = $afdResource
                    }
                }
            }
        }
        catch {
            Write-PSFMessage "Error querying Front Door resources in subscription $subscriptionId : $_" -Level Warning
        }

        # Q3: List WAF policies
        Write-ZtProgress -Activity $activity -Status "Querying WAF policies in subscription $subscriptionId"

        $wafPath = "/subscriptions/$subscriptionId/providers/Microsoft.Network/FrontDoorWebApplicationFirewallPolicies?api-version=2024-02-01"

        try {
            $wafResult = Invoke-AzRestMethod -Path $wafPath -ErrorAction Stop

            if ($wafResult.StatusCode -lt 400) {
                $wafQuerySuccess = $true
                # Azure REST list APIs are paginated.
                # Handling nextLink is required to avoid missing WAF policies.
                $allWafPoliciesInSub = @()
                $wafJson = $wafResult.Content | ConvertFrom-Json

                if ($wafJson.value) {
                    $allWafPoliciesInSub += $wafJson.value
                }

                $nextLink = $wafJson.nextLink
                try {
                    while ($nextLink) {
                        $wafResult = Invoke-AzRestMethod -Uri $nextLink -Method GET
                        $wafJson = $wafResult.Content | ConvertFrom-Json
                        if ($wafJson.value) {
                            $allWafPoliciesInSub += $wafJson.value
                        }
                        $nextLink = $wafJson.nextLink
                    }
                }
                catch {
                    Write-PSFMessage "Failed to retrieve next page of WAF policies for subscription '$subscriptionId': $_. Continuing with collected data." -Level Warning
                }

                foreach ($policy in $allWafPoliciesInSub) {
                    $allWafPolicies += [PSCustomObject]@{
                        SubscriptionId = $subscriptionId
                        Policy         = $policy
                    }
                }
            }
        }
        catch {
            Write-PSFMessage "Error querying WAF policies in subscription $subscriptionId : $_" -Level Warning
        }
    }

    # Check if any Front Door resources exist
    if ($allAfdResources.Count -eq 0) {
        if (-not $frontDoorQuerySuccess) {
            Write-PSFMessage 'Unable to query Front Door resources in any subscription due to access restrictions.' -Level Warning
            Add-ZtTestResultDetail -SkippedBecause NoAzureAccess
            return
        }
        Write-PSFMessage 'No Azure Front Door Standard/Premium resources found.' -Tag Test -Level VeryVerbose
        Add-ZtTestResultDetail -SkippedBecause NotLicensedOrNotApplicable
        return
    }

    # Check if WAF policies could be queried
    if ($allWafPolicies.Count -eq 0 -and -not $wafQuerySuccess) {
        Write-PSFMessage 'Unable to query WAF policies in any subscription due to access restrictions.' -Level Warning
        Add-ZtTestResultDetail -SkippedBecause NoAzureAccess
        return
    }

    # Filter profiles to only those with associated WAF policies (per spec step 3)
    # Use Q3's securityPolicyLinks to find WAF associations
    $profilesWithWaf = @()
    foreach ($fdItem in $allAfdResources) {
        $frontDoorId = $fdItem.FrontDoor.id
        # Check if any WAF policy has securityPolicyLinks pointing to this Front Door
        $matchedWafPolicy = $allWafPolicies | Where-Object {
            $_.Policy.properties.securityPolicyLinks | Where-Object { $_.id -match [regex]::Escape($frontDoorId) }
        }
        if ($matchedWafPolicy) {
            $profilesWithWaf += [PSCustomObject]@{
                SubscriptionId   = $fdItem.SubscriptionId
                SubscriptionName = $fdItem.SubscriptionName
                FrontDoor        = $fdItem.FrontDoor
                WafPolicyName    = ($matchedWafPolicy.Policy.name | Select-Object -Unique) -join ', '
            }
        }
    }

    # Skip if no Azure Front Door profiles with WAF exist (per spec step 6)
    if ($profilesWithWaf.Count -eq 0) {
        Write-PSFMessage 'No Azure Front Door profiles with WAF found.' -Tag Test -Level VeryVerbose
        Add-ZtTestResultDetail -SkippedBecause NotLicensedOrNotApplicable
        return
    }

    # Q4: Get diagnostic settings for each Front Door resource
    Write-ZtProgress -Activity $activity -Status 'Querying diagnostic settings'

    $evaluationResults = @()

    # Iterate only over profiles with WAF (filtered above using Q3 securityPolicyLinks)
    foreach ($fdItem in $profilesWithWaf) {
        $frontDoor = $fdItem.FrontDoor
        $frontDoorId = $frontDoor.id
        $frontDoorName = $frontDoor.name
        $wafPolicyName = $fdItem.WafPolicyName  # WAF policy name from Q3 securityPolicyLinks

        # Q4: Query diagnostic settings
        $diagPath = $frontDoorId + '/providers/Microsoft.Insights/diagnosticSettings?api-version=2021-05-01-preview'

        $diagSettings = @()
        try {
            $diagResult = Invoke-AzRestMethod -Path $diagPath -ErrorAction Stop

            if ($diagResult.StatusCode -lt 400) {
                $diagSettings = ($diagResult.Content | ConvertFrom-Json).value
            }
        }
        catch {
            Write-PSFMessage "Error querying diagnostic settings for $frontDoorName : $_" -Level Warning
        }

        # Fallback: If WAF policy name not found via Q3 securityPolicyLinks, query security policies endpoint
        if (-not $wafPolicyName -or $wafPolicyName -eq 'None') {
            $securityPoliciesPath = $frontDoorId + '/securityPolicies?api-version=2024-02-01'

            try {
                $secPolicyResult = Invoke-AzRestMethod -Path $securityPoliciesPath -ErrorAction Stop

                if ($secPolicyResult.StatusCode -lt 400) {
                    $securityPolicies = ($secPolicyResult.Content | ConvertFrom-Json).value
                    # Get WAF policy references from security policies
                    $wafPolicyIds = $securityPolicies | ForEach-Object {
                        $_.properties.parameters.wafPolicy.id
                    } | Where-Object { $_ }

                    if ($wafPolicyIds) {
                        # Extract WAF policy names and join if multiple
                        $wafPolicyNames = $wafPolicyIds | ForEach-Object {
                            ($_ -split '/')[-1]
                        }
                        $wafPolicyName = ($wafPolicyNames | Select-Object -Unique) -join ', '
                    }
                }
            }
            catch {
                Write-PSFMessage "Error querying security policies for $frontDoorName : $_" -Level Warning
            }
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
                $hasValidDiagSetting = $true
                $diagSettingName = $setting.name

                # Determine destination type
                $destTypes = @()
                if ($workspaceId) { $destTypes += 'Log Analytics' }
                if ($storageAccountId) { $destTypes += 'Storage' }
                if ($eventHubAuthRuleId) { $destTypes += 'Event Hub' }
                $destinationType = $destTypes -join ', '

                # Collect all enabled log categories
                $logs = $setting.properties.logs
                foreach ($log in $logs) {
                    if ($log.enabled) {
                        $enabledCategories += $log.category
                    }
                }
            }
        }

        # Check which required log categories are enabled and if WAF log is enabled for pass criteria
        $enabledCategories = $enabledCategories | Select-Object -Unique
        $missingRequiredCategories = $REQUIRED_LOG_CATEGORIES | Where-Object { $_ -notin $enabledCategories }
        $wafLogEnabled = $WAF_LOG_CATEGORY -in $enabledCategories

        $status = if ($hasValidDiagSetting -and $wafLogEnabled) { 'Pass' } else { 'Fail' }

        $evaluationResults += [PSCustomObject]@{
            SubscriptionId        = $fdItem.SubscriptionId
            SubscriptionName      = $fdItem.SubscriptionName
            FrontDoorName         = $frontDoorName
            FrontDoorId           = $frontDoorId
            Sku                   = $frontDoor.sku.name
            WafPolicy             = $wafPolicyName
            DiagnosticSettingCount = $diagSettings.Count
            DiagnosticSettingName = $diagSettingName
            DestinationType       = $destinationType
            EnabledCategories     = $enabledCategories -join ', '
            MissingRequiredCategories = $missingRequiredCategories -join ', '
            WafLogEnabled         = $wafLogEnabled
            Status                = $status
        }
    }

    #endregion Data Collection

    #region Assessment Logic

    $passedItems = $evaluationResults | Where-Object { $_.Status -eq 'Pass' }
    $failedItems = $evaluationResults | Where-Object { $_.Status -eq 'Fail' }

    $passed = ($failedItems.Count -eq 0) -and ($passedItems.Count -gt 0)

    if ($passed) {
        $testResultMarkdown = "✅ Diagnostic logging is enabled for Azure Front Door WAF with active log collection configured.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "❌ Diagnostic logging is not enabled for Azure Front Door WAF, preventing security monitoring and threat detection at the edge.`n`n%TestResult%"
    }

    #endregion Assessment Logic

    #region Report Generation

    $mdInfo = "`n## [Azure Front Door WAF diagnostic logging status](https://portal.azure.com/#view/HubsExtension/BrowseResource/resourceType/Microsoft.Cdn%2Fprofiles)`n`n"

    # Front Door Status table
    if ($evaluationResults.Count -gt 0) {
        $tableRows = ""
        $formatTemplate = @'
| Subscription | Profile name | SKU | WAF policy | Diagnostic settings count | Destination configured | Enabled log categories | Status |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
{0}

'@
        foreach ($result in $evaluationResults) {
            $subscriptionLink = "[$(Get-SafeMarkdown $result.SubscriptionName)](https://portal.azure.com/#resource/subscriptions/$($result.SubscriptionId)/overview)"
            $profileLink = "[$(Get-SafeMarkdown $result.FrontDoorName)](https://portal.azure.com/#resource$($result.FrontDoorId)/diagnostics)"
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

            $tableRows += "| $subscriptionLink | $profileLink | $($result.Sku) | $(Get-SafeMarkdown $result.WafPolicy) | $diagCount | $destConfigured | $enabledCategories | $statusText |`n"
        }
        $mdInfo += $formatTemplate -f $tableRows
    }

    # Summary
    $mdInfo += "**Summary:**`n`n"
    $mdInfo += "- Total Azure Front Door profiles with WAF evaluated: $($evaluationResults.Count)`n"
    $mdInfo += "- Profiles with diagnostic logging enabled: $($passedItems.Count)`n"
    $mdInfo += "- Profiles without diagnostic logging: $($failedItems.Count)`n"

    # Replace the placeholder with detailed information
    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo

    #endregion Report Generation

    $params = @{
        TestId = '26889'
        Title  = 'Diagnostic logging is enabled in Azure Front Door WAF'
        Status = $passed
        Result = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
