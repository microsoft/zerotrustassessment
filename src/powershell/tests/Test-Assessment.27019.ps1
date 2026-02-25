<#
.SYNOPSIS
    Validates that JavaScript challenge is enabled in Azure Front Door WAF policies.

.DESCRIPTION
    This test evaluates Azure Front Door WAF policies across all subscriptions to verify
    that at least one custom rule with JavaScript challenge action (JSChallenge) is configured
    and enabled. Only policies attached to an Azure Front Door are evaluated.

.NOTES
    Test ID: 27019
    Category: Azure Network Security
    Required APIs: Azure Management REST API (subscriptions, Front Door WAF policies)
#>

function Test-Assessment-27019 {

    [ZtTest(
        Category = 'Azure Network Security',
        ImplementationCost = 'Low',
        MinimumLicense = ('Azure_WAF'),
        Pillar = 'Network',
        RiskLevel = 'Medium',
        SfiPillar = 'Protect networks',
        TenantType = ('Workforce'),
        TestId = 27019,
        Title = 'JavaScript Challenge is Enabled in Azure Front Door WAF',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose
    $activity = 'Checking Azure Front Door WAF JavaScript challenge configuration'

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

    # Step 1: List all subscriptions
    Write-ZtProgress -Activity $activity -Status 'Enumerating subscriptions'

    $subscriptions = @()
    try {
        $subscriptions = Get-AzSubscription -ErrorAction Stop
    }
    catch {
        Write-PSFMessage "Unable to retrieve Azure subscriptions: $_" -Level Warning
    }

    if ($subscriptions.Count -eq 0) {
        Write-PSFMessage 'No Azure subscriptions found.' -Level Warning
        Add-ZtTestResultDetail -SkippedBecause NoAzureAccess
        return
    }

    # Step 2: Collect Front Door WAF policies from all subscriptions
    $allPolicies = @()
    $anySuccessfulAccess = 0
    $apiVersion = '2025-03-01'

    foreach ($sub in $subscriptions) {
        Write-ZtProgress -Activity $activity -Status "Checking subscription: $($sub.Name)"

        $path = "/subscriptions/$($sub.Id)/providers/Microsoft.Network/FrontDoorWebApplicationFirewallPolicies?api-version=$apiVersion"
        $response = Invoke-AzRestMethod -Path $path -ErrorAction SilentlyContinue

        # Skip if request failed completely
        if (-not $response -or $null -eq $response.StatusCode) {
            Write-PSFMessage "Failed to query subscription '$($sub.Name)'. Skipping." -Level Warning
            continue
        }

        # Handle access denied - skip to next subscription
        if ($response.StatusCode -eq 403) {
            Write-PSFMessage "Access denied to subscription '$($sub.Name)': HTTP $($response.StatusCode). Skipping." -Level Verbose
            continue
        }

        # Handle other HTTP errors - skip this subscription
        if ($response.StatusCode -ge 400) {
            Write-PSFMessage "Error querying subscription '$($sub.Name)': HTTP $($response.StatusCode). Skipping." -Level Warning
            continue
        }

        $anySuccessfulAccess++

        if (-not $response.Content) {
            continue
        }

        $policiesJson = $response.Content | ConvertFrom-Json

        if (-not $policiesJson.value -or $policiesJson.value.Count -eq 0) {
            continue
        }

        foreach ($policy in $policiesJson.value) {
            $allPolicies += [PSCustomObject]@{
                SubscriptionId   = $sub.Id
                SubscriptionName = $sub.Name
                Policy           = $policy
            }
        }
    }

    # Skip if no accessible subscriptions
    if ($anySuccessfulAccess -eq 0) {
        Write-PSFMessage 'No accessible Azure subscriptions found.' -Level Warning
        Add-ZtTestResultDetail -SkippedBecause NoAzureAccess
        return
    }

    # Step 3: Filter to only policies attached to Azure Front Door and evaluate
    $evaluationResults = @()

    foreach ($item in $allPolicies) {
        $policy = $item.Policy
        $frontendLinks = $policy.properties.frontendEndpointLinks
        $securityPolicyLinks = $policy.properties.securityPolicyLinks

        # Exclude policies not attached to any Azure Front Door
        $isAttached = ($frontendLinks -and $frontendLinks.Count -gt 0) -or
                      ($securityPolicyLinks -and $securityPolicyLinks.Count -gt 0)

        if (-not $isAttached) {
            continue
        }

        # Evaluate JavaScript challenge rules
        $enabledState = $policy.properties.policySettings.enabledState
        $wafMode = $policy.properties.policySettings.mode
        $cookieExpiration = $policy.properties.policySettings.javascriptChallengeExpirationInMinutes
        $customRules = $policy.properties.customRules.rules

        $jsChallengeRules = @()
        if ($customRules) {
            $jsChallengeRules = @($customRules | Where-Object {
                $_.action -eq 'JSChallenge' -and $_.enabledState -eq 'Enabled'
            })
        }

        $jsChallengeCount = $jsChallengeRules.Count
        $hasJsChallenge = $jsChallengeCount -gt 0
        $cookieExpirationDisplay = if ($cookieExpiration) { $cookieExpiration.ToString() } else { 'N/A' }

        $status = if ($hasJsChallenge) { 'Pass' } else { 'Fail' }

        $evaluationResults += [PSCustomObject]@{
            SubscriptionId      = $item.SubscriptionId
            SubscriptionName    = $item.SubscriptionName
            PolicyName          = $policy.name
            PolicyId            = $policy.id
            AttachedToAFD       = 'Yes'
            EnabledState        = $enabledState
            WafMode             = $wafMode
            JSChallengeCount    = $jsChallengeCount
            CookieExpiration    = $cookieExpirationDisplay
            Status              = $status
        }
    }

    # Skip if no attached WAF policies found
    if ($evaluationResults.Count -eq 0) {
        Write-PSFMessage 'No Azure Front Door WAF policies attached to Azure Front Door found across subscriptions.' -Tag Test -Level Verbose
        Add-ZtTestResultDetail -SkippedBecause NotApplicable
        return
    }

    #endregion Data Collection

    #region Assessment Logic

    $passedItems = $evaluationResults | Where-Object { $_.Status -eq 'Pass' }
    $failedItems = $evaluationResults | Where-Object { $_.Status -eq 'Fail' }

    $passed = ($failedItems.Count -eq 0) -and ($passedItems.Count -gt 0)

    if ($passed) {
        $testResultMarkdown = "✅ All Azure Front Door WAF policies attached to Azure Front Door have at least one custom rule with JavaScript challenge action configured and enabled.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "❌ One or more Azure Front Door WAF policies attached to Azure Front Door do not have any JavaScript challenge rules configured, leaving applications without browser verification against automated bots at the global edge.`n`n%TestResult%"
    }

    #endregion Assessment Logic

    #region Report Generation

    $portalWafLink = 'https://portal.azure.com/#view/Microsoft_Azure_HybridNetworking/FirewallManagerMenuBlade/~/wafMenuItem'
    $portalResourceBaseLink = 'https://portal.azure.com/#resource'
    $portalSubscriptionBaseLink = 'https://portal.azure.com/#resource/subscriptions'

    $mdInfo = ''

    $reportTitle = 'Azure Front Door WAF Policies'
    $formatTemplate = @'


## [{0}]({1})

| Policy name | Subscription name | Attached to AFD | Enabled state | WAF mode | JS challenge rules count | Cookie expiration (mins) | Status |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
{2}

'@

    $tableRows = ''
    foreach ($result in $evaluationResults) {
        $policyLink = "[$(Get-SafeMarkdown $result.PolicyName)]($portalResourceBaseLink$($result.PolicyId))"
        $subLink = "[$(Get-SafeMarkdown $result.SubscriptionName)]($portalSubscriptionBaseLink/$($result.SubscriptionId)/overview)"
        $attachedDisplay = $result.AttachedToAFD
        $enabledStateDisplay = if ($result.EnabledState -eq 'Enabled') { '✅ Enabled' } else { '❌ Disabled' }
        $wafModeDisplay = if ($result.WafMode -eq 'Prevention') { 'Prevention' } else { 'Detection' }
        $jsChallengeCountDisplay = $result.JSChallengeCount
        $cookieExpirationDisplay = $result.CookieExpiration
        $statusText = if ($result.Status -eq 'Pass') { '✅ Pass' } else { '❌ Fail' }

        $tableRows += "| $policyLink | $subLink | $attachedDisplay | $enabledStateDisplay | $wafModeDisplay | $jsChallengeCountDisplay | $cookieExpirationDisplay | $statusText |`n"
    }

    $mdInfo = $formatTemplate -f $reportTitle, $portalWafLink, $tableRows.TrimEnd("`n")

    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo

    #endregion Report Generation

    $params = @{
        TestId = '27019'
        Title  = 'JavaScript Challenge is Enabled in Azure Front Door WAF'
        Status = $passed
        Result = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
