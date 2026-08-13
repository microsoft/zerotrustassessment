<#
.SYNOPSIS
    Checks that security tables in each Sentinel workspace are provisioned on the
    appropriate Log Analytics storage plan (Analytics, Basic, or Auxiliary).

.DESCRIPTION
    Detection-critical tables such as SigninLogs and SecurityAlert must remain on
    the Analytics plan so that scheduled analytics rules and UEBA can run against
    them. High-volume verbose tables like CommonSecurityLog and Syslog may be moved
    to Basic or Auxiliary to reduce ingest costs without losing scheduled-rule coverage.
    This test flags detection-critical tables on the wrong plan (Fail) and
    high-volume tables left on Analytics when cheaper plans are viable (Investigate).

.NOTES
    Test ID: 41217
    Workshop Task: SECOPS_096
    Category: Security information and event management
    Pillar: SecOps
    Required API: Azure Resource Manager (management.azure.com)
#>

function Test-Assessment-41217 {
    [ZtTest(
        Category           = 'Security information and event management',
        ImplementationCost = 'Low',
        MinimumLicense     = ('Consumption-based: Microsoft Sentinel'),
        Pillar             = 'SecOps',
        RiskLevel          = 'Medium',
        Service            = ('Azure'),
        SfiPillar          = 'Monitor and detect cyberthreats',
        TenantType         = ('Workforce'),
        TestId             = 41217,
        Title              = 'Security tables are provisioned on the appropriate Log Analytics storage plan (Analytics, Basic, or Auxiliary)',
        UserImpact         = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose
    $activity = 'Checking Log Analytics table plan assignments in Sentinel workspaces'

    # Q1 + Q2 + onboarding check via shared helper.
    # Returns 'Forbidden'        on ARG 401/403 (Investigate).
    # Returns $null              on unexpected ARG failure (Investigate).
    # Returns 'NoSubscriptions'  when no enabled subscriptions are accessible (Investigate).
    # Returns 'NoWorkspaces'     when no Log Analytics workspaces exist in scope (Investigate).
    $allWorkspaces = Get-SentinelWorkspaceData -Activity $activity

    if ($null -eq $allWorkspaces) {
        $params = @{
            TestId       = '41217'
            Title        = 'Security tables are provisioned on the appropriate Log Analytics storage plan (Analytics, Basic, or Auxiliary)'
            Status       = $false
            Result       = '⚠️ Azure Resource Graph returned an unexpected error while querying subscriptions or Log Analytics workspaces. This is likely a transient issue, please re-run the assessment.'
            CustomStatus = 'Investigate'
        }
        Add-ZtTestResultDetail @params
        return
    }

    if ($allWorkspaces -eq 'Forbidden') {
        $params = @{
            TestId       = '41217'
            Title        = 'Security tables are provisioned on the appropriate Log Analytics storage plan (Analytics, Basic, or Auxiliary)'
            Status       = $false
            Result       = '⚠️ Azure Resource Graph returned insufficient permissions when querying subscriptions or workspaces. Ensure you have at least Reader access to the Azure subscriptions being tested.'
            CustomStatus = 'Investigate'
        }
        Add-ZtTestResultDetail @params
        return
    }

    if ($allWorkspaces -eq 'NoSubscriptions') {
        $params = @{
            TestId       = '41217'
            Title        = 'Security tables are provisioned on the appropriate Log Analytics storage plan (Analytics, Basic, or Auxiliary)'
            Status       = $false
            Result       = '⚠️ The check could not evaluate any table — no Sentinel-onboarded workspace was found, no detection-critical table was present, a plan value was indeterminate, or a query failed.'
            CustomStatus = 'Investigate'
        }
        Add-ZtTestResultDetail @params
        return
    }

    if ($allWorkspaces -eq 'NoWorkspaces') {
        $params = @{
            TestId       = '41217'
            Title        = 'Security tables are provisioned on the appropriate Log Analytics storage plan (Analytics, Basic, or Auxiliary)'
            Status       = $false
            Result       = '⚠️ The check could not evaluate any table — no Sentinel-onboarded workspace was found, no detection-critical table was present, a plan value was indeterminate, or a query failed.'
            CustomStatus = 'Investigate'
        }
        Add-ZtTestResultDetail @params
        return
    }

    $checkableWorkspaces       = @($allWorkspaces | Where-Object { -not $_.PermissionError })
    $forbiddenWorkspaces       = @($allWorkspaces | Where-Object { $_.PermissionError })
    $onboardingErrorWorkspaces = @($allWorkspaces | Where-Object { $_.OnboardingError })
    $onboardedWorkspaces       = @($checkableWorkspaces | Where-Object { $_.SentinelOnboarded })

    if ($onboardedWorkspaces.Count -eq 0) {
        if ($forbiddenWorkspaces.Count -gt 0 -or $onboardingErrorWorkspaces.Count -gt 0) {
            $params = @{
                TestId       = '41217'
                Title        = 'Security tables are provisioned on the appropriate Log Analytics storage plan (Analytics, Basic, or Auxiliary)'
                Status       = $false
                Result       = '⚠️ One or more Log Analytics workspaces returned insufficient permissions when checking Sentinel onboarding state. No Sentinel-onboarded workspace was confirmed among accessible workspaces — the overall state cannot be determined. Ensure Microsoft Sentinel Reader is granted on all workspaces and re-run the assessment.'
                CustomStatus = 'Investigate'
            }
            Add-ZtTestResultDetail @params
        }
        else {
            $params = @{
                TestId       = '41217'
                Title        = 'Security tables are provisioned on the appropriate Log Analytics storage plan (Analytics, Basic, or Auxiliary)'
                Status       = $false
                Result       = '⚠️ The check could not evaluate any table — no Sentinel-onboarded workspace was found, no detection-critical table was present, a plan value was indeterminate, or a query failed.'
                CustomStatus = 'Investigate'
            }
            Add-ZtTestResultDetail @params
        }
        return
    }

    # Q3 (spec): For each Sentinel-onboarded workspace, list every table and read its plan.
    $rawTablesByWorkspace = @{}

    foreach ($workspace in $onboardedWorkspaces) {
        Write-ZtProgress -Activity $activity -Status "Reading table plans for $($workspace.WorkspaceName) in $($workspace.SubscriptionName)"
        $tablesPath = "$($workspace.WorkspaceId)/tables?api-version=2026-03-01"

        try {
            $rawTablesByWorkspace[$workspace.WorkspaceId] = @(Invoke-ZtAzureRequest -Path $tablesPath -ErrorAction Stop)
        }
        catch {
            $rawTablesByWorkspace[$workspace.WorkspaceId] = $null
            Write-PSFMessage "Error reading table plans for workspace '$($workspace.WorkspaceName)' in subscription '$($workspace.SubscriptionName)': $_" -Tag Test -Level Warning
        }
    }

    #endregion Data Collection

    #region Assessment Logic

    # Detection-critical tables: must be on Analytics for analytics rules and UEBA to run.
    $detectionCriticalTables = @(
        'SigninLogs', 'AuditLogs', 'AADNonInteractiveUserSignInLogs',
        'AADServicePrincipalSignInLogs', 'OfficeActivity', 'SecurityAlert',
        'SecurityIncident', 'IdentityLogonEvents', 'EmailEvents',
        'CloudAppEvents', 'SecurityEvent'
    )

    # High-volume verbose tables: any plan is acceptable; Analytics is flagged as cost-optimization.
    $highVolumeTables = @(
        'CommonSecurityLog', 'Syslog', 'WindowsFirewall', 'DeviceNetworkEvents',
        'AzureDiagnostics', 'AzureMetrics'
    )

    $workspaceResults = [System.Collections.Generic.List[object]]::new()
    $allTableRows     = [System.Collections.Generic.List[object]]::new()

    foreach ($workspace in $onboardedWorkspaces) {
        $rawTables    = $rawTablesByWorkspace[$workspace.WorkspaceId]
        $wsHasApiError = $null -eq $rawTables

        if (-not $wsHasApiError) {
            foreach ($table in $rawTables) {
                $tableName  = $table.name
                $actualPlan = $table.properties.plan

                if ($tableName -in $detectionCriticalTables) {
                    $classification = 'Detection-critical'
                    $expectedPlan   = 'Analytics'
                    # Indeterminate plan (null or unrecognized) must not become a false Fail.
                    if ($null -eq $actualPlan -or $actualPlan -notin @('Analytics', 'Basic', 'Auxiliary')) {
                        $rowStatus = 'Investigate'
                    }
                    else {
                        $rowStatus = if ($actualPlan -eq 'Analytics') { 'Pass' } else { 'Fail' }
                    }
                }
                elseif ($tableName -in $highVolumeTables) {
                    $classification = 'High-volume'
                    $expectedPlan   = 'Basic or Auxiliary'
                    $rowStatus      = if ($actualPlan -eq 'Analytics') { 'Investigate' } else { 'Pass' }
                }
                else {
                    continue  # Not in either list — not evaluated.
                }

                [void]$allTableRows.Add([PSCustomObject]@{
                    SubscriptionName = $workspace.SubscriptionName
                    SubscriptionId   = $workspace.SubscriptionId
                    WorkspaceName    = $workspace.WorkspaceName
                    WorkspaceId      = $workspace.WorkspaceId
                    ResourceGroup    = $workspace.ResourceGroup
                    TableName        = $tableName
                    Classification   = $classification
                    ExpectedPlan     = $expectedPlan
                    ActualPlan       = $actualPlan
                    RowStatus        = $rowStatus
                })
            }
        }

        # Add N/A rows for detection-critical tables absent from this workspace (spec: mark N/A, exclude from roll-up).
        if (-not $wsHasApiError) {
            $presentTableNames = @($rawTables | Select-Object -ExpandProperty name)
            foreach ($criticalName in $detectionCriticalTables) {
                if ($criticalName -notin $presentTableNames) {
                    [void]$allTableRows.Add([PSCustomObject]@{
                        SubscriptionName = $workspace.SubscriptionName
                        SubscriptionId   = $workspace.SubscriptionId
                        WorkspaceName    = $workspace.WorkspaceName
                        WorkspaceId      = $workspace.WorkspaceId
                        ResourceGroup    = $workspace.ResourceGroup
                        TableName        = $criticalName
                        Classification   = 'Detection-critical'
                        ExpectedPlan     = 'Analytics'
                        ActualPlan       = '—'
                        RowStatus        = 'NA'
                    })
                }
            }
        }

        # Workspace-level aggregation per spec: Fail > Investigate > Pass.
        # Q3 API error is always Investigate regardless of individual table results.
        $wsFail              = @($allTableRows | Where-Object { $_.WorkspaceId -eq $workspace.WorkspaceId -and $_.RowStatus -eq 'Fail' })
        $wsInvestigate       = @($allTableRows | Where-Object { $_.WorkspaceId -eq $workspace.WorkspaceId -and $_.RowStatus -eq 'Investigate' })
        # Non-NA critical rows: absent (NA) tables are excluded from the aggregation roll-up.
        $wsCriticalEvaluated = @($allTableRows | Where-Object { $_.WorkspaceId -eq $workspace.WorkspaceId -and $_.Classification -eq 'Detection-critical' -and $_.RowStatus -ne 'NA' })

        $wsStatus = if ($wsHasApiError) {
            'Investigate'
        }
        elseif ($wsFail.Count -gt 0) {
            'Fail'
        }
        elseif ($wsCriticalEvaluated.Count -eq 0) {
            'Investigate'  # every detection-critical table was absent — nothing to evaluate
        }
        elseif ($wsInvestigate.Count -gt 0) {
            'Investigate'
        }
        else {
            'Pass'
        }

        [void]$workspaceResults.Add([PSCustomObject]@{
            SubscriptionName    = $workspace.SubscriptionName
            SubscriptionId      = $workspace.SubscriptionId
            WorkspaceName       = $workspace.WorkspaceName
            WorkspaceId         = $workspace.WorkspaceId
            ResourceGroup       = $workspace.ResourceGroup
            ApiError            = $wsHasApiError
            NoEvaluatedCritical = ($wsCriticalEvaluated.Count -eq 0 -and -not $wsHasApiError)
            RowStatus           = $wsStatus
        })
    }

    $workspaceResults = @($workspaceResults)
    $allTableRows     = @($allTableRows)

    # Add Investigate entries for workspaces whose onboarding state could not be determined.
    # These never reach Q3 but must appear in the roll-up so a confirmed-pass workspace
    # cannot mask an unknown workspace.
    foreach ($ws in (@($forbiddenWorkspaces) + @($onboardingErrorWorkspaces))) {
        $workspaceResults += [PSCustomObject]@{
            SubscriptionName    = $ws.SubscriptionName
            SubscriptionId      = $ws.SubscriptionId
            WorkspaceName       = $ws.WorkspaceName
            WorkspaceId         = $ws.WorkspaceId
            ResourceGroup       = $ws.ResourceGroup
            ApiError            = $false
            NoEvaluatedCritical = $false
            RowStatus           = 'Investigate'
        }
    }

    # Tenant-level roll-up: Fail > Investigate > Pass.
    $tenantFailWs        = @($workspaceResults | Where-Object { $_.RowStatus -eq 'Fail' })
    $tenantInvestigateWs = @($workspaceResults | Where-Object { $_.RowStatus -eq 'Investigate' })

    $passed       = $tenantFailWs.Count -eq 0 -and $tenantInvestigateWs.Count -eq 0
    $customStatus = $null

    if ($tenantFailWs.Count -gt 0) {
        $testResultMarkdown = "❌ One or more detection-critical tables are on Basic or Auxiliary, which prevents scheduled analytics rules from running against them.`n`n%TestResult%"
    }
    elseif ($tenantInvestigateWs.Count -gt 0) {
        $customStatus = 'Investigate'
        # Evaluability issues: API errors, no detection-critical tables evaluated, or indeterminate plan values.
        $hasEvaluabilityIssue = (
            @($workspaceResults | Where-Object { $_.ApiError }).Count -gt 0 -or
            @($workspaceResults | Where-Object { $_.NoEvaluatedCritical }).Count -gt 0 -or
            @($allTableRows | Where-Object { $_.Classification -eq 'Detection-critical' -and $_.RowStatus -eq 'Investigate' }).Count -gt 0
        )
        $hasCostOptimize = @($allTableRows | Where-Object { $_.Classification -eq 'High-volume' -and $_.RowStatus -eq 'Investigate' }).Count -gt 0

        if ($hasCostOptimize -and -not $hasEvaluabilityIssue) {
            $testResultMarkdown = "⚠️ A high-volume table is on Analytics where Basic or Auxiliary may significantly reduce ingest cost without losing required detection capability.`n`n%TestResult%"
        }
        else {
            $testResultMarkdown = "⚠️ The check could not evaluate any table — no Sentinel-onboarded workspace was found, no detection-critical table was present, a plan value was indeterminate, or a query failed.`n`n%TestResult%"
        }
    }
    else {
        $testResultMarkdown = "✅ All detection-critical security tables are on the Analytics plan in the Sentinel workspace.`n`n%TestResult%"
    }

    #endregion Assessment Logic

    #region Report Generation

    $azContext          = Get-AzContext -ErrorAction SilentlyContinue
    $portalHost         = if ($azContext -and $azContext.Environment.Name -eq 'AzureUSGovernment') { 'https://portal.azure.us' } else { 'https://portal.azure.com' }
    $portalSentinelLink = "$portalHost/#view/HubsExtension/BrowseResource/resourceType/microsoft.securityinsightsarg%2Fsentinel"
    $title41217         = 'Security tables per Sentinel workspace'

    # Workspace summary table — satisfies "list every evaluated workspace with its status".
    $wsFormatTemplate = @'


## [{0}]({1})

| Subscription | Workspace | Status |
| :----------- | :-------- | :----- |
{2}
'@

    $statusPriority  = @{ Fail = 0; Investigate = 1; Pass = 2; NA = 3 }
    $wsSortedResults = @($workspaceResults | Sort-Object { $statusPriority[$_.RowStatus] }, SubscriptionName, WorkspaceName)

    $wsTableRows = ''
    foreach ($ws in $wsSortedResults) {
        $subLink       = "$portalHost/#resource/subscriptions/$($ws.SubscriptionId)"
        $wsTablesLink  = "$portalHost/#resource$($ws.WorkspaceId)/tables"
        $subMd         = "[$(Get-SafeMarkdown $ws.SubscriptionName)]($subLink)"
        $wsMd          = "[$(Get-SafeMarkdown $ws.WorkspaceName)]($wsTablesLink)"
        $wsStatusDisplay = switch ($ws.RowStatus) {
            'Pass'        { '✅ Pass' }
            'Fail'        { '❌ Fail' }
            'Investigate' { '⚠️ Investigate' }
        }
        $wsTableRows += "| $subMd | $wsMd | $wsStatusDisplay |`n"
    }

    $wsSection = $wsFormatTemplate -f $title41217, $portalSentinelLink, $wsTableRows

    # Per-table detail table — one row per evaluated (classified + present) table.
    $detailFormatTemplate = @'


## [Table plan details]({1})

| Subscription | Workspace | Table | Classification | Expected plan | Actual plan | Status |
| :----------- | :-------- | :---- | :------------- | :------------ | :---------- | :----- |
{0}
'@

    $maxDisplay   = 25
    # Sort: worst status first within each workspace, then by classification (critical first), then name.
    $classOrder   = @{ 'Detection-critical' = 0; 'High-volume' = 1 }
    $sortedRows   = @($allTableRows | Sort-Object {
        $statusPriority[$_.RowStatus]
    }, SubscriptionName, WorkspaceName, { $classOrder[$_.Classification] }, TableName)

    $hasMoreItems = $sortedRows.Count -gt $maxDisplay
    $displayRows  = if ($hasMoreItems) { @($sortedRows | Select-Object -First $maxDisplay) } else { $sortedRows }

    $tableDetailRows = ''
    foreach ($row in $displayRows) {
        $subLink      = "$portalHost/#resource/subscriptions/$($row.SubscriptionId)"
        $wsTablesLink = "$portalHost/#resource$($row.WorkspaceId)/tables"
        $subMd        = "[$(Get-SafeMarkdown $row.SubscriptionName)]($subLink)"
        $wsMd         = "[$(Get-SafeMarkdown $row.WorkspaceName)]($wsTablesLink)"
        $rowStatusDisplay = switch ($row.RowStatus) {
            'Pass'        { '✅ Pass' }
            'Fail'        { '❌ Fail' }
            'Investigate' { '⚠️ Investigate' }
            'NA'          { 'N/A' }
        }
        $tableDetailRows += "| $subMd | $wsMd | $($row.TableName) | $($row.Classification) | $($row.ExpectedPlan) | $($row.ActualPlan) | $rowStatusDisplay |`n"
    }

    if ($hasMoreItems) {
        $remainingCount   = $sortedRows.Count - $maxDisplay
        $tableDetailRows += "`n... and $remainingCount more. [View all tables in Microsoft Sentinel]($portalSentinelLink)`n"
    }

    if ($allTableRows.Count -eq 0) {
        $detailSection = "`n`nNo classified security tables were found in any evaluated workspace."
    }
    else {
        $detailSection = $detailFormatTemplate -f $tableDetailRows, $portalSentinelLink
    }

    $mdInfo             = $wsSection + $detailSection
    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo

    #endregion Report Generation

    $params = @{
        TestId = '41217'
        Title  = 'Security tables are provisioned on the appropriate Log Analytics storage plan (Analytics, Basic, or Auxiliary)'
        Status = $passed
        Result = $testResultMarkdown
    }
    if ($customStatus) {
        $params.CustomStatus = $customStatus
    }

    Add-ZtTestResultDetail @params
}
