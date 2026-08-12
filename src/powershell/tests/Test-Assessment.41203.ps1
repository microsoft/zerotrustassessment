<#
.SYNOPSIS
    Checks that custom data connectors are configured in Microsoft Sentinel for in-scope sources
    without a built-in connector.

.NOTES
    Test ID: 41203
    Workshop Task: SECOPS_095
    Pillar: SecOps
    Category: Security information and event management
    Required API: Azure Resource Manager (management.azure.com)
#>
function Test-Assessment-41203 {
    [ZtTest(
        Category = 'Security information and event management',
        ImplementationCost = 'High',
        CompatibleLicense = ('Consumption-based: Microsoft Sentinel'),
        Pillar = 'SecOps',
        RiskLevel = 'Low',
        Service = ('Azure'),
        SfiPillar = 'Monitor and detect cyberthreats',
        TenantType = ('Workforce'),
        TestId = 41203,
        Title = 'Custom data connectors are configured in Microsoft Sentinel for in-scope sources without a built-in connector',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    $testTitle = 'Custom data connectors are configured in Microsoft Sentinel for in-scope sources without a built-in connector'

    #region Data Collection

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose
    $activity = 'Checking custom data connectors in Microsoft Sentinel workspaces'
    $azContext = Get-AzContext -ErrorAction SilentlyContinue
    $tenantId = if ($azContext) { [string]$azContext.Tenant.Id } else { $null }
    $customerPublisher = if ($tenantId) { Get-ZtTenantName -TenantId $tenantId } else { $null }
    if ($customerPublisher -eq $tenantId) {
        $customerPublisher = $null
    }

    # Q1 + Q2 + onboarding check via shared helper.
    # Returns 'Forbidden'        on ARG 401/403 (Investigate).
    # Returns $null              on unexpected ARG failure (Investigate).
    # Returns 'NoSubscriptions'  when no enabled subscriptions are accessible (Skip).
    # Returns 'NoWorkspaces'     when no Log Analytics workspaces exist in scope (Skip).
    $allWorkspaces = Get-SentinelWorkspaceData -Activity $activity

    if ($null -eq $allWorkspaces) {
        $params = @{
            TestId       = '41203'
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
            TestId       = '41203'
            Title        = $testTitle
            Status       = $false
            Result       = '⚠️ Azure Resource Graph returned insufficient permissions when querying subscriptions or workspaces. Ensure you have at least Reader access to the Azure subscriptions being tested.'
            CustomStatus = 'Investigate'
        }
        Add-ZtTestResultDetail @params
        return
    }

    if ($allWorkspaces -eq 'NoSubscriptions') {
        Write-PSFMessage 'No enabled subscriptions found — skipping Sentinel custom data connectors check.' -Tag Test -Level VeryVerbose
        Add-ZtTestResultDetail -SkippedBecause NotApplicable
        return
    }

    if ($allWorkspaces -eq 'NoWorkspaces') {
        Write-PSFMessage 'No Log Analytics workspaces found across accessible subscriptions — skipping Sentinel custom data connectors check.' -Tag Test -Level VeryVerbose
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
            # Auth errors mean we cannot confirm whether those workspaces have Sentinel onboarded;
            # a passing workspace may exist among the inaccessible ones.
            $params = @{
                TestId       = '41203'
                Title        = $testTitle
                Status       = $false
                Result       = '⚠️ One or more Log Analytics workspaces returned insufficient permissions or an unexpected error when checking Sentinel onboarding state. No Sentinel-onboarded workspace was confirmed among accessible workspaces — the overall state cannot be determined. Ensure Microsoft Sentinel Reader is granted on all workspaces and re-run the assessment.'
                CustomStatus = 'Investigate'
            }
            Add-ZtTestResultDetail @params
        }
        else {
            # Spec: no Sentinel-onboarded workspaces with full visibility — Skipped.
            Write-PSFMessage 'No Sentinel-onboarded workspaces found — skipping Sentinel custom data connectors check.' -Tag Test -Level VeryVerbose
            Add-ZtTestResultDetail -SkippedBecause NotApplicable
        }
        return
    }

    # Q1: data connectors, Q2: codeless connector definitions, per Sentinel-onboarded workspace.
    # Invoke-ZtAzureRequest paginates automatically (Paginate=$true for GET) and unwraps .value.
    $connectorsByWorkspace  = @{}
    $definitionsByWorkspace = @{}

    foreach ($workspace in $onboardedWorkspaces) {
        Write-ZtProgress -Activity $activity -Status "Fetching data connectors for workspace '$($workspace.WorkspaceName)' in '$($workspace.SubscriptionName)'"

        try {
            # api-version 2024-09-01 rejects the GenericUI/APIPolling kinds; only the preview version returns them.
            $connectorsByWorkspace[$workspace.WorkspaceId] = @(Invoke-ZtAzureRequest -Path "$($workspace.WorkspaceId)/providers/Microsoft.SecurityInsights/dataConnectors?api-version=2021-03-01-preview" -ErrorAction Stop)
        }
        catch {
            $connectorsByWorkspace[$workspace.WorkspaceId] = $null
            Write-PSFMessage "Error querying data connectors for workspace '$($workspace.WorkspaceName)' in subscription '$($workspace.SubscriptionName)': $_" -Tag Test -Level Warning
        }

        try {
            $definitionsByWorkspace[$workspace.WorkspaceId] = @(Invoke-ZtAzureRequest -Path "$($workspace.WorkspaceId)/providers/Microsoft.SecurityInsights/dataConnectorDefinitions?api-version=2024-09-01" -ErrorAction Stop)
        }
        catch {
            $definitionsByWorkspace[$workspace.WorkspaceId] = $null
            Write-PSFMessage "Error querying data connector definitions for workspace '$($workspace.WorkspaceName)' in subscription '$($workspace.SubscriptionName)': $_" -Tag Test -Level Warning
        }
    }

    #endregion Data Collection

    #region Assessment Logic

    # Codeless / custom-builder connector kinds per KnownDataConnectorKind.
    $codelessKinds = @('GenericUI', 'APIPolling')
    # A non-Microsoft publisher is not sufficient evidence of customer authorship because it may be a partner.
    $builtInPublishers = @('Microsoft', 'Microsoft Corporation')

    $workspaceResults = foreach ($workspace in $onboardedWorkspaces) {
        $rawConnectors  = $connectorsByWorkspace[$workspace.WorkspaceId]
        $rawDefinitions = $definitionsByWorkspace[$workspace.WorkspaceId]

        $codelessConnectors = @()
        $customConnectors   = @()
        $customDefinitions  = @()
        $rowStatus          = 'Fail'

        if ($null -eq $rawConnectors) {
            # API error for this workspace — cannot determine connector state.
            $rowStatus = 'Investigate'
        }
        else {
            # Definition publishers let a connector that omits connectorUiConfig.publisher still be classified.
            $definitionPublishers = @{}
            foreach ($definition in $rawDefinitions) {
                $definitionPublishers[$definition.name] = $definition.properties.connectorUiConfig.publisher
            }

            $customDefinitions = @($rawDefinitions | Where-Object {
                $customerPublisher -and $_.properties.connectorUiConfig.publisher -eq $customerPublisher
            })

            $codelessConnectors = foreach ($connector in @($rawConnectors | Where-Object { $codelessKinds -contains $_.kind })) {
                $publisher = $connector.properties.connectorUiConfig.publisher
                $definitionName = $connector.properties.connectorDefinitionName
                if ([string]::IsNullOrWhiteSpace($publisher) -and $definitionName) {
                    $publisher = $definitionPublishers[$definitionName]
                }

                [PSCustomObject]@{
                    Title          = if ($connector.properties.connectorUiConfig.title) { $connector.properties.connectorUiConfig.title } else { $connector.name }
                    Publisher      = $publisher
                    DefinitionName = $definitionName
                    IsCustom       = $customerPublisher -and $publisher -eq $customerPublisher
                    IsUnresolved   = [string]::IsNullOrWhiteSpace($publisher) -or ($builtInPublishers -notcontains $publisher -and $publisher -ne $customerPublisher)
                }
            }
            $codelessConnectors = @($codelessConnectors)
            $customConnectors   = @($codelessConnectors | Where-Object IsCustom)

            $rowStatus = if ($null -eq $rawDefinitions) {
                # Q2 errors make the workspace unresolved even when Q1 contains an apparent custom connector.
                'Investigate'
            }
            elseif ($customConnectors.Count -ge 1) {
                'Pass'
            }
            elseif (@($codelessConnectors | Where-Object IsUnresolved).Count -gt 0) {
                # Missing or third-party publisher data cannot establish customer authorship.
                'Investigate'
            }
            else {
                'Fail'
            }
        }

        [PSCustomObject]@{
            SubscriptionName      = $workspace.SubscriptionName
            SubscriptionId        = $workspace.SubscriptionId
            WorkspaceName         = $workspace.WorkspaceName
            ResourceGroup         = $workspace.ResourceGroup
            WorkspaceId           = $workspace.WorkspaceId
            CodelessConnectors    = $codelessConnectors
            CustomConnectorCount  = $customConnectors.Count
            CustomDefinitionCount = if ($null -eq $rawDefinitions) { $null } else { $customDefinitions.Count }
            RowStatus             = $rowStatus
        }
    }
    $workspaceResults = @($workspaceResults)

    $unresolvedWorkspaceResults = foreach ($workspace in @($forbiddenWorkspaces) + @($unresolvedWorkspaces)) {
        [PSCustomObject]@{
            SubscriptionName      = $workspace.SubscriptionName
            SubscriptionId        = $workspace.SubscriptionId
            WorkspaceName         = $workspace.WorkspaceName
            ResourceGroup         = $workspace.ResourceGroup
            WorkspaceId           = $workspace.WorkspaceId
            CodelessConnectors    = @()
            CustomConnectorCount  = 0
            CustomDefinitionCount = $null
            RowStatus             = 'Investigate'
        }
    }
    $workspaceResults = @($workspaceResults) + @($unresolvedWorkspaceResults)

    $passedItems      = @($workspaceResults | Where-Object { $_.RowStatus -eq 'Pass' })
    $investigateItems = @($workspaceResults | Where-Object { $_.RowStatus -eq 'Investigate' })

    $hasUnresolved = $investigateItems.Count -gt 0 -or $forbiddenWorkspaces.Count -gt 0 -or $unresolvedWorkspaces.Count -gt 0
    $passed       = -not $hasUnresolved -and $passedItems.Count -gt 0
    $customStatus = $null

    if ($hasUnresolved) {
        $customStatus       = 'Investigate'
        $testResultMarkdown = "⚠️ The codeless connector inventory could not be classified as customer-authored versus partner-authored from the API response.`n`n%TestResult%"
    }
    elseif ($passed) {
        $testResultMarkdown = "✅ At least one custom data connector is configured in the Sentinel workspace.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "❌ No custom data connectors are configured.`n`n%TestResult%"
    }

    #endregion Assessment Logic

    #region Report Generation

    $portalHost         = if ($azContext -and $azContext.Environment.Name -eq 'AzureUSGovernment') { 'https://portal.azure.us' } else { 'https://portal.azure.com' }
    $portalSentinelLink = "$portalHost/#view/HubsExtension/BrowseResource/resourceType/microsoft.securityinsightsarg%2Fsentinel"
    $tableTitle         = 'Custom data connectors per Sentinel workspace'

    $formatTemplate = @'


## [{0}]({1})

| Subscription | Workspace | Codeless connectors | Publishers | Connector definitions | Custom definitions | Status |
| :----------- | :-------- | :------------------ | :--------- | :-------------------- | :----------------- | :----- |
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
        $subLink       = "$portalHost/#resource/subscriptions/$($result.SubscriptionId)"
        $sentinelId    = "/subscriptions/$($result.SubscriptionId)/resourcegroups/$($result.ResourceGroup)/providers/microsoft.securityinsightsarg/sentinel/$($result.WorkspaceName)"
        $connectorLink = "$portalHost/#view/Microsoft_Azure_Security_Insights/MainMenuBlade/~/DataConnectors/id/$($sentinelId -replace '/', '%2F')"
        $subMd         = "[$(Get-SafeMarkdown $result.SubscriptionName)]($subLink)"
        $workspaceMd   = "[$(Get-SafeMarkdown $result.WorkspaceName)]($connectorLink)"
        $definitionsMd = if ($null -eq $result.CustomDefinitionCount) { '—' } else { $result.CustomDefinitionCount }
        $statusDisplay = switch ($result.RowStatus) {
            'Pass'        { '✅ Pass' }
            'Fail'        { '❌ Fail' }
            'Investigate' { '⚠️ Investigate' }
        }

        if ($result.CodelessConnectors.Count -gt 0) {
            $titlesMd     = ($result.CodelessConnectors | ForEach-Object { Get-SafeMarkdown $_.Title }) -join ', '
            $publishersMd = ($result.CodelessConnectors | ForEach-Object { if ($_.Publisher) { Get-SafeMarkdown $_.Publisher } else { 'Unknown' } }) -join ', '
            $namesMd      = ($result.CodelessConnectors | ForEach-Object { if ($_.DefinitionName) { Get-SafeMarkdown $_.DefinitionName } else { '—' } }) -join ', '
            $tableRows   += "| $subMd | $workspaceMd | $titlesMd | $publishersMd | $namesMd | $definitionsMd | $statusDisplay |`n"
        }
        else {
            # No codeless connectors (Fail) or API error (Investigate) — one placeholder row so the workspace appears in the table.
            $tableRows += "| $subMd | $workspaceMd | — | — | — | $definitionsMd | $statusDisplay |`n"
        }
    }

    if ($hasMoreItems) {
        $remainingCount = $workspaceResults.Count - $maxDisplay
        $tableRows += "`n... and $remainingCount more. [View all in Microsoft Sentinel]($portalSentinelLink)`n"
    }

    $mdInfo             = $formatTemplate -f $tableTitle, $portalSentinelLink, $tableRows
    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo

    #endregion Report Generation

    $params = @{
        TestId = '41203'
        Title  = $testTitle
        Status = $passed
        Result = $testResultMarkdown
    }
    if ($customStatus) {
        $params.CustomStatus = $customStatus
    }

    Add-ZtTestResultDetail @params
}
