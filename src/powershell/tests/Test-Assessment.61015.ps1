<#
.SYNOPSIS
    Microsoft Entra ID data connector is enabled on the Microsoft Sentinel workspace with all log categories.

.DESCRIPTION
    Evaluates Sentinel-onboarded Log Analytics workspaces and verifies Microsoft Entra log coverage
    through tenant-level Entra diagnostic settings targeting each workspace.

    The tenant passes when at least one Sentinel-onboarded workspace has all required
    diagnostic log categories enabled.

.NOTES
    Test ID: 61015
    Pillar: AI
    Workshop Task: AI_089
    Spec: ztspecs/specs/ai/61015.md
#>

function Test-Assessment-61015 {
    [ZtTest(
        Category = 'AI Threat Detection',
        ImplementationCost = 'Low',
        Service = ('Azure'),
        MinimumLicense = ('AAD_PREMIUM', 'Consumption-based: Microsoft Sentinel'),
        CompatibleLicense = ('AAD_PREMIUM', 'AAD_PREMIUM_P2'),
        Pillar = 'AI',
        RiskLevel = 'High',
        SfiPillar = 'Monitor and detect cyberthreats',
        TenantType = ('Workforce'),
        TestId = 61015,
        Title = 'Microsoft Entra ID data connector is enabled on the Microsoft Sentinel workspace with all log categories',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking Microsoft Entra ID log coverage on Sentinel-onboarded workspaces'

    $requiredDiagnosticCategories = @(
        'SignInLogs',
        'AuditLogs',
        'NonInteractiveUserSignInLogs',
        'ServicePrincipalSignInLogs',
        'ManagedIdentitySignInLogs',
        'ProvisioningLogs',
        'ADFSSignInLogs'
    )

    # Q1 (subscriptions) + Q2 (workspaces) + onboarding-state check:
    # Delegate to the shared helper. Returns the same sentinel values as used by 61002.
    # 'Forbidden'       → 401/403 on Q1/Q2 ARG query (skip NoAzureAccess)
    # $null             → unexpected ARG failure (skip NotSupported)
    # 'NoSubscriptions' → no enabled subscriptions (skip NotApplicable)
    # 'NoWorkspaces'    → no Log Analytics workspaces found (Fail — blocked by upstream 61002)
    # array             → workspace results (SentinelOnboarded, PermissionError flags)
    $workspaceResults = Get-SentinelWorkspaceData -Activity $activity

    if ($workspaceResults -eq 'Forbidden') {
        Add-ZtTestResultDetail -SkippedBecause NoAzureAccess
        return
    }

    if ($null -eq $workspaceResults) {
        Add-ZtTestResultDetail -SkippedBecause NotSupported
        return
    }

    if ($workspaceResults -eq 'NoSubscriptions') {
        Add-ZtTestResultDetail -SkippedBecause NotApplicable
        return
    }

    # 'NoWorkspaces' (no Log Analytics workspaces at all) and an array with no Sentinel-onboarded
    # workspaces are both the "blocked by upstream 61002" condition — both Fail per spec.
    $sentinelWorkspaces = if ($workspaceResults -eq 'NoWorkspaces') {
        @()
    } else {
        @($workspaceResults | Where-Object { $_.SentinelOnboarded })
    }

    if ($sentinelWorkspaces.Count -eq 0) {
        $params = @{
            TestId = '61015'
            Title  = 'Microsoft Entra ID data connector is enabled on the Microsoft Sentinel workspace with all log categories'
            Status = $false
            Result = "❌ No Sentinel-onboarded workspace was found in this tenant. Deploy Microsoft Sentinel and enable the Entra ID data connector to evaluate Entra log coverage."
        }
        Add-ZtTestResultDetail @params
        return
    }

    $tenantDiagnosticSettings = @()
    $q3PermissionError = $false

    # Q3: List Microsoft Entra diagnostic settings once at tenant scope (cached for all workspace evaluations).
    Write-ZtProgress -Activity $activity -Status 'Querying tenant Entra diagnostic settings (Q3)'
    try {
        $q3Response = Invoke-ZtAzureRequest -Path '/providers/microsoft.aadiam/diagnosticSettings?api-version=2017-04-01-preview'
        $tenantDiagnosticSettings = @($q3Response.value)
    }
    catch {
        Write-PSFMessage "Entra diagnostic settings request threw: $($_.Exception.Message)" -Tag Test -Level Warning
        $q3PermissionError = $true
    }
    #endregion Data Collection

    #region Assessment Logic

    # Q3 permission error → return Investigate immediately (no data to evaluate)
    if ($q3PermissionError) {
        $params = @{
            TestId = '61015'
            Title  = 'Microsoft Entra ID data connector is enabled on the Microsoft Sentinel workspace with all log categories'
            Status = $false
            Result = '⚠️ The Entra diagnostic settings API returned an authorization (401/403) or transient (5xx) error, so coverage could not be determined. Re-run after verifying caller permissions — Security Reader or Global Reader at tenant scope.'
            CustomStatus = 'Investigate'
        }
        Add-ZtTestResultDetail @params
        return
    }

    $workspaceRows = @()
    $workspacePassCount = 0

    Write-ZtProgress -Activity $activity -Status 'Evaluating workspace coverage via Entra diagnostic settings (Q3)'

    foreach ($workspace in ($sentinelWorkspaces | Sort-Object SubscriptionName, ResourceGroup, WorkspaceName)) {
        $workspaceResourceId = $workspace.WorkspaceId
        $workspaceResourceIdNormalized = $workspaceResourceId.TrimEnd('/').ToLowerInvariant()
        $workspaceName = $workspace.WorkspaceName
        $subscriptionName = $workspace.SubscriptionName
        if ([string]::IsNullOrWhiteSpace($subscriptionName)) {
            $subscriptionName = 'Unknown subscription'
        }

        $matchingDiagnosticSettings = @($tenantDiagnosticSettings | Where-Object {
            $targetWorkspaceId = $_.properties.workspaceId
            -not [string]::IsNullOrWhiteSpace($targetWorkspaceId) -and $targetWorkspaceId.TrimEnd('/').ToLowerInvariant() -eq $workspaceResourceIdNormalized
        })

        $enabledCategories = @(
            $matchingDiagnosticSettings |
                ForEach-Object { $_.properties.logs } |
                Where-Object { $_.enabled -eq $true -and -not [string]::IsNullOrWhiteSpace($_.category) } |
                Select-Object -ExpandProperty category -Unique
        )

        $categoriesInMatchingSettings = @(
            $matchingDiagnosticSettings |
                ForEach-Object { $_.properties.logs } |
                Where-Object { -not [string]::IsNullOrWhiteSpace($_.category) } |
                Select-Object -ExpandProperty category -Unique
        )

        # ADFSSignInLogs is skipped only when AD FS is not applicable for this workspace scope.
        $adfsApplicable = 'ADFSSignInLogs' -in $categoriesInMatchingSettings
        $missingCategories = @($requiredDiagnosticCategories | Where-Object {
            if ($_ -eq 'ADFSSignInLogs' -and -not $adfsApplicable) {
                return $false
            }
            $_ -notin $enabledCategories
        })
        $workspacePassed = ($matchingDiagnosticSettings.Count -gt 0) -and ($missingCategories.Count -eq 0)

        if ($workspacePassed) {
            $workspacePassCount++
        }

        foreach ($requiredCategory in $requiredDiagnosticCategories) {
            $categoryEnabled = $requiredCategory -in $enabledCategories
            $isAdfsSkipped = $requiredCategory -eq 'ADFSSignInLogs' -and -not $adfsApplicable
            $noSettings = $matchingDiagnosticSettings.Count -eq 0

            $workspaceRows += [PSCustomObject]@{
                Subscription        = $subscriptionName
                SubscriptionId      = $workspace.SubscriptionId
                Workspace           = $workspaceName
                WorkspaceResourceId = $workspaceResourceId
                RequiredCategory    = $requiredCategory
                EnabledDisplay      = if ($noSettings) { '❌ Diagnostic setting missing' } elseif ($isAdfsSkipped) { '⚠️ Skipped' } elseif ($categoryEnabled) { '✅ Yes' } else { '❌ No' }
                StatusDisplay       = if ($noSettings) { '❌ Fail' } elseif ($isAdfsSkipped) { '⚠️ Skipped' } elseif ($categoryEnabled) { '✅ Pass' } else { '❌ Fail' }
            }
        }
    }

    if ($workspacePassCount -gt 0) {
        $passed = $true
        $testResultMarkdown = "✅ Microsoft Entra ID logs are flowing to at least one Sentinel-onboarded workspace — a tenant Entra diagnostic setting targets the workspace with every required log category enabled (which automatically enables the Sentinel connector and the Microsoft Entra ID Content Hub solution).`n`n%TestResult%"
    }
    else {
        $passed = $false
        $testResultMarkdown = "❌ No Sentinel-onboarded workspace has an Entra diagnostic setting covering it with every required log category enabled. Also Fail when the Sentinel onboarding check failed.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    $maxTableRows = 10
    $mdInfo = ''

    $reportTitle = 'Sentinel Entra ID coverage per workspace'
    $portalLink = 'https://portal.azure.com/#view/HubsExtension/BrowseResource/resourceType/microsoft.securityinsightsarg%2Fsentinel'

    $tableRows = ''
    $rowsToRender = @($workspaceRows | Sort-Object Subscription, Workspace, RequiredCategory)
    $rowsToRenderOriginalCount = $rowsToRender.Count
    if ($rowsToRender.Count -gt $maxTableRows) {
        $rowsToRender = @($rowsToRender | Select-Object -First $maxTableRows)
    }

    foreach ($row in $rowsToRender) {
        $subscriptionLink = "https://portal.azure.com/#resource/subscriptions/$($row.SubscriptionId)/overview"
        $workspaceLink = "https://portal.azure.com/#resource$($row.WorkspaceResourceId)/overview"
        $tableRows += "| [$(Get-SafeMarkdown $row.Subscription)]($subscriptionLink) | [$(Get-SafeMarkdown $row.Workspace)]($workspaceLink) | $(Get-SafeMarkdown $row.RequiredCategory) | $($row.EnabledDisplay) | $($row.StatusDisplay) |`n"
    }

    if ($tableRows) {
        $formatTemplate = @'


### [{0}]({1})

| Subscription | Workspace | Required log category | Enabled | Status |
| :----------- | :-------- | :-------------------- | :------ | :----- |
{2}

'@

        $mdInfo = $formatTemplate -f $reportTitle, $portalLink, $tableRows

        if ($rowsToRenderOriginalCount -gt $maxTableRows) {
            $mdInfo += "_**Note**: This table is truncated and showing the first $maxTableRows out of $rowsToRenderOriginalCount rows._`n`n"
        }
    }
    else {
        $mdInfo = 'No Sentinel-onboarded workspace rows were available to render for this tenant.'
    }

    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '61015'
        Title  = 'Microsoft Entra ID data connector is enabled on the Microsoft Sentinel workspace with all log categories'
        Status = $passed
        Result = $testResultMarkdown
    }
    Add-ZtTestResultDetail @params
}
