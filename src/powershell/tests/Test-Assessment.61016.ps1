<#
.SYNOPSIS
    Microsoft Entra ID Protection risk events are flowing to the Microsoft Sentinel workspace.

.DESCRIPTION
    Verifies that Microsoft Entra ID Protection risk-event categories (RiskyUsers and
    UserRiskEvents) are flowing into at least one Sentinel-onboarded Log Analytics workspace
    via a tenant-scoped Microsoft Entra diagnostic setting that targets the workspace.
    Configuring this diagnostic setting auto-enables the Microsoft Entra ID data connector
    (and Content Hub solution) inside Sentinel for the targeted workspace.

    Evaluation steps:
      1. Skip if the tenant lacks an AAD_PREMIUM_P2 subscribed SKU (Identity Protection
         requires Entra ID P2).
      2. Enumerate Sentinel-onboarded Log Analytics workspaces (Q1 + Q2) via the shared
         helper Get-SentinelWorkspaceData.
      3. Read tenant-scoped Microsoft Entra diagnostic settings once (Q3).
      4. For each Sentinel-onboarded workspace, union enabled categories across all
         diagnostic settings whose properties.workspaceId matches the workspace ARM id,
         and require both 'RiskyUsers' and 'UserRiskEvents' to be enabled.
      5. Pass if at least one Sentinel-onboarded workspace satisfies the criterion.

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
        CompatibleLicense = ('AAD_PREMIUM_P2'),
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

    # License precondition: Identity Protection requires Entra ID P2 (service plan AAD_PREMIUM_P2).
    if (-not (Get-ZtLicense EntraIDP2)) {
        Add-ZtTestResultDetail -SkippedBecause NotLicensedEntraIDP2
        return
    }

    $activity = 'Checking Microsoft Entra ID Protection risk events flowing to Sentinel workspaces'
    $requiredCategories = @('RiskyUsers', 'UserRiskEvents')
    $customStatus = 'Investigate'
    $insufficientPermissionsMessage = '⚠️ Some of the queried resources returned status indicating insufficient permissions. Please make sure you have at least reader access to the Azure subscriptions being tested and the Security Reader or Global Reader directory role for the tenant-scope diagnostic-settings read.'

    # Q1 + Q2: enumerate Log Analytics workspaces and their Sentinel onboarding state via shared helper.
    # 'Forbidden' => Investigate; $null => non-403 ARG failure (skip); empty => no workspaces (skip).
    $workspaceResults = Get-SentinelWorkspaceData -Activity $activity

    if ($workspaceResults -eq 'Forbidden') {
        $params = @{
            TestId       = '61016'
            Status       = $false
            Result       = $insufficientPermissionsMessage
            CustomStatus = $customStatus
        }
        Add-ZtTestResultDetail @params
        return
    }

    if ($null -eq $workspaceResults) {
        Add-ZtTestResultDetail -SkippedBecause NoAzureAccess
        return
    }

    # Q3: tenant-scoped Microsoft Entra diagnostic settings (single call).
    Write-ZtProgress -Activity $activity -Status 'Querying Microsoft Entra diagnostic settings (tenant scope)'
    $diagnosticSettings = @()
    try {
        $diagResponse = Invoke-ZtAzureRequest -Path '/providers/microsoft.aadiam/diagnosticSettings?api-version=2017-04-01-preview' -FullResponse -ErrorAction Stop
        if ($diagResponse.StatusCode -in 401, 403) {
            $params = @{
                TestId       = '61016'
                Status       = $false
                Result       = $insufficientPermissionsMessage
                CustomStatus = $customStatus
            }
            Add-ZtTestResultDetail @params
            return
        }
        if ($diagResponse.StatusCode -ge 400) {
            Write-PSFMessage "Microsoft Entra diagnostic settings query failed with status $($diagResponse.StatusCode)." -Tag Test -Level Warning
            $params = @{
                TestId       = '61016'
                Status       = $false
                Result       = "⚠️ Microsoft Entra diagnostic settings query returned an unexpected status ($($diagResponse.StatusCode)). Please retry or investigate tenant-scope access."
                CustomStatus = $customStatus
            }
            Add-ZtTestResultDetail @params
            return
        }
        $diagnosticSettings = @(($diagResponse.Content | ConvertFrom-Json).value)
    }
    catch {
        Write-PSFMessage "Failed to query Microsoft Entra diagnostic settings: $_" -Tag Test -Level Warning -ErrorRecord $_
        $params = @{
            TestId       = '61016'
            Status       = $false
            Result       = '⚠️ Microsoft Entra diagnostic settings query failed. Please retry or investigate tenant-scope access.'
            CustomStatus = $customStatus
        }
        Add-ZtTestResultDetail @params
        return
    }
    #endregion Data Collection

    #region Assessment Logic
    $sentinelWorkspaces = @($workspaceResults | Where-Object { $_.SentinelOnboarded })

    # Precondition (61002): no Sentinel-onboarded workspace -> Fail per spec.
    if ($sentinelWorkspaces.Count -eq 0) {
        $testResultMarkdown = "❌ No Sentinel-onboarded workspace in tenant.`n`n%TestResult%"
        $mdInfo = "`n`nNo Log Analytics workspace in scope is onboarded to Microsoft Sentinel, so Microsoft Entra ID Protection risk events have nowhere to flow.`n"
        $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
        $params = @{
            TestId = '61016'
            Status = $false
            Result = $testResultMarkdown
        }
        Add-ZtTestResultDetail @params
        return
    }

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
    $passed = $passingWorkspaces.Count -ge 1
    #endregion Assessment Logic

    #region Report Generation
    if ($passed) {
        $testResultMarkdown = "✅ Microsoft Entra ID Protection risk events (``RiskyUsers`` / ``UserRiskEvents``) are configured to flow to at least one Sentinel-onboarded workspace — a tenant Entra diagnostic setting targets the workspace with both risk-event log categories enabled (which automatically enables the Sentinel connector and the Microsoft Entra ID Content Hub solution).`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "❌ No Sentinel-onboarded workspace has a tenant-scoped Microsoft Entra diagnostic setting targeting it with both ``RiskyUsers`` and ``UserRiskEvents`` log categories enabled.`n`n%TestResult%"
    }

    $reportPortalUrl = 'https://portal.azure.com/#view/HubsExtension/BrowseResource/resourceType/microsoft.securityinsightsarg%2Fsentinel'
    $workspacePortalTemplate = 'https://portal.azure.com/#resource{0}/overview'
    $subscriptionPortalTemplate = 'https://portal.azure.com/#resource/subscriptions/{0}/overview'

    # Spec output: one row per (workspace, required category). Workspace passes only when both rows pass.
    $categoryTableMap = [ordered]@{
        'RiskyUsers'     = 'AADRiskyUsers'
        'UserRiskEvents' = 'AADUserRiskEvents'
    }

    $tableRows = ''
    foreach ($entry in $perWorkspace) {
        $subscriptionName = Get-SafeMarkdown -Text $entry.SubscriptionName
        $workspaceName = Get-SafeMarkdown -Text $entry.WorkspaceName
        $workspaceLink = "[$workspaceName]($($workspacePortalTemplate -f $entry.WorkspaceId))"

        # Extract subscription GUID from the workspace ARM id (/subscriptions/{id}/...).
        $subscriptionLink = $subscriptionName
        if ($entry.WorkspaceId -match '/subscriptions/([0-9a-fA-F-]{36})/') {
            $subscriptionLink = "[$subscriptionName]($($subscriptionPortalTemplate -f $Matches[1]))"
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

    $formatTemplate = @'


#### [Sentinel Entra ID Protection coverage per workspace]({0})

| Subscription | Workspace | Required risk-event category | Enabled | Status |
| :----------- | :-------- | :--------------------------- | :------ | :----- |
{1}

**Summary:**

- Sentinel-onboarded workspaces: {2}
- Workspaces with both ``RiskyUsers`` and ``UserRiskEvents`` enabled via Entra diagnostic setting: {3}

'@

    $mdInfo = $formatTemplate -f $reportPortalUrl, $tableRows, $sentinelWorkspaces.Count, $passingWorkspaces.Count

    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '61016'
        Status = $passed
        Result = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
