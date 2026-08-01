<#
.SYNOPSIS
    Checks that auditing and health monitoring is enabled for Microsoft Sentinel.

.DESCRIPTION
    Verifies that at least one Sentinel-onboarded Log Analytics workspace has an Azure Monitor
    diagnostic setting whose logs[] contains at least one entry with enabled == true and whose
    destination is a Log Analytics workspace (properties.workspaceId is non-empty).
    This is the documented mechanism for populating the SentinelAudit and SentinelHealth tables
    and for detecting detection-pipeline degradation and SOC tampering.

.NOTES
    Test ID: 41211
    Workshop Task: SECOPS_105
    Pillar: SecOps
    Category: Security information and event management
    Required API: Azure Resource Manager (management.azure.com), azure.insights diagnosticSettings
#>
function Test-Assessment-41211 {
    [ZtTest(
        Category = 'Security information and event management',
        ImplementationCost = 'Low',
        MinimumLicense = ('Consumption-based: Microsoft Sentinel'),
        Pillar = 'SecOps',
        RiskLevel = 'Medium',
        Service = ('Azure'),
        SfiPillar = 'Accelerate response and remediation',
        TenantType = ('Workforce'),
        TestId = 41211,
        Title = 'Auditing and health monitoring is enabled for Microsoft Sentinel',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose
    $activity = 'Checking Sentinel auditing and health monitoring diagnostic settings'

    # Q1 + Q2 + onboarding check delegated to the shared helper.
    # 'Forbidden'       → 401/403 on ARG subscription or workspace query (spec: Investigate).
    # $null             → unexpected ARG failure (spec: Investigate).
    # 'NoSubscriptions' → no enabled subscriptions accessible (spec: Skip).
    # 'NoWorkspaces'    → no Log Analytics workspaces found (spec: Skip).
    # array             → per-workspace results; PermissionError=$true means 401/403 on onboarding check.
    $allWorkspaces = Get-SentinelWorkspaceData -Activity $activity

    if ($null -eq $allWorkspaces) {
        $params = @{
            TestId       = '41211'
            Title        = 'Auditing and health monitoring is enabled for Microsoft Sentinel'
            Status       = $false
            Result       = '⚠️ Azure Resource Graph returned an unexpected error while querying subscriptions or Log Analytics workspaces. This is likely a transient issue, please re-run the assessment.'
            CustomStatus = 'Investigate'
        }
        Add-ZtTestResultDetail @params
        return
    }

    if ($allWorkspaces -eq 'Forbidden') {
        $params = @{
            TestId       = '41211'
            Title        = 'Auditing and health monitoring is enabled for Microsoft Sentinel'
            Status       = $false
            Result       = '⚠️ Azure Resource Graph returned insufficient permissions when querying subscriptions or workspaces. Ensure you have at least Reader access to the Azure subscriptions being tested.'
            CustomStatus = 'Investigate'
        }
        Add-ZtTestResultDetail @params
        return
    }

    if ($allWorkspaces -eq 'NoSubscriptions') {
        Write-PSFMessage 'No enabled subscriptions found — skipping Sentinel audit/health-monitoring check.' -Tag Test -Level VeryVerbose
        Add-ZtTestResultDetail -SkippedBecause NotApplicable
        return
    }

    if ($allWorkspaces -eq 'NoWorkspaces') {
        Write-PSFMessage 'No Log Analytics workspaces found across accessible subscriptions — skipping Sentinel audit/health-monitoring check.' -Tag Test -Level VeryVerbose
        Add-ZtTestResultDetail -SkippedBecause NotApplicable
        return
    }

    $checkableWorkspaces = @($allWorkspaces | Where-Object { -not $_.PermissionError })
    $forbiddenWorkspaces = @($allWorkspaces | Where-Object { $_.PermissionError })
    $onboardedWorkspaces = @($checkableWorkspaces | Where-Object { $_.SentinelOnboarded })

    if ($onboardedWorkspaces.Count -eq 0) {
        if ($forbiddenWorkspaces.Count -gt 0) {
            # Cannot confirm whether inaccessible workspaces have Sentinel onboarded.
            $params = @{
                TestId       = '41211'
                Title        = 'Auditing and health monitoring is enabled for Microsoft Sentinel'
                Status       = $false
                Result       = '⚠️ One or more Log Analytics workspaces returned insufficient permissions when checking Sentinel onboarding state. No Sentinel-onboarded workspace was confirmed among accessible workspaces — the overall state cannot be determined. Ensure Microsoft Sentinel Reader is granted on all workspaces and re-run the assessment.'
                CustomStatus = 'Investigate'
            }
            Add-ZtTestResultDetail @params
        }
        else {
            # Spec: no Sentinel-onboarded workspaces → Skipped.
            Write-PSFMessage 'No Sentinel-onboarded workspaces found — skipping Sentinel audit/health-monitoring check.' -Tag Test -Level VeryVerbose
            Add-ZtTestResultDetail -SkippedBecause NotApplicable
        }
        return
    }

    # Q1: For each Sentinel-onboarded workspace, retrieve the list of diagnostic settings.
    # A setting qualifies when logs[].enabled == true and properties.workspaceId is non-empty
    # (confirming routing to a Log Analytics workspace rather than Event Hub or Storage Account).
    $diagSettingsByWorkspace = @{}

    foreach ($workspace in $onboardedWorkspaces) {
        Write-ZtProgress -Activity $activity -Status "Fetching diagnostic settings for workspace '$($workspace.WorkspaceName)' in '$($workspace.SubscriptionName)'"
        $diagPath = "$($workspace.WorkspaceId)/providers/microsoft.insights/diagnosticSettings?api-version=2021-05-01-preview"

        try {
            $diagSettingsByWorkspace[$workspace.WorkspaceId] = @(Invoke-ZtAzureRequest -Path $diagPath -ErrorAction Stop)
        }
        catch {
            $diagSettingsByWorkspace[$workspace.WorkspaceId] = $null
            Write-PSFMessage "Diagnostic settings API call failed — cannot determine setting state for workspace '$($workspace.WorkspaceName)' in subscription '$($workspace.SubscriptionName)': $_" -Tag Test -Level Warning
        }
    }

    #endregion Data Collection

    #region Assessment Logic

    $workspaceResults = foreach ($workspace in $onboardedWorkspaces) {
        $diagSettings = $diagSettingsByWorkspace[$workspace.WorkspaceId]

        $totalSettingCount = $null
        $settingDetails    = @()
        $rowStatus         = 'Fail'

        if ($null -eq $diagSettings) {
            # Diagnostic settings API call failed — cannot determine setting state for this workspace.
            $rowStatus = 'Investigate'
        }
        elseif ($diagSettings.Count -eq 0) {
            # Q1 returned an empty collection — no diagnostic settings configured (spec: Fail).
            $totalSettingCount = 0
            $rowStatus = 'Fail'
        }
        else {
            $totalSettingCount = $diagSettings.Count

            # Build per-setting detail for display, preserving the category-to-destination
            # association for each diagnostic setting. Include categoryGroup (e.g. allLogs, audit)
            # as fallback for logs[].category — both are valid shapes for a log entry; a given
            # entry uses one or the other, never both simultaneously.
            $settingDetails = @(foreach ($setting in $diagSettings) {
                $enabledLogs = @($setting.properties.logs | Where-Object { $_.enabled -eq $true })
                $settingCats = @($enabledLogs | ForEach-Object {
                    if ($_.category) { $_.category } else { $_.categoryGroup }
                } | Where-Object { $_ })
                [PSCustomObject]@{
                    Name              = $setting.name
                    EnabledCategories = $settingCats
                    DestinationId     = $setting.properties.workspaceId
                }
            })

            # A qualifying setting has at least one logs[] entry with enabled == true
            # AND routes to a Log Analytics workspace (properties.workspaceId non-empty).
            $qualifyingSettings = @($diagSettings | Where-Object {
                ($_.properties.logs | Where-Object { $_.enabled -eq $true }).Count -gt 0 -and
                -not [string]::IsNullOrEmpty($_.properties.workspaceId)
            })

            # Settings with enabled logs but no LAW destination — cannot confirm the feature is on.
            $enabledLogsNoLaw = @($diagSettings | Where-Object {
                ($_.properties.logs | Where-Object { $_.enabled -eq $true }).Count -gt 0 -and
                [string]::IsNullOrEmpty($_.properties.workspaceId)
            })

            if ($qualifyingSettings.Count -gt 0) {
                $rowStatus = 'Pass'
            }
            elseif ($enabledLogsNoLaw.Count -gt 0) {
                # Logs are enabled but destination is not a Log Analytics workspace (spec: Investigate).
                $rowStatus = 'Investigate'
            }
            else {
                # Settings exist but none have any logs[].enabled == true (spec: Investigate).
                $rowStatus = 'Investigate'
            }
        }

        [PSCustomObject]@{
            SubscriptionName   = $workspace.SubscriptionName
            SubscriptionId     = $workspace.SubscriptionId
            WorkspaceName      = $workspace.WorkspaceName
            ResourceGroup      = $workspace.ResourceGroup
            WorkspaceId        = $workspace.WorkspaceId
            TotalSettingCount  = $totalSettingCount
            DiagnosticSettings = $settingDetails  # array of per-setting objects; preserves category-to-destination association
            RowStatus          = $rowStatus
        }
    }
    $workspaceResults = @($workspaceResults)

    $passedItems      = @($workspaceResults | Where-Object { $_.RowStatus -eq 'Pass' })
    $investigateItems = @($workspaceResults | Where-Object { $_.RowStatus -eq 'Investigate' })

    # Pass when at least one Sentinel workspace has a qualifying diagnostic setting.
    $passed       = $passedItems.Count -gt 0
    $customStatus = $null

    if (-not $passed -and ($investigateItems.Count -gt 0 -or $forbiddenWorkspaces.Count -gt 0)) {
        $customStatus       = 'Investigate'
        $testResultMarkdown = "⚠️ Auditing and health monitoring could not be confirmed for one or more Sentinel workspaces. This may be due to a diagnostic settings API failure, all log categories being disabled, or diagnostic settings routing to a non-Log Analytics destination. Re-run after verifying Monitoring Reader access on each affected workspace.`n`n%TestResult%"
    }
    elseif ($passed) {
        $testResultMarkdown = "✅ Auditing and health monitoring is enabled for the Sentinel workspace.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "❌ Auditing and health monitoring is not enabled for the Sentinel workspace.`n`n%TestResult%"
    }

    #endregion Assessment Logic

    #region Report Generation

    $azContext          = Get-AzContext -ErrorAction SilentlyContinue
    $portalHost         = if ($azContext -and $azContext.Environment.Name -eq 'AzureUSGovernment') { 'https://portal.azure.us' } else { 'https://portal.azure.com' }
    $portalSentinelLink = "$portalHost/#view/HubsExtension/BrowseResource/resourceType/microsoft.securityinsightsarg%2Fsentinel"
    $tableTitle         = 'Auditing and health monitoring status per workspace'

    $formatTemplate = @'


## [{0}]({1})

| Subscription | Workspace | Diagnostic settings | Setting name | Enabled categories | Destination workspace | Status |
| :----------- | :-------- | ------------------: | :----------- | :----------------- | :-------------------- | :----- |
{2}
'@

    $tableRows      = ''
    $maxDisplay     = 10
    $statusPriority = @{ Fail = 0; Investigate = 1; Pass = 2 }
    $displayResults = @($workspaceResults | Sort-Object { $statusPriority[$_.RowStatus] }, SubscriptionName, WorkspaceName)
    $hasMoreItems   = $false
    if ($workspaceResults.Count -gt $maxDisplay) {
        $displayResults = @($displayResults | Select-Object -First $maxDisplay)
        $hasMoreItems   = $true
    }

    foreach ($result in $displayResults) {
        $subLink      = "$portalHost/#resource/subscriptions/$($result.SubscriptionId)"
        $diagLink     = "$portalHost/#resource$($result.WorkspaceId)/diagnosticSettings"
        $subMd        = "[$(Get-SafeMarkdown $result.SubscriptionName)]($subLink)"
        $workspaceMd  = "[$(Get-SafeMarkdown $result.WorkspaceName)]($diagLink)"
        $countMd      = if ($null -eq $result.TotalSettingCount) { '—' } else { $result.TotalSettingCount }

        if ($result.DiagnosticSettings.Count -gt 0) {
            # One row per diagnostic setting — preserves the category-to-destination association.
            foreach ($setting in $result.DiagnosticSettings) {
                $settingNameMd = Get-SafeMarkdown -Text $setting.Name
                $categoriesMd  = if ($setting.EnabledCategories.Count -gt 0) {
                    $setting.EnabledCategories -join ', '
                } else { '—' }
                $destMd        = if (-not [string]::IsNullOrEmpty($setting.DestinationId)) {
                    $wsName = ($setting.DestinationId -split '/')[-1]
                    "[$(Get-SafeMarkdown $wsName)]($portalHost/#resource$($setting.DestinationId)/overview)"
                } elseif ($setting.EnabledCategories.Count -gt 0) {
                    # Logs enabled but destination is not a Log Analytics workspace.
                    '⚠️ Non-LAW destination'
                } else { '—' }
                $settingStatus = if ($setting.EnabledCategories.Count -gt 0 -and -not [string]::IsNullOrEmpty($setting.DestinationId)) {
                    '✅ Active'
                } elseif ($setting.EnabledCategories.Count -gt 0) {
                    '⚠️ Non-LAW'
                } else {
                    '❌ Logs disabled'
                }
                $tableRows += "| $subMd | $workspaceMd | $countMd | $settingNameMd | $categoriesMd | $destMd | $settingStatus |`n"
            }
        } else {
            # No diagnostic settings (Fail) or API error (Investigate) — single placeholder row.
            $placeholderStatus = if ($result.RowStatus -eq 'Investigate') { '⚠️ Investigate' } else { '❌ No settings' }
            $tableRows += "| $subMd | $workspaceMd | $countMd | — | — | — | $placeholderStatus |`n"
        }
    }

    if ($hasMoreItems) {
        $remainingCount = $workspaceResults.Count - $maxDisplay
        $tableRows     += "`n... and $remainingCount more. [View all in Microsoft Sentinel]($portalSentinelLink)`n"
    }

    $mdInfo             = $formatTemplate -f $tableTitle, $portalSentinelLink, $tableRows
    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo

    #endregion Report Generation

    $params = @{
        TestId = '41211'
        Title  = 'Auditing and health monitoring is enabled for Microsoft Sentinel'
        Status = $passed
        Result = $testResultMarkdown
    }
    if ($null -ne $customStatus) {
        $params.CustomStatus = $customStatus
    }

    Add-ZtTestResultDetail @params
}
