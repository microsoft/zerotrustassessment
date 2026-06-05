<#
.SYNOPSIS
    Microsoft Entra ID Protection risk events are flowing to the Microsoft Sentinel workspace.

.DESCRIPTION
    Verifies that Microsoft Entra ID Protection risk-event categories (RiskyAgents and
    AgentRiskEvents) are flowing into at least one Sentinel-onboarded Log Analytics workspace
    via a tenant-scoped Microsoft Entra diagnostic setting that targets the workspace.
    Configuring this diagnostic setting auto-enables the Microsoft Entra ID data connector
    (and Content Hub solution) inside Sentinel for the targeted workspace.

    Evaluation steps:
      1. Enumerate Sentinel-onboarded Log Analytics workspaces (Q1 + Q2) via the shared
         helper Get-SentinelWorkspaceData. Workspaces whose Sentinel onboarding check
         returned 401/403 are surfaced via PermissionError=$true and treated as unknown.
      2. Read tenant-scoped Microsoft Entra diagnostic settings once (Q3).
      3. For each Sentinel-onboarded workspace, union enabled categories across all
         diagnostic settings whose properties.workspaceId matches the workspace ARM id,
         and require both 'RiskyAgents' and 'AgentRiskEvents' to be enabled.
      4. Pass if at least one Sentinel-onboarded workspace satisfies the criterion.

.NOTES
    Test ID: 61016
    Workshop Task: AI_089
    Pillar: AI
    Category: AI Threat Detection
#>

function Test-Assessment-61016 {
    [ZtTest(
        Category = 'AI Threat Detection',
        ImplementationCost = 'Low',
        Service = ('Azure'),
        CompatibleLicense = ('AAD_PREMIUM_P2', 'AGENT_365'),
        Pillar = 'AI',
        RiskLevel = 'High',
        SfiPillar = 'Monitor and detect cyberthreats',
        TenantType = ('Workforce'),
        TestId = 61016,
        Title = 'Microsoft Entra ID Protection risk events are flowing to the Microsoft Sentinel workspace',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    if ( -not (Get-ZtLicense EntraIDP2) ) {
        Add-ZtTestResultDetail -SkippedBecause NotLicensedEntraIDP2
        return
    }

    $activity = 'Checking Microsoft Entra ID Protection risk events flowing to Sentinel workspaces'
    $testTitle = 'Microsoft Entra ID Protection risk events are flowing to the Microsoft Sentinel workspace'
    $requiredCategories = @('RiskyAgents', 'AgentRiskEvents')
    $insufficientPermissionsMessage = '⚠️ Some of the queried resources returned status indicating insufficient permissions. Please make sure you have at least reader access to the Azure subscriptions being tested and the Security Reader or Global Reader directory role for the tenant-scope diagnostic-settings read.'

    # Tracks Investigate path; when set, the final emit reports Investigate without running the per-workspace evaluation.
    $investigateReason = $null
    # Tracks the 61002 precondition Fail path (no Sentinel-onboarded workspace can exist in scope).
    $noSentinelWorkspace = $false
    $diagnosticSettings = @()

    # Q1 + Q2: enumerate Log Analytics workspaces and their Sentinel onboarding state via shared helper.
    # 'Forbidden'       => 401/403 on Q1 or Q2 ARG query (Investigate).
    # $null             => unexpected ARG failure (Skip - NotApplicable).
    # 'NoSubscriptions' => Q1 succeeded but no enabled subscriptions accessible (Fail - no Sentinel workspace can exist).
    # 'NoWorkspaces'    => Q2 succeeded but no Log Analytics workspaces in scope (Fail - no Sentinel workspace can exist).
    # array             => workspace results; entries with PermissionError=$true had a 401/403
    #                      on the Sentinel onboarding check and must be treated as unknown.
    $workspaceResults = Get-SentinelWorkspaceData -Activity $activity

    if ($workspaceResults -eq 'Forbidden') {
        $investigateReason = $insufficientPermissionsMessage
    }
    elseif ($null -eq $workspaceResults) {
        # Unexpected ARG failure (transient infrastructure issue), not a missing capability.
        # NotApplicable (not NotSupported): NotSupported implies the capability doesn't exist
        # for the tenant, whereas this is a transient infrastructure failure. Per reviewer
        # feedback on the sibling 61015 PR for this same shared surface.
        Add-ZtTestResultDetail -SkippedBecause NotApplicable
        return
    }
    # NOTE: 61016 intentionally diverges from peer 61002 here. 61002 treats no-subscriptions /
    # no-workspaces as a Skip (NotApplicable); 61016 treats them as Fail, because the spec's
    # 61002 precondition says "if 61002 returned Fail, short-circuit to Fail" and the Fail copy
    # is "no workspaces are onboarded to Sentinel". Do not change these to skips.
    elseif ($workspaceResults -eq 'NoSubscriptions') {
        # Precondition (61002): no accessible subscriptions -> no Sentinel-onboarded workspace can exist -> Fail.
        Write-PSFMessage 'No enabled subscriptions found - no Sentinel-onboarded workspace can exist.' -Tag Test -Level VeryVerbose
        $noSentinelWorkspace = $true
    }
    elseif ($workspaceResults -eq 'NoWorkspaces') {
        # Precondition (61002): no Log Analytics workspaces -> no Sentinel-onboarded workspace can exist -> Fail.
        Write-PSFMessage 'No Log Analytics workspaces found across accessible subscriptions - no Sentinel-onboarded workspace can exist.' -Tag Test -Level VeryVerbose
        $noSentinelWorkspace = $true
    }
    else {
        # Q3: tenant-scoped Microsoft Entra diagnostic settings (single call).
        Write-ZtProgress -Activity $activity -Status 'Querying Microsoft Entra diagnostic settings (tenant scope)'
        try {
            $diagResponse = Invoke-ZtAzureRequest -Path '/providers/microsoft.aadiam/diagnosticsettings?api-version=2017-04-01-preview' -FullResponse -ErrorAction Stop
            if ($diagResponse.StatusCode -in 401, 403) {
                # Spec: 401/403 -> Investigate (insufficient directory-role permissions).
                $investigateReason = $insufficientPermissionsMessage
            }
            elseif ($diagResponse.StatusCode -ge 500) {
                # Spec: 5xx -> Investigate (transient ARM/aadiam failure, retry recommended).
                Write-PSFMessage "Microsoft Entra diagnostic settings query failed with status $($diagResponse.StatusCode)." -Tag Test -Level Warning
                $investigateReason = "⚠️ Microsoft Entra diagnostic settings query returned a server error ($($diagResponse.StatusCode)). Please retry."
            }
            elseif ($diagResponse.StatusCode -ge 400) {
                Write-PSFMessage "Microsoft Entra diagnostic settings query failed with status $($diagResponse.StatusCode)." -Tag Test -Level Warning
                $investigateReason = "⚠️ Microsoft Entra diagnostic settings query returned an unexpected status ($($diagResponse.StatusCode))."
            }
            else {
                $diagnosticSettings = @(($diagResponse.Content | ConvertFrom-Json).value)
            }
        }
        catch {
            Write-PSFMessage "Failed to query Microsoft Entra diagnostic settings: $_" -Tag Test -Level Warning -ErrorRecord $_
            $investigateReason = '⚠️ Microsoft Entra diagnostic settings query failed. Please retry or investigate tenant-scope access.'
        }
    }
    #endregion Data Collection

    #region Assessment Logic
    $sentinelWorkspaces = @()
    $forbiddenWorkspaces = @()
    $perWorkspace = @()
    $passingWorkspaces = @()

    if (-not $investigateReason -and -not $noSentinelWorkspace) {
        $forbiddenWorkspaces = @($workspaceResults | Where-Object { $_.PermissionError })
        $sentinelWorkspaces  = @($workspaceResults | Where-Object { -not $_.PermissionError -and $_.SentinelOnboarded })

        # If no Sentinel-onboarded workspace was confirmed AND some workspaces could not be
        # checked due to permission errors, we cannot rule out coverage -> Investigate.
        if ($sentinelWorkspaces.Count -eq 0 -and $forbiddenWorkspaces.Count -gt 0) {
            $investigateReason = '⚠️ All Log Analytics workspaces returned insufficient permissions when checking Sentinel onboarding state. Please ensure Microsoft Sentinel Reader is granted on each workspace and re-run the assessment.'
        }
        elseif ($sentinelWorkspaces.Count -eq 0) {
            # Precondition (61002): no Sentinel-onboarded workspace -> Fail per spec.
            $noSentinelWorkspace = $true
        }
    }

    if (-not $investigateReason -and -not $noSentinelWorkspace) {
        Write-ZtProgress -Activity $activity -Status 'Evaluating diagnostic-setting coverage per workspace'

        # Per workspace, union enabled categories across all diagnostic settings whose
        # properties.workspaceId matches the workspace ARM id (case-insensitive).
        $perWorkspace = foreach ($workspace in $sentinelWorkspaces) {
            $matchingSettings = @($diagnosticSettings | Where-Object {
                $_.properties.workspaceId -and
                ([string]$_.properties.workspaceId).Trim().ToLowerInvariant() -eq ([string]$workspace.WorkspaceId).Trim().ToLowerInvariant()
            })

            $enabledCategories = @(
                $matchingSettings |
                    ForEach-Object { $_.properties.logs } |
                    Where-Object { $_.enabled -eq $true } |
                    Select-Object -ExpandProperty category -Unique
            )

            $missingCategories = @($requiredCategories | Where-Object { $_ -notin $enabledCategories })
            $hasDiagnosticSetting = $matchingSettings.Count -gt 0
            $workspacePassed = $hasDiagnosticSetting -and ($missingCategories.Count -eq 0)

            [PSCustomObject]@{
                SubscriptionName     = $workspace.SubscriptionName
                SubscriptionId       = $workspace.SubscriptionId
                WorkspaceName        = $workspace.WorkspaceName
                ResourceGroup        = $workspace.ResourceGroup
                WorkspaceId          = $workspace.WorkspaceId
                HasDiagnosticSetting = $hasDiagnosticSetting
                EnabledCategories    = $enabledCategories
                MissingCategories    = $missingCategories
                Passed               = $workspacePassed
            }
        }

        $passingWorkspaces = @($perWorkspace | Where-Object { $_.Passed })
    }

    $passed = (-not $investigateReason) -and (-not $noSentinelWorkspace) -and ($passingWorkspaces.Count -ge 1)
    #endregion Assessment Logic

    #region Report Generation
    if ($investigateReason) {
        $testResultMarkdown = $investigateReason
    }
    elseif ($noSentinelWorkspace) {
        $testResultMarkdown = "❌ No Sentinel-onboarded workspace in tenant.`n`nNo Log Analytics workspace in scope is onboarded to Microsoft Sentinel, so Microsoft Entra ID Protection risk events have nowhere to flow."
    }
    elseif ($passed) {
        $testResultMarkdown = "✅ Microsoft Entra ID Protection risk events (``RiskyAgents`` / ``AgentRiskEvents``) are configured to flow to at least one Sentinel-onboarded workspace — a tenant Entra diagnostic setting targets the workspace with both risk-event log categories enabled (which automatically enables the Sentinel connector and the Microsoft Entra ID Content Hub solution).`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "❌ No Sentinel-onboarded workspace has a tenant-scoped Microsoft Entra diagnostic setting targeting it with both ``RiskyAgents`` and ``AgentRiskEvents`` log categories enabled.`n`n%TestResult%"
    }

    $reportPortalUrl = 'https://portal.azure.com/#view/HubsExtension/BrowseResource/resourceType/microsoft.securityinsightsarg%2Fsentinel'
    $workspacePortalTemplate = 'https://portal.azure.com/#resource{0}/overview'
    $subscriptionPortalTemplate = 'https://portal.azure.com/#resource/subscriptions/{0}/overview'

    # Spec output: one row per (workspace, required category). Workspace passes only when both rows pass.
    $categoryTableMap = [ordered]@{
        'RiskyAgents'     = 'AADRiskyAgents'
        'AgentRiskEvents' = 'AADAgentRiskEvents'
    }

    $tableRows = ''
    $maxWorkspacesToDisplay = 10
    # Sort failing workspaces first so they aren't truncated away; truncate by workspace so each workspace keeps both category rows together.
    $statusPriority = @{ $false = 0; $true = 1 }
    $displayWorkspaces = @($perWorkspace | Sort-Object { $statusPriority[[bool]$_.Passed] }, WorkspaceName)
    $hasMoreItems = $false
    if ($displayWorkspaces.Count -gt $maxWorkspacesToDisplay) {
        $displayWorkspaces = @($displayWorkspaces | Select-Object -First $maxWorkspacesToDisplay)
        $hasMoreItems = $true
    }

    foreach ($entry in $displayWorkspaces) {
        $subscriptionName = Get-SafeMarkdown -Text $entry.SubscriptionName
        $workspaceName = Get-SafeMarkdown -Text $entry.WorkspaceName
        $workspaceLink = "[$workspaceName]($($workspacePortalTemplate -f $entry.WorkspaceId))"

        $subscriptionLink = $subscriptionName
        if ($entry.SubscriptionId) {
            $subscriptionLink = "[$subscriptionName]($($subscriptionPortalTemplate -f $entry.SubscriptionId))"
        }

        foreach ($category in $categoryTableMap.Keys) {
            $tableName = $categoryTableMap[$category]
            $categoryLabel = "``$category`` (table ``$tableName``)"

            if (-not $entry.HasDiagnosticSetting) {
                $enabledLabel = '❌ Diagnostic setting missing'
                $statusLabel = '❌ Fail'
            }
            elseif ($category -in $entry.EnabledCategories) {
                $enabledLabel = '✅ Yes'
                $statusLabel = '✅ Pass'
            }
            else {
                $enabledLabel = '❌ No'
                $statusLabel = '❌ Fail'
            }

            $tableRows += "| $subscriptionLink | $workspaceLink | $categoryLabel | $enabledLabel | $statusLabel |`n"
        }
    }

    if ($hasMoreItems) {
        $remainingCount = $perWorkspace.Count - $maxWorkspacesToDisplay
        $tableRows += "`n... and $remainingCount more workspace(s). [View all in Microsoft Sentinel]($reportPortalUrl)`n"
    }

    $formatTemplate = @'


#### [Sentinel Entra ID Protection coverage per workspace]({0})

| Subscription | Workspace | Required risk-event category | Enabled | Status |
| :----------- | :-------- | :--------------------------- | :------ | :----- |
{1}

**Summary:**

- Sentinel-onboarded workspaces: {2}
- Workspaces with both ``RiskyAgents`` and ``AgentRiskEvents`` enabled via Entra diagnostic setting: {3}
- Workspaces skipped (insufficient permissions on Sentinel onboarding check): {4}
{5}

'@

    if (-not $investigateReason -and -not $noSentinelWorkspace) {
        $partialWarning = ''
        if ($forbiddenWorkspaces.Count -gt 0) {
            $partialWarning = "`n> ⚠️ **$($forbiddenWorkspaces.Count) workspace(s) could not be checked** for Sentinel onboarding due to insufficient permissions. Coverage for those workspaces is unknown."
        }
        $mdInfo = $formatTemplate -f $reportPortalUrl, $tableRows, $sentinelWorkspaces.Count, $passingWorkspaces.Count, $forbiddenWorkspaces.Count, $partialWarning
        $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    }
    #endregion Report Generation

    $params = @{
        TestId = '61016'
        Title  = $testTitle
        Status = $passed
        Result = $testResultMarkdown
    }

    if ($investigateReason) {
        $params.CustomStatus = 'Investigate'
    }

    Add-ZtTestResultDetail @params
}
