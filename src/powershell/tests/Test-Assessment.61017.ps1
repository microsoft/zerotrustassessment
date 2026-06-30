<#
.SYNOPSIS
    Microsoft Defender for AI Services alerts are flowing to the Microsoft Sentinel workspace via a single connector path.

.DESCRIPTION
    Checks that the Defender for AI Services plan is enabled on at least one subscription containing
    Azure OpenAI or Azure AI Services accounts, and that exactly one alert-forwarding path is
    configured on a Sentinel-onboarded workspace. Multiple simultaneous paths (ARM connectors +
    Content Hub packages) produce duplicate incidents and are surfaced as Investigate.

.NOTES
    Test ID: 61017
    Workshop Task: AI_089
    Pillar: AI
    Category: AI Threat Detection
    Required APIs:
        Azure Resource Graph (resourcecontainers, resources)
        Azure Management REST (Microsoft.Security/pricings,
            Microsoft.SecurityInsights/dataConnectors,
            Microsoft.SecurityInsights/alertRules,
            Microsoft.SecurityInsights/contentPackages)
#>

function Test-Assessment-61017 {
    [ZtTest(
        Category = 'AI Threat Detection',
        ImplementationCost = 'Low',
        Service = ('Azure'),
        MinimumLicense = ('Microsoft_Defender_for_AI_Services', 'Consumption-based: Microsoft Sentinel'),
        Pillar = 'AI',
        RiskLevel = 'High',
        SfiPillar = 'Monitor and detect cyberthreats',
        TenantType = ('Workforce'),
        TestId = 61017,
        Title = 'Microsoft Defender for AI Services alerts are flowing to the Microsoft Sentinel workspace via a single connector path',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose
    $activity = 'Checking Defender for AI Services alert flow to Sentinel workspace'

    # Q1 + Q2 + Sentinel onboarding check via shared helper.
    # Returns 'Forbidden' on ARG 401/403, $null on unexpected failure,
    # 'NoSubscriptions' / 'NoWorkspaces' when nothing is in scope.
    $allWorkspaces = Get-SentinelWorkspaceData -Activity $activity

    if ($null -eq $allWorkspaces) {
        $params = @{
            TestId       = '61017'
            Title        = 'Microsoft Defender for AI Services alerts are flowing to the Microsoft Sentinel workspace via a single connector path'
            Status       = $false
            Result       = '⚠️ Azure Resource Graph returned an unexpected error while querying subscriptions or Log Analytics workspaces. This is likely a transient issue, please re-run the assessment.'
            CustomStatus = 'Investigate'
        }
        Add-ZtTestResultDetail @params
        return
    }
    if ($allWorkspaces -eq 'Forbidden') {
        $params = @{
            TestId       = '61017'
            Title        = 'Microsoft Defender for AI Services alerts are flowing to the Microsoft Sentinel workspace via a single connector path'
            Status       = $false
            Result       = '⚠️ Azure Resource Graph returned insufficient permissions when querying subscriptions or workspaces. Ensure you have at least Reader access to the Azure subscriptions being tested.'
            CustomStatus = 'Investigate'
        }
        Add-ZtTestResultDetail @params
        return
    }

    if ($allWorkspaces -eq 'NoSubscriptions') {
        Write-PSFMessage 'No enabled subscriptions found — skipping Defender for AI Services alert flow check.' -Tag Test -Level VeryVerbose
        Add-ZtTestResultDetail -SkippedBecause NotApplicable
        return
    }

    if ($allWorkspaces -eq 'NoWorkspaces') {
        Write-PSFMessage 'No Log Analytics workspaces found across accessible subscriptions — skipping Defender for AI Services alert flow check.' -Tag Test -Level VeryVerbose
        Add-ZtTestResultDetail -SkippedBecause NotApplicable
        return
    }

    $checkableWorkspaces = @($allWorkspaces | Where-Object { -not $_.PermissionError })
    $forbiddenWorkspaces = @($allWorkspaces | Where-Object { $_.PermissionError })
    $onboardedWorkspaces = @($checkableWorkspaces | Where-Object { $_.SentinelOnboarded })

    if ($onboardedWorkspaces.Count -eq 0) {
        if ($forbiddenWorkspaces.Count -gt 0) {
            # Auth errors mean we cannot confirm whether those workspaces are onboarded —
            # we cannot rule out a passing workspace exists.
            $params = @{
                TestId       = '61017'
                Title        = 'Microsoft Defender for AI Services alerts are flowing to the Microsoft Sentinel workspace via a single connector path'
                Status       = $false
                Result       = '⚠️ One or more Log Analytics workspaces returned insufficient permissions when checking Sentinel onboarding state. No Sentinel-onboarded workspace was confirmed among accessible workspaces — the overall state cannot be determined. Ensure Microsoft Sentinel Reader is granted on all workspaces and re-run the assessment.'
                CustomStatus = 'Investigate'
            }
        }
        else {
            $params = @{
                TestId = '61017'
                Title  = 'Microsoft Defender for AI Services alerts are flowing to the Microsoft Sentinel workspace via a single connector path'
                Status = $false
                Result = '❌ No Sentinel-onboarded workspace in tenant.'
            }
        }
        Add-ZtTestResultDetail @params
        return
    }

    # Q3: Enumerate Azure OpenAI / Azure AI Services accounts with subscription display names.
    Write-ZtProgress -Activity $activity -Status 'Querying Azure OpenAI and Azure AI Services accounts via Resource Graph'

    $argAiAccountQuery = @"
resources
| where type =~ 'Microsoft.CognitiveServices/accounts'
| where kind in ('OpenAI', 'AIServices')
| project id, name, subscriptionId
| join kind=leftouter (
    resourcecontainers
    | where type =~ 'microsoft.resources/subscriptions'
    | where properties.state =~ 'Enabled'
    | project subscriptionId, subscriptionDisplayName=name
) on subscriptionId
| project id, name, subscriptionId, subscriptionDisplayName
"@

    $allAiAccounts = @()
    try {
        $allAiAccounts = @(Invoke-ZtAzureResourceGraphRequest -Query $argAiAccountQuery)
        Write-PSFMessage "Q3 returned $($allAiAccounts.Count) Azure OpenAI / Azure AI Services account(s)." -Tag Test -Level VeryVerbose
    }
    catch {
        Write-PSFMessage "Azure Resource Graph query for AI accounts failed: $($_.Exception.Message)" -Tag Test -Level Warning
        Add-ZtTestResultDetail -SkippedBecause NotSupported
        return
    }

    # No AI accounts in scope — nothing for Defender for AI Services to protect.
    if ($allAiAccounts.Count -eq 0) {
        Write-PSFMessage 'No Azure OpenAI or Azure AI Services accounts found — skipping.' -Tag Test -Level VeryVerbose
        Add-ZtTestResultDetail -SkippedBecause NotApplicable
        return
    }

    # Build per-subscription AI account info from combined ARG results.
    $inScopeSubscriptionIds = @($allAiAccounts | Select-Object -ExpandProperty subscriptionId -Unique)
    $subInfoBySubscription = @{}
    foreach ($account in $allAiAccounts) {
        $subId = $account.subscriptionId
        if (-not $subInfoBySubscription.ContainsKey($subId)) {
            $subInfoBySubscription[$subId] = @{
                DisplayName    = if ($account.subscriptionDisplayName) { $account.subscriptionDisplayName } else { $subId }
                AiAccountCount = 0
            }
        }
        $subInfoBySubscription[$subId].AiAccountCount++
    }

    # Q4: Read the Defender for AI Services pricing plan for each in-scope subscription.
    Write-ZtProgress -Activity $activity -Status 'Querying Defender for AI Services plan per subscription'

    $subscriptionResults = @()
    foreach ($subscriptionId in $inScopeSubscriptionIds) {
        $displayName    = $subInfoBySubscription[$subscriptionId].DisplayName
        $aiAccountCount = $subInfoBySubscription[$subscriptionId].AiAccountCount
        $pricingTier    = 'Not configured'
        $subRowStatus   = 'Fail'

        $pricingPath = "/subscriptions/$subscriptionId/providers/Microsoft.Security/pricings/AI?api-version=2024-01-01"
        try {
            $pricingResponse = Invoke-ZtAzureRequest -Path $pricingPath
            if ($null -ne $pricingResponse -and $null -ne $pricingResponse.properties.pricingTier) {
                $pricingTier  = $pricingResponse.properties.pricingTier
                $subRowStatus = if ($pricingTier -eq 'Standard') { 'Pass' } else { 'Fail' }
            }
        }
        catch {
            $httpStatusCode = $null
            if ($_.Exception.Message -match 'with status (\d+):') {
                $httpStatusCode = [int]$Matches[1]
            }
            if ($httpStatusCode -eq 404) {
                # 404 means the AI plan has never been configured; treat as Fail per spec.
                $pricingTier  = 'Not configured'
                $subRowStatus = 'Fail'
            }
            elseif ($httpStatusCode -in @(401, 403)) {
                $pricingTier  = 'Access denied'
                $subRowStatus = 'Investigate'
            }
            else {
                $pricingTier  = 'Error'
                $subRowStatus = 'Investigate'
            }
            Write-PSFMessage "Error querying Defender for AI Services plan for '$displayName' ($subscriptionId): $_" -Tag Test -Level Warning
        }

        $subscriptionResults += [PSCustomObject]@{
            SubscriptionId = $subscriptionId
            DisplayName    = $displayName
            AiAccountCount = $aiAccountCount
            PricingTier    = $pricingTier
            SubRowStatus   = $subRowStatus
        }
    }

    # Q5, Q6, Q7: Data connectors, alert rules, and content packages per onboarded workspace.
    $workspacePathResults = @()

    foreach ($workspace in $onboardedWorkspaces) {
        Write-ZtProgress -Activity $activity -Status "Checking connectors, alert rules, and content packages on $($workspace.WorkspaceName) in $($workspace.SubscriptionName)"

        $connectors  = @()
        $alertRules  = @()
        $packages    = @()
        $queryError  = $false

        $connectorsPath = "$($workspace.WorkspaceId)/providers/Microsoft.SecurityInsights/dataConnectors?api-version=2024-09-01"
        $alertRulesPath = "$($workspace.WorkspaceId)/providers/Microsoft.SecurityInsights/alertRules?api-version=2024-09-01"
        $packagesPath   = "$($workspace.WorkspaceId)/providers/Microsoft.SecurityInsights/contentPackages?api-version=2024-09-01"

        # Q5: data connectors (enumerate client-side; API does not support $filter on kind).
        try {
            $connectors = @(Invoke-ZtAzureRequest -Path $connectorsPath -ErrorAction Stop)
        }
        catch {
            $queryError = $true
            Write-PSFMessage "Error querying data connectors for '$($workspace.WorkspaceName)': $_" -Tag Test -Level Warning
        }

        # Q6: alert rules — filter client-side for MicrosoftSecurityIncidentCreation with Defender for Cloud product.
        try {
            $alertRules = @(Invoke-ZtAzureRequest -Path $alertRulesPath -ErrorAction Stop)
        }
        catch {
            $queryError = $true
            Write-PSFMessage "Error querying alert rules for '$($workspace.WorkspaceName)': $_" -Tag Test -Level Warning
        }

        # Q7: installed Content Hub solutions.
        try {
            $packages = @(Invoke-ZtAzureRequest -Path $packagesPath -ErrorAction Stop)
        }
        catch {
            $queryError = $true
            Write-PSFMessage "Error querying content packages for '$($workspace.WorkspaceName)': $_" -Tag Test -Level Warning
        }

        if ($queryError) {
            $workspacePathResults += [PSCustomObject]@{
                WorkspaceName     = $workspace.WorkspaceName
                WorkspaceId       = $workspace.WorkspaceId
                SubscriptionId    = $workspace.SubscriptionId
                ResourceGroup     = $workspace.ResourceGroup
                ActiveChannels    = @()
                PathStatus        = 'Error'
                AlertPathLabel    = 'Error'
                DuplicateWarning  = '⚠️ Unknown (query error)'
            }
            continue
        }

        # Determine active ARM connector channels.

        # Tenant-based MDC: kind begins with 'MicrosoftDefenderForCloud' (accept both
        # MicrosoftDefenderForCloud and MicrosoftDefenderForCloudTenant for API-version forward-compat).
        $tenantMDCConnector = $connectors | Where-Object { $_.kind -like 'MicrosoftDefenderForCloud*' } | Select-Object -First 1
        $tenantMDCActive    = $null -ne $tenantMDCConnector -and (
            $tenantMDCConnector.properties.dataTypes.PSObject.Properties |
                Where-Object { $_.Value.state -eq 'Enabled' }
        )

        # Subscription-based (Legacy) MDC: kind == 'AzureSecurityCenter'.
        $legacyMDCConnector = $connectors | Where-Object { $_.kind -eq 'AzureSecurityCenter' } | Select-Object -First 1
        $legacyMDCActive    = $null -ne $legacyMDCConnector -and (
            $legacyMDCConnector.properties.dataTypes.PSObject.Properties |
                Where-Object { $_.Value.state -eq 'Enabled' }
        )

        # Defender XDR connector: kind == 'MicrosoftThreatProtection'.
        $xdrConnector      = $connectors | Where-Object { $_.kind -eq 'MicrosoftThreatProtection' } | Select-Object -First 1
        $xdrConnectorActive = $null -ne $xdrConnector -and (
            $xdrConnector.properties.dataTypes.PSObject.Properties |
                Where-Object { $_.Value.state -eq 'Enabled' }
        )

        # Q6: Check whether the 'Create incidents based on Microsoft Defender for Cloud alerts'
        # Microsoft-security alert rule is enabled. This rule must be disabled when the XDR path
        # is used to avoid duplicate incidents.
        $msiCreationRuleEnabled = $null -ne (
            $alertRules | Where-Object {
                $_.kind -eq 'MicrosoftSecurityIncidentCreation' -and
                ($_.properties.productFilter -ieq 'Azure Security Center' -or $_.properties.productFilter -ieq 'Microsoft Defender for Cloud') -and
                $_.properties.enabled -eq $true
            } | Select-Object -First 1
        )

        # Content Hub packages (presence means installed; no separate state field).
        $mdcPackageInstalled = $null -ne ($packages | Where-Object { $_.properties.displayName -ieq 'Microsoft Defender for Cloud' } | Select-Object -First 1)
        $xdrPackageInstalled = $null -ne ($packages | Where-Object {
            $_.properties.displayName -ieq 'Microsoft Defender XDR' -or
            $_.properties.displayName -ieq 'Microsoft 365 Defender'
        } | Select-Object -First 1)

        # Count emitting channels — each active connector or installed content package that can
        # forward Defender for Cloud alerts. MSI creation rule + XDR connector together is an
        # additional implicit MDC path, so treat it as a duplicate even with only one connector.
        $activeChannels = @()
        if ($tenantMDCActive)    { $activeChannels += 'Tenant-based MDC (ARM)' }
        if ($legacyMDCActive)    { $activeChannels += 'Legacy MDC (ARM)' }
        if ($xdrConnectorActive) { $activeChannels += 'Defender XDR (ARM)' }
        if ($mdcPackageInstalled) { $activeChannels += 'MDC Content Pack' }
        if ($xdrPackageInstalled) { $activeChannels += 'XDR Content Pack' }

        # Duplicate emission: XDR connector or XDR Content Pack active with the MDC incident-creation
        # rule still enabled means alerts arrive through both the XDR stream and the MDC rule.
        $xdrMsiConflict = ($xdrConnectorActive -or $xdrPackageInstalled) -and $msiCreationRuleEnabled

        $isDuplicate    = $activeChannels.Count -gt 1 -or $xdrMsiConflict

        if ($activeChannels.Count -eq 0) {
            $pathStatus       = 'None'
            $alertPathLabel   = 'None'
            $duplicateWarning = '❌ No'
        }
        elseif ($isDuplicate) {
            $conflictDetail   = if ($xdrMsiConflict -and $activeChannels.Count -le 1) {
                "$($activeChannels[0]) + MDC incident creation rule (enabled)"
            } else {
                $activeChannels -join ', '
            }
            $pathStatus       = 'Duplicate'
            $alertPathLabel   = $activeChannels -join ', '
            $duplicateWarning = "⚠️ Yes ($conflictDetail)"
        }
        else {
            $pathStatus       = 'Clean'
            $alertPathLabel   = $activeChannels[0]
            $duplicateWarning = '✅ No'
        }

        $workspacePathResults += [PSCustomObject]@{
            WorkspaceName    = $workspace.WorkspaceName
            WorkspaceId      = $workspace.WorkspaceId
            SubscriptionId   = $workspace.SubscriptionId
            ResourceGroup    = $workspace.ResourceGroup
            ActiveChannels   = $activeChannels
            PathStatus       = $pathStatus
            AlertPathLabel   = $alertPathLabel
            DuplicateWarning = $duplicateWarning
        }
    }

    #endregion Data Collection

    #region Assessment Logic

    # Half A: Defender for AI Services plan is Standard on at least one subscription
    # that contains Azure OpenAI / Azure AI Services accounts.
    $halfASubscriptions    = @($subscriptionResults | Where-Object { $_.SubRowStatus -eq 'Pass' })
    $halfAInvestigateItems = @($subscriptionResults | Where-Object { $_.SubRowStatus -eq 'Investigate' })
    $halfAPassed           = $halfASubscriptions.Count -gt 0
    $hasQ4InvestigateItems = $halfAInvestigateItems.Count -gt 0

    # Half B: exactly one alert path is active on at least one Sentinel-onboarded workspace.
    $workspacesWithCleanPath    = @($workspacePathResults | Where-Object { $_.PathStatus -eq 'Clean' })
    $workspacesWithDuplicate    = @($workspacePathResults | Where-Object { $_.PathStatus -eq 'Duplicate' })
    $workspacesWithQueryError   = @($workspacePathResults | Where-Object { $_.PathStatus -eq 'Error' })
    $halfBPassed                = $workspacesWithCleanPath.Count -gt 0

    $hasDuplicateEmission = $workspacesWithDuplicate.Count -gt 0
    $hasQueryErrors       = $workspacesWithQueryError.Count -gt 0

    # Determine overall outcome.
    # Duplicate emission overrides Pass — the customer must reduce to one path first.
    $passed       = $false
    $customStatus = $null

    if ($hasDuplicateEmission) {
        $passed       = $false
        $customStatus = 'Investigate'
        $testResultMarkdown = "⚠️ Two or more alert paths are simultaneously forwarding Defender for Cloud alerts to a workspace. This produces duplicate alerts and incidents. Pick one path and disable the others.`n`n%TestResult%"
    }
    elseif ($hasQueryErrors -and -not $halfBPassed) {
        # Query errors prevent confirming Half B — surface as Investigate.
        $passed       = $false
        $customStatus = 'Investigate'
        $testResultMarkdown = "⚠️ The data connectors, alert rules, or content packages API returned an authorization (401/403) or transient (5xx) error on at least one workspace, so the alert path state could not be fully determined. Re-run after verifying Microsoft Sentinel Reader on each affected workspace's resource group.`n`n%TestResult%"
    }
    elseif ($halfAPassed -and $halfBPassed) {
        $passed             = $true
        $testResultMarkdown = "✅ Microsoft Defender for AI Services is enabled on at least one subscription with Azure OpenAI or Azure AI Services accounts, and exactly one alert path is forwarding alerts to a Sentinel-onboarded workspace.`n`n%TestResult%"
    }
    elseif ($hasQ4InvestigateItems -and -not $halfAPassed) {
        # Q4 auth/transport errors prevented confirming Half A — surface as Investigate per spec.
        $passed       = $false
        $customStatus = 'Investigate'
        $testResultMarkdown = "⚠️ The Defender for AI Services pricing API returned an authorization (401/403) or transient error on at least one subscription, so the plan state could not be fully determined. Ensure Security Reader is granted on each in-scope subscription and re-run the assessment.`n`n%TestResult%"
    }
    elseif (-not $halfAPassed) {
        $testResultMarkdown = "❌ The Defender for AI Services plan is not enabled on any subscription with AI accounts, or no alert path is configured, or the Sentinel onboarding check failed.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "❌ The Defender for AI Services plan is enabled, but no valid alert-forwarding path is configured on a Sentinel-onboarded workspace.`n`n%TestResult%"
    }

    # Determine the tenant-level alert path label and duplicate warning for display in the table.
    # Use the first clean workspace, falling back to the first duplicate, for the path column.
    $firstCleanWorkspace     = $workspacesWithCleanPath | Select-Object -First 1
    $firstDuplicateWorkspace = $workspacesWithDuplicate | Select-Object -First 1

    if ($firstCleanWorkspace) {
        $tenantAlertPathLabel   = $firstCleanWorkspace.AlertPathLabel
        $tenantDuplicateWarning = '✅ No'
    }
    elseif ($firstDuplicateWorkspace) {
        $tenantAlertPathLabel   = $firstDuplicateWorkspace.AlertPathLabel
        $tenantDuplicateWarning = $firstDuplicateWorkspace.DuplicateWarning
    }
    else {
        $tenantAlertPathLabel   = 'None'
        $tenantDuplicateWarning = '❌ No'
    }

    # Apply workspace-level duplicate warning to tenant display if any workspace has duplicates.
    if ($hasDuplicateEmission) {
        $tenantDuplicateWarning = $firstDuplicateWorkspace.DuplicateWarning
    }

    #endregion Assessment Logic

    #region Report Generation

    $portalDefenderLink = 'https://portal.azure.com/#view/Microsoft_Azure_Security/SecurityMenuBlade/~/EnvironmentSettings'
    $tableTitle         = 'Defender for AI Services plan and Sentinel alert path'

    $formatTemplate = @'


## [{0}]({1})

| Subscription | AI accounts in scope | Defender for AI Services plan | Alert path active | Duplicate path warning | Status |
| :----------- | :------------------- | :---------------------------- | :---------------- | :--------------------- | :----- |
{2}
'@

    $tableRows  = ''
    $maxDisplay = 10

    # Sort Fail/Investigate rows first, then by subscription name.
    $statusPriority = @{ Fail = 0; Investigate = 1; Pass = 2 }
    $sortedResults  = @($subscriptionResults | Sort-Object { $statusPriority[$_.SubRowStatus] }, DisplayName)

    $hasMoreItems = $false
    if ($subscriptionResults.Count -gt $maxDisplay) {
        $sortedResults = @($sortedResults | Select-Object -First $maxDisplay)
        $hasMoreItems  = $true
    }

    foreach ($result in $sortedResults) {
        $subPortalLink  = "https://portal.azure.com/#view/Microsoft_Azure_Security/PolicyMenuBlade/~/pricingTier/subscriptionId/$($result.SubscriptionId)"
        $subscriptionMd = "[$(Get-SafeMarkdown $result.DisplayName)]($subPortalLink)"
        $planDisplay    = Get-SafeMarkdown $result.PricingTier
        $alertPathMd    = Get-SafeMarkdown $tenantAlertPathLabel
        $duplicateMd    = $tenantDuplicateWarning

        # Per-row status: Pass if this subscription has Standard and Half B globally holds without duplicates.
        $rowStatus = switch ($result.SubRowStatus) {
            'Pass' {
                if ($hasDuplicateEmission) { '⚠️ Investigate' }
                elseif ($halfBPassed)      { '✅ Pass' }
                else                       { '❌ Fail' }
            }
            'Investigate' { '⚠️ Investigate' }
            default       { '❌ Fail' }
        }

        $tableRows += "| $subscriptionMd | $($result.AiAccountCount) | $planDisplay | $alertPathMd | $duplicateMd | $rowStatus |`n"
    }

    if ($hasMoreItems) {
        $remainingCount = $subscriptionResults.Count - $maxDisplay
        $tableRows += "`n... and $remainingCount more. [View all in Defender for Cloud — Environment settings]($portalDefenderLink)`n"
    }

    $mdInfo = $formatTemplate -f $tableTitle, $portalDefenderLink, $tableRows

    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo

    #endregion Report Generation

    $params = @{
        TestId = '61017'
        Title  = 'Microsoft Defender for AI Services alerts are flowing to the Microsoft Sentinel workspace via a single connector path'
        Status = $passed
        Result = $testResultMarkdown
    }
    if ($customStatus) {
        $params.CustomStatus = $customStatus
    }

    Add-ZtTestResultDetail @params
}
