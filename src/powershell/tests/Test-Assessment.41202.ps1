<#
.SYNOPSIS
    Checks that third-party (non-Microsoft) data connectors are configured in Microsoft Sentinel
    for non-Microsoft workloads in scope.

.NOTES
    Test ID: 41202
    Workshop Task: SECOPS_094
    Pillar: SecOps
    Category: Security information and event management
    Required API: Azure Resource Manager (management.azure.com)
#>
function Test-Assessment-41202 {
    [ZtTest(
        Category = 'Security information and event management',
        ImplementationCost = 'Medium',
        MinimumLicense = ('Consumption-based: Microsoft Sentinel'),
        Pillar = 'SecOps',
        RiskLevel = 'Medium',
        Service = ('Azure'),
        SfiPillar = 'Monitor and detect cyberthreats',
        TenantType = ('Workforce'),
        TestId = 41202,
        Title = 'Third-party (non-Microsoft) data connectors are configured in Microsoft Sentinel for non-Microsoft workloads in scope',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    $testTitle = 'Third-party (non-Microsoft) data connectors are configured in Microsoft Sentinel for non-Microsoft workloads in scope'

    #region Data Collection

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose
    $activity = 'Checking third-party data connectors in Microsoft Sentinel workspaces'
    $azContext = Get-AzContext -ErrorAction SilentlyContinue
    $tenantId = if ($azContext) { [string]$azContext.Tenant.Id } else { $null }
    # Identify the customer's publisher name so customer-authored codeless connectors (scope of 41203) are excluded from third-party classification.
    $customerPublisher = if ($tenantId) { Get-ZtTenantName -TenantId $tenantId } else { $null }
    if ($customerPublisher -eq $tenantId) {
        $customerPublisher = $null
    }

    # D1 + D2: workspace discovery and Sentinel onboarding check via shared helper.
    # Returns 'Forbidden'        on ARG 401/403 — Investigate.
    # Returns $null              on unexpected ARG failure — Investigate.
    # Returns 'NoSubscriptions'  when no enabled subscriptions accessible — Skip.
    # Returns 'NoWorkspaces'     when no Log Analytics workspaces found — Skip.
    # Returns array              per-workspace results; PermissionError/OnboardingError mark inaccessible workspaces.
    $allWorkspaces = Get-SentinelWorkspaceData -Activity $activity

    if ($null -eq $allWorkspaces) {
        $params = @{
            TestId       = '41202'
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
            TestId       = '41202'
            Title        = $testTitle
            Status       = $false
            Result       = '⚠️ Azure Resource Graph returned insufficient permissions when querying subscriptions or workspaces. Ensure you have at least Reader access to the Azure subscriptions being tested.'
            CustomStatus = 'Investigate'
        }
        Add-ZtTestResultDetail @params
        return
    }

    if ($allWorkspaces -eq 'NoSubscriptions') {
        Write-PSFMessage 'No enabled subscriptions found — skipping Sentinel third-party data connectors check.' -Tag Test -Level VeryVerbose
        Add-ZtTestResultDetail -SkippedBecause NotApplicable
        return
    }

    if ($allWorkspaces -eq 'NoWorkspaces') {
        Write-PSFMessage 'No Log Analytics workspaces found across accessible subscriptions — skipping Sentinel third-party data connectors check.' -Tag Test -Level VeryVerbose
        Add-ZtTestResultDetail -SkippedBecause NotApplicable
        return
    }

    $checkableWorkspaces  = @($allWorkspaces | Where-Object { -not $_.PermissionError })
    $forbiddenWorkspaces  = @($allWorkspaces | Where-Object { $_.PermissionError })
    $unresolvedWorkspaces = @($checkableWorkspaces | Where-Object { $_.OnboardingError })
    $onboardedWorkspaces  = @($checkableWorkspaces | Where-Object { $_.SentinelOnboarded })

    if ($onboardedWorkspaces.Count -eq 0) {
        # Spec: return Investigate (not Skipped) when no Sentinel-onboarded workspace can be evaluated.
        $params = @{
            TestId       = '41202'
            Title        = $testTitle
            Status       = $false
            Result       = '⚠️ No Sentinel-onboarded workspace could be evaluated in any accessible subscription. Confirm that Microsoft Sentinel is deployed on at least one Log Analytics workspace and that Microsoft Sentinel Reader is granted on all workspaces.'
            CustomStatus = 'Investigate'
        }
        Add-ZtTestResultDetail @params
        return
    }

    # Q1: data connectors list per onboarded workspace.
    # Q2: connector definitions, used as publisher fallback for codeless connectors with null Q1 publisher.
    $connectorsByWorkspace  = @{}
    $definitionsByWorkspace = @{}

    foreach ($workspace in $onboardedWorkspaces) {
        Write-ZtProgress -Activity $activity -Status "Fetching data connectors for workspace '$($workspace.WorkspaceName)' in '$($workspace.SubscriptionName)'"

        try {
            # Q1: GA 2024-09-01 returns empty for StaticUI/codeless connectors; preview version returns all.
            $q1Path = "$($workspace.WorkspaceId)/providers/Microsoft.SecurityInsights/dataConnectors?api-version=2023-12-01-preview"
            $connectorsByWorkspace[$workspace.WorkspaceId] = @(Invoke-ZtAzureRequest -Path $q1Path -ErrorAction Stop)
        }
        catch {
            $connectorsByWorkspace[$workspace.WorkspaceId] = $null
            Write-PSFMessage "Q1 error querying data connectors for workspace '$($workspace.WorkspaceName)' in subscription '$($workspace.SubscriptionName)': $_" -Tag Test -Level Warning
        }

        try {
            # Q2: definitions expose publisher for Codeless Connector Framework entries; fallback only.
            $q2Path = "$($workspace.WorkspaceId)/providers/Microsoft.SecurityInsights/dataConnectorDefinitions?api-version=2024-09-01"
            $definitionsByWorkspace[$workspace.WorkspaceId] = @(Invoke-ZtAzureRequest -Path $q2Path -ErrorAction Stop)
        }
        catch {
            $definitionsByWorkspace[$workspace.WorkspaceId] = $null
            Write-PSFMessage "Q2 error querying connector definitions for workspace '$($workspace.WorkspaceName)' in subscription '$($workspace.SubscriptionName)': $_" -Tag Test -Level Warning
        }
    }

    #endregion Data Collection

    #region Assessment Logic

    # Microsoft first-party kinds (inlined from spec 41201).
    # StaticUI (content-hub) connectors expose only { id } in connectorUiConfig and are first-party by definition.
    $microsoftFirstPartyKinds = @(
        'AzureActiveDirectory', 'AzureActivityLog', 'AzureSecurityCenter',
        'AzureAdvancedThreatProtection', 'MicrosoftDefenderAdvancedThreatProtection',
        'MicrosoftCloudAppSecurity', 'MicrosoftThreatProtection', 'MicrosoftThreatIntelligence',
        'Office365', 'OfficeATP', 'OfficeIRM', 'Office365Project', 'OfficePowerBI',
        'IOT', 'MicrosoftPurviewInformationProtection', 'Dynamics365',
        'ThreatIntelligence', 'ThreatIntelligenceTaxii'
    )
    # Dedicated cloud-platform connector kinds are always third-party.
    $thirdPartyCloudKinds = @('AmazonWebServicesCloudTrail', 'AmazonWebServicesS3', 'GCP')
    # Codeless Connector Framework kinds — classification is publisher-based.
    $codelessKinds       = @('GenericUI', 'APIPolling', 'RestApiPoller')
    $microsoftPublishers = @('Microsoft', 'Microsoft Corporation')

    $workspaceResults = foreach ($workspace in $onboardedWorkspaces) {
        $rawConnectors  = $connectorsByWorkspace[$workspace.WorkspaceId]
        $rawDefinitions = $definitionsByWorkspace[$workspace.WorkspaceId]

        $connectorRows     = @()
        $thirdPartyFound   = $false
        $hasUnclassifiable = $false

        if ($null -ne $rawConnectors) {
            # Build definition-publisher lookup for the Q2 fallback when Q1 list-item publisher is null/empty.
            $definitionPublishers = @{}
            foreach ($definition in @($rawDefinitions)) {
                if ($definition.name) {
                    $definitionPublishers[$definition.name] = $definition.properties.connectorUiConfig.publisher
                }
            }

            foreach ($connector in @($rawConnectors)) {
                $kind           = $connector.kind
                $publisher      = $null
                $classification = 'Unclassifiable'
                $connStatus     = 'Investigate'

                if ($kind -eq 'StaticUI') {
                    # Content-hub connector — first-party, publisher not surfaced by API.
                    $publisher      = '—'
                    $classification = 'Microsoft first-party'
                    $connStatus     = 'n/a'
                }
                elseif ($microsoftFirstPartyKinds -contains $kind) {
                    $publisher      = '—'
                    $classification = 'Microsoft first-party'
                    $connStatus     = 'n/a'
                }
                elseif ($thirdPartyCloudKinds -contains $kind) {
                    $publisher      = '—'
                    $classification = 'Third-party'
                    $connStatus     = 'Pass'
                    $thirdPartyFound = $true
                }
                elseif ($codelessKinds -contains $kind) {
                    # Resolve publisher: Q1 list-item first; Q2 definition as fallback.
                    $publisher = $connector.properties.connectorUiConfig.publisher
                    if ([string]::IsNullOrWhiteSpace($publisher)) {
                        $definitionName = $connector.properties.connectorDefinitionName
                        if ($definitionName) {
                            $publisher = $definitionPublishers[$definitionName]
                        }
                    }

                    if ([string]::IsNullOrWhiteSpace($publisher)) {
                        # Publisher unresolvable after Q1 + Q2 — unclassifiable.
                        $publisher         = '—'
                        $classification    = 'Unclassifiable'
                        $connStatus        = 'Investigate'
                        $hasUnclassifiable = $true
                    }
                    elseif ($customerPublisher -and $publisher -eq $customerPublisher) {
                        # Customer-authored codeless connector — out of scope (evaluated by spec 41203).
                        $classification = 'Custom (41203)'
                        $connStatus     = 'n/a'
                    }
                    elseif ($microsoftPublishers -contains $publisher) {
                        $classification = 'Microsoft first-party'
                        $connStatus     = 'n/a'
                    }
                    else {
                        # Non-Microsoft, non-customer publisher — third-party.
                        $classification = 'Third-party'
                        $connStatus     = 'Pass'
                        $thirdPartyFound = $true
                    }
                }
                else {
                    # Unknown kind — treat conservatively as unclassifiable.
                    $publisher         = '—'
                    $classification    = 'Unclassifiable'
                    $connStatus        = 'Investigate'
                    $hasUnclassifiable = $true
                }

                $connectorRows += [PSCustomObject]@{
                    ConnectorName   = $connector.name
                    Kind            = $kind
                    Publisher       = if ([string]::IsNullOrWhiteSpace($publisher)) { '—' } else { $publisher }
                    Classification  = $classification
                    ConnectorStatus = $connStatus
                }
            }
        }

        # Workspace roll-up: unresolved signals (unclassifiable connectors, Q1 error) take precedence over Pass.
        $rowStatus = if ($null -eq $rawConnectors) {
            'Investigate'
        }
        elseif ($thirdPartyFound -and -not $hasUnclassifiable) {
            'Pass'
        }
        else {
            'Investigate'
        }

        [PSCustomObject]@{
            SubscriptionName    = $workspace.SubscriptionName
            SubscriptionId      = $workspace.SubscriptionId
            WorkspaceName       = $workspace.WorkspaceName
            ResourceGroup       = $workspace.ResourceGroup
            WorkspaceId         = $workspace.WorkspaceId
            ConnectorRows       = $connectorRows
            ThirdPartyCount     = @($connectorRows | Where-Object { $_.Classification -eq 'Third-party' }).Count
            FirstPartyCount     = @($connectorRows | Where-Object { $_.Classification -eq 'Microsoft first-party' }).Count
            CustomCount         = @($connectorRows | Where-Object { $_.Classification -eq 'Custom (41203)' }).Count
            UnclassifiableCount = @($connectorRows | Where-Object { $_.Classification -eq 'Unclassifiable' }).Count
            RowStatus           = $rowStatus
        }
    }
    $workspaceResults = @($workspaceResults)

    # Add Investigate placeholders for permission-error and onboarding-error workspaces.
    $unresolvedWorkspaceResults = foreach ($workspace in @($forbiddenWorkspaces) + @($unresolvedWorkspaces)) {
        [PSCustomObject]@{
            SubscriptionName    = $workspace.SubscriptionName
            SubscriptionId      = $workspace.SubscriptionId
            WorkspaceName       = $workspace.WorkspaceName
            ResourceGroup       = $workspace.ResourceGroup
            WorkspaceId         = $workspace.WorkspaceId
            ConnectorRows       = @()
            ThirdPartyCount     = 0
            FirstPartyCount     = 0
            CustomCount         = 0
            UnclassifiableCount = 0
            RowStatus           = 'Investigate'
        }
    }
    $workspaceResults = @($workspaceResults) + @($unresolvedWorkspaceResults)

    # Tenant roll-up: Pass only when every evaluated workspace has at least one third-party connector.
    $investigateItems = @($workspaceResults | Where-Object { $_.RowStatus -eq 'Investigate' })
    $passedItems      = @($workspaceResults | Where-Object { $_.RowStatus -eq 'Pass' })

    $passed       = ($investigateItems.Count -eq 0) -and ($passedItems.Count -gt 0)
    $customStatus = if (-not $passed) { 'Investigate' } else { $null }

    if ($passed) {
        $testResultMarkdown = "✅ At least one third-party (non-Microsoft) data connector is configured in the Sentinel workspace.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "⚠️ No third-party data connector was found — confirm whether non-Microsoft workloads (AWS, GCP, on-premises Syslog/CEF, or third-party SaaS/security sources) are in scope, since the check cannot self-determine workload scope; or a connector's publisher could not be classified as Microsoft vs third-party; or a discovery, onboarding, Q1, or Q2 call returned an authorization failure, throttling, service error, or malformed response.`n`n%TestResult%"
    }

    #endregion Assessment Logic

    #region Report Generation

    $portalHost         = if ($azContext -and $azContext.Environment.Name -eq 'AzureUSGovernment') { 'https://portal.azure.us' } else { 'https://portal.azure.com' }
    $portalSentinelLink = "$portalHost/#view/HubsExtension/BrowseResource/resourceType/microsoft.securityinsightsarg%2Fsentinel"

    $formatTemplate = @'


## [{0}]({1})

| Subscription | Workspace | Connector name | Kind | Publisher | Classification | Status |
| :----------- | :-------- | :------------- | :--- | :-------- | :------------- | :----- |
{2}

### Workspace summary

| Subscription | Workspace | Third-party | Microsoft first-party | Custom (41203) | Unclassifiable | Status |
| :----------- | :-------- | :---------- | :-------------------- | :------------- | :------------- | :----- |
{3}
'@

    $connectorTableRows   = ''
    $workspaceSummaryRows = ''
    $maxDisplay           = 10
    $summaryRowCount      = 0
    $statusPriority       = @{ Investigate = 0; Pass = 1 }
    $sortedResults        = @($workspaceResults | Sort-Object { $statusPriority[$_.RowStatus] }, SubscriptionName, WorkspaceName)

    foreach ($wsResult in $sortedResults) {
        $subLink       = "$portalHost/#resource/subscriptions/$($wsResult.SubscriptionId)"
        $sentinelId    = "/subscriptions/$($wsResult.SubscriptionId)/resourcegroups/$($wsResult.ResourceGroup)/providers/microsoft.securityinsightsarg/sentinel/$($wsResult.WorkspaceName)"
        $connectorLink = "$portalHost/#view/Microsoft_Azure_Security_Insights/MainMenuBlade/~/DataConnectors/id/$($sentinelId -replace '/', '%2F')"
        $subMd         = "[$(Get-SafeMarkdown $wsResult.SubscriptionName)]($subLink)"
        $workspaceMd   = "[$(Get-SafeMarkdown $wsResult.WorkspaceName)]($connectorLink)"

        # Connector table: one row per connector; placeholder row when Q1 failed or zero connectors.
        if ($wsResult.ConnectorRows.Count -eq 0) {
            $wsStatusDisplay    = if ($wsResult.RowStatus -eq 'Pass') { '✅ Pass' } else { '⚠️ Investigate' }
            $connectorTableRows += "| $subMd | $workspaceMd | — | — | — | — | $wsStatusDisplay |`n"
        }
        else {
            foreach ($row in $wsResult.ConnectorRows) {
                $rowStatusDisplay = switch ($row.ConnectorStatus) {
                    'Pass'        { '✅ Pass' }
                    'Investigate' { '⚠️ Investigate' }
                    default       { 'n/a' }
                }
                $publisherMd        = if ($row.Publisher -eq '—') { '—' } else { Get-SafeMarkdown $row.Publisher }
                $connectorTableRows += "| $subMd | $workspaceMd | $(Get-SafeMarkdown $row.ConnectorName) | $($row.Kind) | $publisherMd | $($row.Classification) | $rowStatusDisplay |`n"
            }
        }

        # Workspace summary row — capped at $maxDisplay to match peer pattern.
        if ($summaryRowCount -lt $maxDisplay) {
            $wsStatusDisplay      = if ($wsResult.RowStatus -eq 'Pass') { '✅ Pass' } else { '⚠️ Investigate' }
            $workspaceSummaryRows += "| $subMd | $workspaceMd | $($wsResult.ThirdPartyCount) | $($wsResult.FirstPartyCount) | $($wsResult.CustomCount) | $($wsResult.UnclassifiableCount) | $wsStatusDisplay |`n"
            $summaryRowCount++
        }
    }

    if ($workspaceResults.Count -gt $maxDisplay) {
        $remaining             = $workspaceResults.Count - $maxDisplay
        $workspaceSummaryRows += "`n... and $remaining more. [View all in Microsoft Sentinel]($portalSentinelLink)`n"
    }

    $mdInfo             = $formatTemplate -f 'Data connectors per Sentinel workspace', $portalSentinelLink, $connectorTableRows, $workspaceSummaryRows
    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo

    #endregion Report Generation

    $params = @{
        TestId = '41202'
        Title  = $testTitle
        Status = $passed
        Result = $testResultMarkdown
    }
    if ($customStatus) {
        $params.CustomStatus = $customStatus
    }

    Add-ZtTestResultDetail @params
}
