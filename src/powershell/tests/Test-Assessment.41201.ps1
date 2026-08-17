<#
.SYNOPSIS
    Checks that at least one Microsoft (first-party) data connector is configured in every Sentinel-onboarded Log Analytics workspace.

.NOTES
    Test ID: 41201
    Workshop Task: SECOPS_093
    Pillar: SecOps
    Category: Security information and event management
    Required API: Azure Resource Manager (management.azure.com)
#>
function Test-Assessment-41201 {
    [ZtTest(
        Category = 'Security information and event management',
        ImplementationCost = 'Low',
        MinimumLicense = ('Consumption-based: Microsoft Sentinel'),
        Pillar = 'SecOps',
        RiskLevel = 'High',
        Service = ('Azure'),
        SfiPillar = 'Monitor and detect cyberthreats',
        TenantType = ('Workforce'),
        TestId = 41201,
        Title = 'At least one Microsoft (first-party) data connector is configured in every Microsoft Sentinel workspace',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    $testTitle = 'At least one Microsoft (first-party) data connector is configured in every Microsoft Sentinel workspace'

    #region Data Collection

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose
    $activity = 'Checking Microsoft first-party data connectors in Microsoft Sentinel workspaces'

    # Q1 + Q2 + onboarding check via shared helper.
    # Returns 'Forbidden'        on ARG 401/403 (Investigate).
    # Returns $null              on unexpected ARG failure (Investigate).
    # Returns 'NoSubscriptions'  when no enabled subscriptions are accessible (Skip).
    # Returns 'NoWorkspaces'     when no Log Analytics workspaces exist in scope (Skip).
    $allWorkspaces = Get-SentinelWorkspaceData -Activity $activity

    if ($null -eq $allWorkspaces) {
        $params = @{
            TestId       = '41201'
            Title        = $testTitle
            Status       = $false
            Result       = '⚠️ Azure Resource Graph returned an unexpected error while querying subscriptions or Log Analytics workspaces. This is likely a transient issue, please re-run the assessment.'
            CustomStatus = 'Investigate'
        }
        Add-ZtTestResultDetail @params
        return
    }

    if ($allWorkspaces -eq 'Forbidden') {
        $params = @{
            TestId       = '41201'
            Title        = $testTitle
            Status       = $false
            Result       = '⚠️ Azure Resource Graph returned insufficient permissions when querying subscriptions or workspaces. Ensure you have at least Reader access to the Azure subscriptions being tested.'
            CustomStatus = 'Investigate'
        }
        Add-ZtTestResultDetail @params
        return
    }

    if ($allWorkspaces -eq 'NoSubscriptions') {
        Write-PSFMessage 'No enabled subscriptions found — skipping Sentinel data connectors check.' -Tag Test -Level VeryVerbose
        Add-ZtTestResultDetail -SkippedBecause NotApplicable
        return
    }

    if ($allWorkspaces -eq 'NoWorkspaces') {
        Write-PSFMessage 'No Log Analytics workspaces found across accessible subscriptions — skipping Sentinel data connectors check.' -Tag Test -Level VeryVerbose
        Add-ZtTestResultDetail -SkippedBecause NotApplicable
        return
    }

    $checkableWorkspaces  = @($allWorkspaces | Where-Object { -not $_.PermissionError })
    $forbiddenWorkspaces  = @($allWorkspaces | Where-Object { $_.PermissionError })
    $onboardedWorkspaces  = @($checkableWorkspaces | Where-Object { $_.SentinelOnboarded })
    # An onboarding check that failed unexpectedly is unresolved data, not a confirmed 'not onboarded'.
    $unresolvedWorkspaces = @($checkableWorkspaces | Where-Object { $_.OnboardingError })

    if ($onboardedWorkspaces.Count -eq 0) {
        if ($forbiddenWorkspaces.Count -gt 0 -or $unresolvedWorkspaces.Count -gt 0) {
            # Auth or transient errors mean we cannot confirm whether those workspaces have Sentinel
            # onboarded; a passing workspace may exist among the ones that could not be checked.
            $params = @{
                TestId       = '41201'
                Title        = $testTitle
                Status       = $false
                Result       = '⚠️ One or more Log Analytics workspaces returned insufficient permissions or an unexpected error when checking Sentinel onboarding state. No Sentinel-onboarded workspace was confirmed among accessible workspaces — the overall state cannot be determined. Ensure Microsoft Sentinel Reader is granted on all workspaces and re-run the assessment.'
                CustomStatus = 'Investigate'
            }
            Add-ZtTestResultDetail @params
        }
        else {
            # Spec: no Sentinel-onboarded workspaces with full visibility — Skipped.
            Write-PSFMessage 'No Sentinel-onboarded workspaces found — skipping Sentinel data connectors check.' -Tag Test -Level VeryVerbose
            Add-ZtTestResultDetail -SkippedBecause NotApplicable
        }
        return
    }

    # Q1 (spec): List every data connector for each Sentinel-onboarded workspace.
    $dataConnectorsApiVersion = '2024-09-01'
    $connectorsByWorkspace = @{}

    foreach ($workspace in $onboardedWorkspaces) {
        Write-ZtProgress -Activity $activity -Status "Fetching data connectors for workspace '$($workspace.WorkspaceName)' in '$($workspace.SubscriptionName)'"
        $dataConnectorsPath = "$($workspace.WorkspaceId)/providers/Microsoft.SecurityInsights/dataConnectors?api-version=$dataConnectorsApiVersion"

        try {
            $workspaceConnectors = @()
            $nextPath = $dataConnectorsPath

            do {
                $response = Invoke-ZtAzureRequest -Path $nextPath -ErrorAction Stop

                if ($null -ne $response -and $response.PSObject.Properties['value']) {
                    $workspaceConnectors += @($response.value)
                    $nextPath = $response.nextLink
                }
                else {
                    $workspaceConnectors += @($response)
                    $nextPath = $null
                }
            } while ($nextPath)

            $connectorsByWorkspace[$workspace.WorkspaceId] = @($workspaceConnectors)
        }
        catch {
            $connectorsByWorkspace[$workspace.WorkspaceId] = $null
            Write-PSFMessage "Error querying data connectors for workspace '$($workspace.WorkspaceName)' in subscription '$($workspace.SubscriptionName)': $_" -Tag Test -Level Warning
        }
    }

    #endregion Data Collection

    #region Assessment Logic

    # Microsoft first-party connector kinds from the KnownDataConnectorKind enum (spec evaluation logic).
    $firstPartyKinds = [System.Collections.Generic.HashSet[string]]::new(
        [string[]]@(
            'AzureActiveDirectory', 'AzureActivityLog', 'AzureSecurityCenter', 'AzureAdvancedThreatProtection',
            'MicrosoftDefenderAdvancedThreatProtection', 'MicrosoftCloudAppSecurity', 'MicrosoftThreatProtection',
            'MicrosoftThreatIntelligence', 'Office365', 'OfficeATP', 'OfficeIRM', 'Office365Project',
            'OfficePowerBI', 'IOT', 'MicrosoftPurviewInformationProtection', 'Dynamics365'
        ),
        [System.StringComparer]::OrdinalIgnoreCase
    )

    $workspaceResults = foreach ($workspace in $onboardedWorkspaces) {
        $rawConnectors = $connectorsByWorkspace[$workspace.WorkspaceId]

        $totalConnectors   = 0
        $kindBreakdown     = ''
        $firstPartyPresent = @()
        $rowStatus         = 'Fail'

        if ($null -eq $rawConnectors) {
            $rowStatus = 'Investigate'
        }
        else {
            $totalConnectors   = $rawConnectors.Count
            $kindBreakdown     = (@($rawConnectors | Group-Object -Property kind | Sort-Object Name |
                ForEach-Object { "$($_.Name) ($($_.Count))" }) -join ', ')
            $firstPartyPresent = @($rawConnectors | Where-Object { $firstPartyKinds.Contains([string]$_.kind) } |
                Select-Object -ExpandProperty kind -Unique | Sort-Object)
            $rowStatus         = if ($firstPartyPresent.Count -ge 1) { 'Pass' } else { 'Fail' }
        }

        [PSCustomObject]@{
            SubscriptionName = $workspace.SubscriptionName
            SubscriptionId   = $workspace.SubscriptionId
            WorkspaceName    = $workspace.WorkspaceName
            ResourceGroup    = $workspace.ResourceGroup
            WorkspaceId      = $workspace.WorkspaceId
            TotalConnectors  = $totalConnectors
            ConnectorKinds   = $kindBreakdown
            FirstPartyKinds  = ($firstPartyPresent -join ', ')
            RowStatus        = $rowStatus
        }
    }
    $workspaceResults = @($workspaceResults)

    $investigateItems = @($workspaceResults | Where-Object { $_.RowStatus -eq 'Investigate' })
    $failedItems      = @($workspaceResults | Where-Object { $_.RowStatus -eq 'Fail' })

    # Pass only when every onboarded workspace has at least one Microsoft first-party connector and
    # no workspace was left unevaluated due to an API error or insufficient permissions.
    $passed       = $failedItems.Count -eq 0 -and $investigateItems.Count -eq 0 -and
                    $forbiddenWorkspaces.Count -eq 0 -and $unresolvedWorkspaces.Count -eq 0
    $customStatus = $null

    if ($investigateItems.Count -gt 0 -or $forbiddenWorkspaces.Count -gt 0 -or $unresolvedWorkspaces.Count -gt 0) {
        $customStatus       = 'Investigate'
        $testResultMarkdown = "⚠️ The data-connectors API returned an unexpected response for one or more workspaces, or one or more workspaces could not be checked due to insufficient permissions. Note that connectors configured exclusively via diagnostic settings are not returned by this API and require a separate check. Re-run after verifying Microsoft Sentinel Reader access on each affected workspace.`n`n%TestResult%"
    }
    elseif ($passed) {
        $testResultMarkdown = "✅ At least one Microsoft first-party data connector is configured in the Sentinel workspace.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "❌ No Microsoft first-party data connectors are configured in the Sentinel workspace.`n`n%TestResult%"
    }

    #endregion Assessment Logic

    #region Report Generation

    $azContext          = Get-AzContext -ErrorAction SilentlyContinue
    $portalHost         = if ($azContext -and $azContext.Environment.Name -eq 'AzureUSGovernment') { 'https://portal.azure.us' } else { 'https://portal.azure.com' }
    $portalSentinelLink = "$portalHost/#view/HubsExtension/BrowseResource/resourceType/microsoft.securityinsightsarg%2Fsentinel"
    $tableTitle         = 'Microsoft first-party data connectors per Sentinel workspace'

    $formatTemplate = @'


## [{0}]({1})

| Subscription | Workspace | Total connectors | Connectors by kind | Microsoft first-party connectors | Status |
| :----------- | :-------- | ---------------: | :----------------- | :------------------------------- | :----- |
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
        $subLink            = "$portalHost/#resource/subscriptions/$($result.SubscriptionId)"
        $encodedWorkspaceId = [System.Uri]::EscapeDataString($result.WorkspaceId)
        $connectorsLink     = "$portalHost/#view/Microsoft_Azure_Security_Insights/MainMenuBlade/~/DataConnectors/id/$encodedWorkspaceId"
        $subMd              = "[$(Get-SafeMarkdown $result.SubscriptionName)]($subLink)"
        $workspaceMd        = "[$(Get-SafeMarkdown $result.WorkspaceName)]($connectorsLink)"
        $allKindsMd         = if ($result.ConnectorKinds) { Get-SafeMarkdown -Text $result.ConnectorKinds } else { '—' }
        $kindsMd            = if ($result.FirstPartyKinds) { Get-SafeMarkdown -Text $result.FirstPartyKinds } else { '—' }
        $statusDisplay      = switch ($result.RowStatus) {
            'Pass'        { '✅ Pass' }
            'Fail'        { '❌ Fail' }
            'Investigate' { '⚠️ Investigate' }
        }
        $tableRows += "| $subMd | $workspaceMd | $($result.TotalConnectors) | $allKindsMd | $kindsMd | $statusDisplay |`n"
    }

    if ($hasMoreItems) {
        $remainingCount = $workspaceResults.Count - $maxDisplay
        $tableRows += "`n... and $remainingCount more. [View all in Microsoft Sentinel]($portalSentinelLink)`n"
    }

    $mdInfo             = $formatTemplate -f $tableTitle, $portalSentinelLink, $tableRows
    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo

    #endregion Report Generation

    $params = @{
        TestId = '41201'
        Title  = $testTitle
        Status = $passed
        Result = $testResultMarkdown
    }
    if ($customStatus) {
        $params.CustomStatus = $customStatus
    }

    Add-ZtTestResultDetail @params
}
