<#
.SYNOPSIS
    User and Entity Behavior Analytics (UEBA) is enabled in Microsoft Sentinel

.DESCRIPTION
    Verifies UEBA configuration on every Sentinel-onboarded Log Analytics workspace by querying
    the Microsoft.SecurityInsights/settings/Ueba and settings/EntityAnalytics resources via ARM.
    Reports per-workspace UEBA state, configured data sources, onboarding date, and entity providers.

.NOTES
    Test ID: 41209
    Workshop Task: SECOPS_103
    Pillar: SecOps
    Category: Security information and event management
    Required API: Azure Resource Manager (management.azure.com)
#>

function Test-Assessment-41209 {
    [ZtTest(
        Category = 'Security information and event management',
        ImplementationCost = 'Low',
        Service = ('Azure'),
        MinimumLicense = ('Consumption-based: Microsoft Sentinel'),
        Pillar = 'SecOps',
        RiskLevel = 'Medium',
        SfiPillar = 'Monitor and detect cyberthreats',
        TenantType = ('Workforce'),
        TestId = 41209,
        Title = 'User and Entity Behavior Analytics (UEBA) is enabled in Microsoft Sentinel',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose
    $activity = 'Checking UEBA configuration in Microsoft Sentinel workspaces'

    # Q1 + Q2 + onboarding check via shared helper.
    # Returns 'Forbidden'        on ARG 401/403 (Investigate).
    # Returns $null              on unexpected ARG failure (Investigate).
    # Returns 'NoSubscriptions'  when no enabled subscriptions are accessible (Skip).
    # Returns 'NoWorkspaces'     when no Log Analytics workspaces exist in scope (Skip).
    $allWorkspaces = Get-SentinelWorkspaceData -Activity $activity

    if ($null -eq $allWorkspaces) {
        $params = @{
            TestId       = '41209'
            Title        = 'User and Entity Behavior Analytics (UEBA) is enabled in Microsoft Sentinel'
            Status       = $false
            Result       = '⚠️ Azure Resource Graph returned an unexpected error while querying subscriptions or Log Analytics workspaces. This is likely a transient issue, please re-run the assessment.'
            CustomStatus = 'Investigate'
        }
        Add-ZtTestResultDetail @params
        return
    }

    if ($allWorkspaces -eq 'Forbidden') {
        $params = @{
            TestId       = '41209'
            Title        = 'User and Entity Behavior Analytics (UEBA) is enabled in Microsoft Sentinel'
            Status       = $false
            Result       = '⚠️ Azure Resource Graph returned insufficient permissions when querying subscriptions or workspaces. Ensure you have at least Reader access to the Azure subscriptions being tested.'
            CustomStatus = 'Investigate'
        }
        Add-ZtTestResultDetail @params
        return
    }

    if ($allWorkspaces -eq 'NoSubscriptions') {
        Write-PSFMessage 'No enabled subscriptions found — skipping Sentinel UEBA check.' -Tag Test -Level VeryVerbose
        Add-ZtTestResultDetail -SkippedBecause NotApplicable
        return
    }

    if ($allWorkspaces -eq 'NoWorkspaces') {
        Write-PSFMessage 'No Log Analytics workspaces found across accessible subscriptions — skipping Sentinel UEBA check.' -Tag Test -Level VeryVerbose
        Add-ZtTestResultDetail -SkippedBecause NotApplicable
        return
    }

    $checkableWorkspaces = @($allWorkspaces | Where-Object { -not $_.PermissionError })
    $forbiddenWorkspaces = @($allWorkspaces | Where-Object { $_.PermissionError })
    $onboardedWorkspaces = @($checkableWorkspaces | Where-Object { $_.SentinelOnboarded })

    if ($onboardedWorkspaces.Count -eq 0) {
        if ($forbiddenWorkspaces.Count -gt 0) {
            # Auth errors on the Q3 onboarding check mean we cannot confirm whether those workspaces
            # have Sentinel onboarded; a passing workspace may exist among the inaccessible ones.
            $params = @{
                TestId       = '41209'
                Title        = 'User and Entity Behavior Analytics (UEBA) is enabled in Microsoft Sentinel'
                Status       = $false
                Result       = '⚠️ One or more Log Analytics workspaces returned insufficient permissions when checking Sentinel onboarding state. No Sentinel-onboarded workspace was confirmed among accessible workspaces — the overall state cannot be determined. Ensure Microsoft Sentinel Reader is granted on all workspaces and re-run the assessment.'
                CustomStatus = 'Investigate'
            }
            Add-ZtTestResultDetail @params
        }
        else {
            # Spec: no Sentinel-onboarded workspaces with full visibility — Skipped.
            Write-PSFMessage 'No Sentinel-onboarded workspaces found — skipping Sentinel UEBA check.' -Tag Test -Level VeryVerbose
            Add-ZtTestResultDetail -SkippedBecause NotApplicable
        }
        return
    }

    # Q1 (spec): Read the Sentinel UEBA setting for each Sentinel-onboarded workspace.
    # Q2 (spec): Read the EntityAnalytics setting (controls IdentityInfo synchronisation, a UEBA prerequisite).
    # Both use api-version 2024-10-01-preview; there is no GA version for the settings endpoint.
    # -FullResponse is required so that HTTP 404 (UEBA never enabled → Fail) can be distinguished from
    # HTTP 200 with empty dataSources (UEBA enabled but not yet analysing any source → Investigate).
    $uebaApiVersion                     = '2024-10-01-preview'
    $uebaResponseByWorkspace            = @{}
    $entityAnalyticsResponseByWorkspace = @{}

    foreach ($workspace in $onboardedWorkspaces) {
        Write-ZtProgress -Activity $activity -Status "Reading UEBA and EntityAnalytics settings for $($workspace.WorkspaceName) in $($workspace.SubscriptionName)"

        # Q1: Ueba setting.
        $uebaPath = "$($workspace.WorkspaceId)/providers/Microsoft.SecurityInsights/settings/Ueba?api-version=$uebaApiVersion"
        try {
            $uebaResponseByWorkspace[$workspace.WorkspaceId] = Invoke-ZtAzureRequest -Path $uebaPath -FullResponse -ErrorAction Stop
        }
        catch {
            # Unexpected connection-level error — cannot determine UEBA state for this workspace.
            $uebaResponseByWorkspace[$workspace.WorkspaceId] = $null
            Write-PSFMessage "Error reading UEBA setting for workspace '$($workspace.WorkspaceName)' in '$($workspace.SubscriptionName)': $_" -Tag Test -Level Warning
        }

        # Q2: EntityAnalytics setting.
        # A 404 here means entityProviders were never explicitly set — not a hard error per spec.
        $entityAnalyticsPath = "$($workspace.WorkspaceId)/providers/Microsoft.SecurityInsights/settings/EntityAnalytics?api-version=$uebaApiVersion"
        try {
            $entityAnalyticsResponseByWorkspace[$workspace.WorkspaceId] = Invoke-ZtAzureRequest -Path $entityAnalyticsPath -FullResponse -ErrorAction Stop
        }
        catch {
            $entityAnalyticsResponseByWorkspace[$workspace.WorkspaceId] = $null
            Write-PSFMessage "Error reading EntityAnalytics setting for workspace '$($workspace.WorkspaceName)' in '$($workspace.SubscriptionName)': $_" -Tag Test -Level Warning
        }
    }

    #endregion Data Collection

    #region Assessment Logic

    $workspaceResults = foreach ($workspace in $onboardedWorkspaces) {
        $uebaResponse            = $uebaResponseByWorkspace[$workspace.WorkspaceId]
        $entityAnalyticsResponse = $entityAnalyticsResponseByWorkspace[$workspace.WorkspaceId]

        # Evaluate Q1 — UEBA setting.
        # $null = state unknown (connection error or unexpected HTTP error); $true/$false = known state.
        $uebaPresent     = $null
        $dataSources     = @()
        $onboardDateTime = $null
        $rowStatus       = 'Investigate'

        if ($null -eq $uebaResponse) {
            # Unexpected connection error — state unknown; $uebaPresent stays $null.
            $rowStatus = 'Investigate'
        }
        else {
            switch ([int]$uebaResponse.StatusCode) {
                200 {
                    $uebaSetting = $uebaResponse.Content | ConvertFrom-Json
                    $uebaPresent = $true
                    $dataSources = @($uebaSetting.properties.dataSources | Where-Object { $_ })
                    $onboardDateTime = $uebaSetting.properties.onboardDateTime
                    # Pass when at least one supported data source is configured; Investigate when empty.
                    $rowStatus = if ($dataSources.Count -gt 0) { 'Pass' } else { 'Investigate' }
                }
                404 {
                    # UEBA has never been enabled on this workspace — definitively off.
                    $uebaPresent = $false
                    $rowStatus   = 'Fail'
                }
                default {
                    # 401, 403, 5xx — API returned but state is unknown; $uebaPresent stays $null.
                    $rowStatus = 'Investigate'
                }
            }
        }

        # Evaluate Q2 — EntityAnalytics setting (informational; does not affect Pass/Fail).
        # $null = state unknown (connection error or unexpected HTTP error).
        # $false = definitively not configured (404: entityProviders never explicitly set per spec).
        $entityAnalyticsPresent = $null
        $entityProviders        = @()

        if ($null -ne $entityAnalyticsResponse) {
            switch ([int]$entityAnalyticsResponse.StatusCode) {
                200 {
                    $eaSetting              = $entityAnalyticsResponse.Content | ConvertFrom-Json
                    $entityAnalyticsPresent = $true
                    $entityProviders        = @($eaSetting.properties.entityProviders | Where-Object { $_ })
                }
                404 {
                    # Spec: entityProviders were never explicitly set — definitively not configured.
                    $entityAnalyticsPresent = $false
                }
                # 401, 403, 5xx → state unknown; $entityAnalyticsPresent stays $null.
            }
        }
        # $null response (connection error) → $entityAnalyticsPresent stays $null.

        [PSCustomObject]@{
            SubscriptionName       = $workspace.SubscriptionName
            SubscriptionId         = $workspace.SubscriptionId
            WorkspaceName          = $workspace.WorkspaceName
            ResourceGroup          = $workspace.ResourceGroup
            WorkspaceId            = $workspace.WorkspaceId
            UebaPresent            = $uebaPresent
            DataSources            = $dataSources
            OnboardDateTime        = $onboardDateTime
            EntityAnalyticsPresent = $entityAnalyticsPresent
            EntityProviders        = $entityProviders
            RowStatus              = $rowStatus
        }
    }
    $workspaceResults = @($workspaceResults)

    $failItems        = @($workspaceResults | Where-Object { $_.RowStatus -eq 'Fail' })
    $investigateItems = @($workspaceResults | Where-Object { $_.RowStatus -eq 'Investigate' })

    # Overall result: Fail takes priority over Investigate; Pass only when every workspace passes.
    $passed       = $failItems.Count -eq 0 -and $investigateItems.Count -eq 0
    $customStatus = $null

    if ($failItems.Count -gt 0) {
        $testResultMarkdown = "❌ UEBA is not enabled in the Sentinel workspace.`n`n%TestResult%"
    }
    elseif ($investigateItems.Count -gt 0) {
        $customStatus       = 'Investigate'
        $testResultMarkdown = "⚠️ The UEBA setting returned an unexpected response, or UEBA is enabled but no supported data sources are configured.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "✅ UEBA is enabled in the Sentinel workspace.`n`n%TestResult%"
    }

    #endregion Assessment Logic

    #region Report Generation

    $azContext          = Get-AzContext -ErrorAction SilentlyContinue
    $portalHost         = if ($azContext -and $azContext.Environment.Name -eq 'AzureUSGovernment') { 'https://portal.azure.us' } else { 'https://portal.azure.com' }
    $portalSentinelLink = "$portalHost/#view/HubsExtension/BrowseResource/resourceType/microsoft.securityinsightsarg%2Fsentinel"
    $tableTitle         = 'UEBA configuration per workspace'

    $formatTemplate = @'


## [{0}]({1})

| Subscription | Workspace | UEBA enabled | Data sources | Onboarded since | Entity analytics | Entity providers | Status |
| :----------- | :-------- | :----------- | :----------- | :-------------- | :--------------- | :--------------- | :----- |
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
        $subLink    = "$portalHost/#resource/subscriptions/$($result.SubscriptionId)"
        $sentinelId = "/subscriptions/$($result.SubscriptionId)/resourcegroups/$($result.ResourceGroup)/providers/microsoft.securityinsightsarg/sentinel/$($result.WorkspaceName)"
        $uebaLink   = "$portalHost/#view/Microsoft_Azure_Security_Insights/MainMenuBlade/~/EntityBehavior/id/$($sentinelId -replace '/', '%2F')"
        $subMd      = "[$(Get-SafeMarkdown $result.SubscriptionName)]($subLink)"
        $wsMd       = "[$(Get-SafeMarkdown $result.WorkspaceName)]($uebaLink)"

        # dataSources and entityProviders are API-controlled enum values — no Get-SafeMarkdown.
        # $null fields mean state unknown (API error) → render as '—'; $true/$false → Yes/No.
        $uebaEnabledMd     = if ($null -eq $result.UebaPresent) { '—' } elseif ($result.UebaPresent) { '✅ Yes' } else { '❌ No' }
        $dataSourcesMd     = if ($result.DataSources.Count -gt 0) { $result.DataSources -join ', ' } else { '—' }
        $onboardedSinceMd  = if ($result.OnboardDateTime) { $result.OnboardDateTime } else { '—' }
        $eaEnabledMd       = if ($null -eq $result.EntityAnalyticsPresent) { '—' } elseif ($result.EntityAnalyticsPresent) { '✅ Yes' } else { '❌ No' }
        $entityProvidersMd = if ($result.EntityProviders.Count -gt 0) { $result.EntityProviders -join ', ' } else { '—' }
        $statusDisplay     = switch ($result.RowStatus) {
            'Pass'        { '✅ Pass' }
            'Fail'        { '❌ Fail' }
            'Investigate' { '⚠️ Investigate' }
        }

        $tableRows += "| $subMd | $wsMd | $uebaEnabledMd | $dataSourcesMd | $onboardedSinceMd | $eaEnabledMd | $entityProvidersMd | $statusDisplay |`n"
    }

    if ($hasMoreItems) {
        $remainingCount = $workspaceResults.Count - $maxDisplay
        $tableRows += "`n... and $remainingCount more. [View all in Microsoft Sentinel]($portalSentinelLink)`n"
    }

    $mdInfo             = $formatTemplate -f $tableTitle, $portalSentinelLink, $tableRows
    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo

    #endregion Report Generation

    $params = @{
        TestId = '41209'
        Title  = 'User and Entity Behavior Analytics (UEBA) is enabled in Microsoft Sentinel'
        Status = $passed
        Result = $testResultMarkdown
    }
    if ($customStatus) {
        $params.CustomStatus = $customStatus
    }

    Add-ZtTestResultDetail @params
}
