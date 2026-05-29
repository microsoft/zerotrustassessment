<#
.SYNOPSIS
    Validates that Microsoft Defender for AI Services is enabled on every Azure subscription
    that hosts Azure OpenAI or Azure AI Services accounts.

.DESCRIPTION
    This test evaluates the Microsoft Defender for AI Services pricing plan for every Azure
    subscription that contains at least one Azure OpenAI or Azure AI Services account. A
    subscription passes only when the AI plan pricingTier is 'Standard'. Subscriptions without
    the plan active emit no AI threat alerts regardless of downstream Sentinel or Defender XDR
    configuration.

.NOTES
    Test ID: 61022
    Category: AI Threat Detection
    Required APIs: Azure Resource Graph (resourcecontainers/subscriptions, Microsoft.CognitiveServices/accounts),
                   Azure Management REST API (Microsoft.Security/pricings/AI)
#>

function Test-Assessment-61022 {

    [ZtTest(
        Category = 'AI Threat Detection',
        ImplementationCost = 'Low',
        Service = ('Azure'),
        MinimumLicense = ('Microsoft_Defender_for_AI_Services'),
        Pillar = 'AI',
        RiskLevel = 'High',
        SfiPillar = 'Monitor and detect cyberthreats',
        TenantType = ('Workforce'),
        TestId = 61022,
        Title = 'Microsoft Defender for AI Services is enabled on every Azure subscription that hosts Azure OpenAI or Azure AI Services accounts',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose
    $activity = 'Evaluating Microsoft Defender for AI Services plan coverage'

    # Q1 & Q2: Enumerate Azure OpenAI / Azure AI Services accounts with subscription display names
    # in a single Azure Resource Graph query using a join across resources and resourcecontainers
    Write-ZtProgress -Activity $activity -Status 'Querying Azure OpenAI and Azure AI Services accounts via Resource Graph'

    $argAiAccountQuery = @"
resources
| where type =~ 'Microsoft.CognitiveServices/accounts'
| where kind in ('OpenAI', 'AIServices')
| project accountId=id, accountName=name, subscriptionId
| join kind=leftouter (
    resourcecontainers
    | where type =~ 'microsoft.resources/subscriptions'
    | where properties.state =~ 'Enabled'
    | project subscriptionId, subscriptionDisplayName=name
) on subscriptionId
| project accountId, accountName, subscriptionId, subscriptionDisplayName
"@

    $allAiAccounts = @()
    try {
        $allAiAccounts = @(Invoke-ZtAzureResourceGraphRequest -Query $argAiAccountQuery)
        Write-PSFMessage "ARG query returned $($allAiAccounts.Count) Azure OpenAI / Azure AI Services account(s)" -Tag Test -Level VeryVerbose
    }
    catch {
        Write-PSFMessage "Azure Resource Graph query failed: $($_.Exception.Message)" -Tag Test -Level Warning
        Add-ZtTestResultDetail -SkippedBecause NotSupported
        return
    }

    # If no AI accounts exist, the check is not applicable — nothing for Defender for AI Services to protect
    if ($allAiAccounts.Count -eq 0) {
        Write-PSFMessage 'No Azure OpenAI or Azure AI Services accounts found in tenant.' -Tag Test -Level VeryVerbose
        Add-ZtTestResultDetail -SkippedBecause NotApplicable
        return
    }

    # Build per-subscription info (display name + AI account count) from the combined ARG results
    $inScopeSubscriptionIds = @($allAiAccounts | Select-Object -ExpandProperty subscriptionId -Unique)

    $subscriptionInfoBySubscription = @{}
    foreach ($account in $allAiAccounts) {
        $subId = $account.subscriptionId
        if (-not $subscriptionInfoBySubscription.ContainsKey($subId)) {
            $subscriptionInfoBySubscription[$subId] = @{
                DisplayName    = if ($account.subscriptionDisplayName) { $account.subscriptionDisplayName } else { $subId }
                AiAccountCount = 0
            }
        }
        $subscriptionInfoBySubscription[$subId].AiAccountCount++
    }

    # Q3: Read the Defender for AI Services pricing plan for each in-scope subscription
    Write-ZtProgress -Activity $activity -Status 'Querying Defender for AI Services plan per in-scope subscription'

    $evaluationResults = @()

    foreach ($subscriptionId in $inScopeSubscriptionIds) {
        $displayName    = $subscriptionInfoBySubscription[$subscriptionId].DisplayName
        $aiAccountCount = $subscriptionInfoBySubscription[$subscriptionId].AiAccountCount

        $pricingPath = "/subscriptions/$subscriptionId/providers/Microsoft.Security/pricings/AI?api-version=2024-01-01"
        $pricingTier = 'Not configured'
        $rowStatus   = 'Fail'

        try {
            $pricingResponse = Invoke-ZtAzureRequest -Path $pricingPath
            if ($null -ne $pricingResponse -and $null -ne $pricingResponse.properties.pricingTier) {
                $pricingTier = $pricingResponse.properties.pricingTier
                $rowStatus   = if ($pricingTier -eq 'Standard') { 'Pass' } else { 'Fail' }
            }
        }
        catch {
            $httpStatusCode = $null
            # Invoke-ZtAzureRequestCache throws a string like:
            # "Azure REST request failed with status 403: ..."
            # so there is no .Response property. Parse the message instead.
            if ($_.Exception.Message -match 'with status (\d+):') {
                $httpStatusCode = [int]$Matches[1]
            }
            elseif ($_.Exception.Response) {
                $httpStatusCode = [int]$_.Exception.Response.StatusCode
            }

            if ($httpStatusCode -eq 404) {
                # 404 means the AI plan has never been configured on this subscription; treat as Fail per spec
                $pricingTier = 'Not configured'
                $rowStatus   = 'Fail'
            }
            elseif ($httpStatusCode -in @(401, 403)) {
                $pricingTier = 'Access denied'
                $rowStatus   = 'Investigate'
            }
            else {
                $pricingTier = 'Error'
                $rowStatus   = 'Investigate'
            }
            Write-PSFMessage "Error querying Defender for AI Services plan for subscription '$displayName' ($subscriptionId): $_" -Tag Test -Level Warning
        }

        $evaluationResults += [PSCustomObject]@{
            SubscriptionId = $subscriptionId
            DisplayName    = $displayName
            AiAccountCount = $aiAccountCount
            PricingTier    = $pricingTier
            RowStatus      = $rowStatus
        }
    }

    #endregion Data Collection

    #region Assessment Logic

    $failedItems      = @($evaluationResults | Where-Object { $_.RowStatus -eq 'Fail' })
    $investigateItems = @($evaluationResults | Where-Object { $_.RowStatus -eq 'Investigate' })

    # Pass requires every in-scope subscription to have pricingTier == 'Standard'
    # Any Fail or Investigate subscription results in a non-pass overall outcome
    $passed = ($failedItems.Count -eq 0) -and ($investigateItems.Count -eq 0)

    if ($investigateItems.Count -gt 0 -and $failedItems.Count -eq 0) {
        $testResultMarkdown = "⚠️ Some of the queried resources returned status indicating not sufficient permissions. Please check you have at least reader access to the Azure Subscriptions being tested.`n`n%TestResult%"
    }
    elseif ($passed) {
        $testResultMarkdown = "✅ Microsoft Defender for AI Services is enabled on every Azure subscription that hosts Azure OpenAI or Azure AI Services accounts.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "❌ One or more Azure subscriptions host Azure OpenAI or Azure AI Services accounts without Microsoft Defender for AI Services enabled. Those subscriptions emit no AI threat alerts.`n`n%TestResult%"
    }

    #endregion Assessment Logic

    #region Report Generation

    $portalDefenderLink         = 'https://portal.azure.com/#view/Microsoft_Azure_Security/SecurityMenuBlade/~/EnvironmentSettings'
    $portalSubPricingBaseLink    = 'https://portal.azure.com/#view/Microsoft_Azure_Security/PolicyMenuBlade/~/pricingTier/subscriptionId'
    $tableTitle = 'Defender for Cloud — Environment settings'

    $formatTemplate = @'


## [{0}]({1})

| Subscription | AI accounts in subscription | Defender for AI Services plan | Status |
| :----------- | :-------------------------- | :---------------------------- | :----- |
{2}
'@

    $tableRows      = ''
    $maxDisplay     = 10
    $displayResults = @($evaluationResults | Sort-Object DisplayName)
    $hasMoreItems   = $false
    if ($evaluationResults.Count -gt $maxDisplay) {
        $displayResults = @($evaluationResults | Select-Object -First $maxDisplay)
        $hasMoreItems   = $true
    }

    foreach ($result in $displayResults) {
        $subscriptionLink = "[$(Get-SafeMarkdown $result.DisplayName)]($portalSubPricingBaseLink/$($result.SubscriptionId))"
        $planDisplay      = $result.PricingTier
        $statusDisplay    = switch ($result.RowStatus) {
            'Pass'        { '✅ Pass' }
            'Fail'        { '❌ Fail' }
            'Investigate' { '⚠️ Investigate' }
        }
        $tableRows += "| $subscriptionLink | $($result.AiAccountCount) | $planDisplay | $statusDisplay |`n"
    }

    if ($hasMoreItems) {
        $remainingCount = $evaluationResults.Count - $maxDisplay
        $tableRows += "`n... and $remainingCount more. [View all in Defender for Cloud — Environment settings]($portalDefenderLink)`n"
    }

    $mdInfo = $formatTemplate -f $tableTitle, $portalDefenderLink, $tableRows

    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo

    #endregion Report Generation

    $params = @{
        TestId = '61022'
        Title  = 'Microsoft Defender for AI Services is enabled on every Azure subscription that hosts Azure OpenAI or Azure AI Services accounts'
        Status = $passed
        Result = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
