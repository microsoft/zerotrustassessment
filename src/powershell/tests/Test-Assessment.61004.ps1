<#
.SYNOPSIS
    Validates that Microsoft Defender for Cloud CSPM plan is enabled on all Azure subscriptions.

.DESCRIPTION
    This test evaluates the Defender for Cloud CloudPosture pricing tier for every enabled
    Azure subscription. A subscription passes only when pricingTier is 'Standard'.
    Without the CSPM plan active, AI posture recommendations, attack-path visibility, and
    AI Security Posture features cannot run on the subscription.

.NOTES
    Test ID: 61004
    Category: AI Cloud Posture
    Required APIs: Azure Resource Graph (resourcecontainers/subscriptions),
                   Azure Management REST API (Microsoft.Security/pricings/CloudPosture)
#>

function Test-Assessment-61004 {

    [ZtTest(
        Category = 'AI Cloud Posture',
        ImplementationCost = 'Medium',
        Service = ('Azure'),
        MinimumLicense = ('Microsoft_Defender_for_Cloud'),
        Pillar = 'AI',
        RiskLevel = 'High',
        SfiPillar = 'Protect tenants and production systems',
        TenantType = ('Workforce'),
        TestId = 61004,
        Title = 'Microsoft Defender for Cloud CSPM plan is enabled on all Azure subscriptions',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose
    $activity = 'Evaluating Microsoft Defender for Cloud CSPM plan configuration'

    # Q1: Enumerate all enabled subscriptions via Azure Resource Graph
    Write-ZtProgress -Activity $activity -Status 'Querying enabled subscriptions via Resource Graph'

    $argQuery = @"
resourcecontainers
| where type =~ 'microsoft.resources/subscriptions'
| where properties.state =~ 'Enabled'
| project subscriptionId, displayName=name
"@

    $allSubscriptions = @()
    try {
        $allSubscriptions = @(Invoke-ZtAzureResourceGraphRequest -Query $argQuery)
        Write-PSFMessage "ARG Query returned $($allSubscriptions.Count) enabled subscription(s)" -Tag Test -Level VeryVerbose
    }
    catch {
        Write-PSFMessage "Azure Resource Graph query failed: $($_.Exception.Message)" -Tag Test -Level Warning
        Add-ZtTestResultDetail -SkippedBecause NotSupported
        return
    }

    if ($allSubscriptions.Count -eq 0) {
        Write-PSFMessage 'No enabled Azure subscriptions found.' -Tag Test -Level VeryVerbose
        Add-ZtTestResultDetail -SkippedBecause NotApplicable
        return
    }

    # Q2: For each subscription, read the Defender for Cloud CloudPosture pricing plan
    Write-ZtProgress -Activity $activity -Status 'Querying Defender for Cloud CSPM plan per subscription'

    $evaluationResults = @()

    foreach ($subscription in $allSubscriptions) {
        $subscriptionId = $subscription.subscriptionId
        $displayName    = $subscription.displayName

        $pricingPath = "/subscriptions/$subscriptionId/providers/Microsoft.Security/pricings/CloudPosture?api-version=2024-01-01"
        $pricingTier = 'Not Found'

        try {
            $pricingResponse = Invoke-ZtAzureRequest -Path $pricingPath
            $pricingTier = if ($pricingResponse.properties.pricingTier) { $pricingResponse.properties.pricingTier } else { 'Unknown' }
        }
        catch {
            Write-PSFMessage "Error querying Defender CSPM plan for subscription '$displayName' ($subscriptionId): $_" -Tag Test -Level Warning
        }

        $evaluationResults += [PSCustomObject]@{
            SubscriptionId = $subscriptionId
            DisplayName    = $displayName
            PricingTier    = $pricingTier
        }
    }

    #endregion Data Collection

    #region Assessment Logic

    $failedItems = @($evaluationResults | Where-Object { $_.PricingTier -ne 'Standard' })
    $passed = $failedItems.Count -eq 0

    if ($passed) {
        $testResultMarkdown = "✅ Microsoft Defender for Cloud CSPM plan (Standard tier) is enabled on every in-scope Azure subscription.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "❌ One or more in-scope Azure subscriptions do not have the Defender CSPM plan enabled.`n`n%TestResult%"
    }

    #endregion Assessment Logic

    #region Report Generation

    $portalCspmLink             = 'https://portal.azure.com/#view/Microsoft_Azure_Security/SecurityMenuBlade/~/EnvironmentSettings'
    $portalSubPricingBaseLink    = 'https://portal.azure.com/#view/Microsoft_Azure_Security/PolicyMenuBlade/~/pricingTier/subscriptionId'

    $formatTemplate = @'


## [{0}]({1})

| Display name | Pricing tier |
| :----------- | :----------- |
{2}
'@

    $mdInfo = ''
    if ($failedItems.Count -gt 0) {
        $tableRows         = ''
        $maxItemsToDisplay = 10
        $displayResults    = @($failedItems | Sort-Object DisplayName)
        $hasMoreItems      = $false
        if ($displayResults.Count -gt $maxItemsToDisplay) {
            $displayResults = @($displayResults | Select-Object -First $maxItemsToDisplay)
            $hasMoreItems   = $true
        }

        foreach ($result in $displayResults) {
            $displayNameLink = "[$(Get-SafeMarkdown $result.DisplayName)]($portalSubPricingBaseLink/$($result.SubscriptionId))"
            $pricingTierSafe = $result.PricingTier
            $tableRows      += "| $displayNameLink | $pricingTierSafe |`n"
        }

        if ($hasMoreItems) {
            $remainingCount = $failedItems.Count - $maxItemsToDisplay
            $tableRows += "`n... and $remainingCount more. [View all subscriptions in Microsoft Defender for Cloud]($portalCspmLink)`n"
        }

        $mdInfo = $formatTemplate -f 'Subscriptions missing Defender CSPM plan', $portalCspmLink, $tableRows
    }

    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo

    #endregion Report Generation

    $params = @{
        TestId = '61004'
        Title  = 'Microsoft Defender for Cloud CSPM plan is enabled on all Azure subscriptions'
        Status = $passed
        Result = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
