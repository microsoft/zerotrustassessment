<#
.SYNOPSIS
    Checks interactive and total retention against the security baseline on every Sentinel-onboarded Log Analytics workspace.

.NOTES
    Test ID: 41204
    Workshop Task: SECOPS_096
    Pillar: SecOps
    Category: Security information and event management
    Required API: Azure Resource Manager (management.azure.com)
#>
function Test-Assessment-41204 {
    [ZtTest(
        Category = 'Security information and event management',
        ImplementationCost = 'Low',
        MinimumLicense = ('Consumption-based: Microsoft Sentinel'),
        Pillar = 'SecOps',
        RiskLevel = 'Medium',
        Service = ('Azure'),
        SfiPillar = 'Monitor and detect cyberthreats',
        TenantType = ('Workforce'),
        TestId = 41204,
        Title = 'Interactive and long-term retention duration meets the security baseline on every Microsoft Sentinel workspace',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose
    $activity = 'Checking retention settings in Microsoft Sentinel workspaces'

    # Sentinel workspace discovery and onboarding checks are provided by the shared helper.
    $allWorkspaces = Get-SentinelWorkspaceData -Activity $activity

    if ($null -eq $allWorkspaces -or $allWorkspaces -in @('Forbidden', 'NoSubscriptions', 'NoWorkspaces')) {
        $params = @{
            TestId       = '41204'
            Title        = 'Interactive and long-term retention duration meets the security baseline on every Microsoft Sentinel workspace'
            Status       = $false
            Result       = '⚠️ A workspace-discovery, onboarding, Q1, or Q2 call returned an authorization failure, throttling, service error, or malformed response; or a Sentinel-onboarded workspace exists but none of the security-relevant tables is present to evaluate.'
            CustomStatus = 'Investigate'
        }
        Add-ZtTestResultDetail @params
        return
    }

    $checkableWorkspaces  = @($allWorkspaces | Where-Object { -not $_.PermissionError })
    $forbiddenWorkspaces  = @($allWorkspaces | Where-Object { $_.PermissionError })
    $onboardedWorkspaces  = @($checkableWorkspaces | Where-Object { $_.SentinelOnboarded })
    $unresolvedWorkspaces = @($checkableWorkspaces | Where-Object { $_.OnboardingError })

    if ($onboardedWorkspaces.Count -eq 0) {
        $params = @{
            TestId       = '41204'
            Title        = 'Interactive and long-term retention duration meets the security baseline on every Microsoft Sentinel workspace'
            Status       = $false
            Result       = '⚠️ A workspace-discovery, onboarding, Q1, or Q2 call returned an authorization failure, throttling, service error, or malformed response; or a Sentinel-onboarded workspace exists but none of the security-relevant tables is present to evaluate.'
            CustomStatus = 'Investigate'
        }
        Add-ZtTestResultDetail @params
        return
    }

    $retentionByWorkspace = @{}
    foreach ($workspace in $onboardedWorkspaces) {
        $workspaceRetention = $null
        $tables             = $null
        $workspaceQueryError = $false
        $tablesQueryError    = $false

        # Q1: Retrieve workspace-level interactive retention.
        Write-ZtProgress -Activity $activity -Status "Fetching workspace retention for '$($workspace.WorkspaceName)' in '$($workspace.SubscriptionName)'"
        try {
            $workspaceRetention = Invoke-ZtAzureRequest -Path "$($workspace.WorkspaceId)?api-version=2023-09-01" -ErrorAction Stop
        }
        catch {
            $workspaceQueryError = $true
            Write-PSFMessage "Error querying retention for workspace '$($workspace.WorkspaceName)' in subscription '$($workspace.SubscriptionName)': $_" -Tag Test -Level Warning
        }

        # Q2: Retrieve table-level interactive and total retention.
        Write-ZtProgress -Activity $activity -Status "Fetching table retention for '$($workspace.WorkspaceName)' in '$($workspace.SubscriptionName)'"
        try {
            $tables = @(Invoke-ZtAzureRequest -Path "$($workspace.WorkspaceId)/tables?api-version=2026-03-01" -ErrorAction Stop)
        }
        catch {
            $tablesQueryError = $true
            Write-PSFMessage "Error querying table retention for workspace '$($workspace.WorkspaceName)' in subscription '$($workspace.SubscriptionName)': $_" -Tag Test -Level Warning
        }

        $retentionByWorkspace[$workspace.WorkspaceId] = [PSCustomObject]@{
            WorkspaceResponse   = $workspaceRetention
            Tables              = $tables
            WorkspaceQueryError = $workspaceQueryError
            TablesQueryError    = $tablesQueryError
        }
    }

    #endregion Data Collection

    #region Assessment Logic

    $securityRelevantTables = @(
        'SecurityEvent', 'SigninLogs', 'AuditLogs', 'AADNonInteractiveUserSignInLogs',
        'AADServicePrincipalSignInLogs', 'OfficeActivity', 'SecurityAlert', 'SecurityIncident',
        'CommonSecurityLog', 'Syslog', 'WindowsFirewall', 'DeviceLogonEvents',
        'IdentityLogonEvents', 'EmailEvents', 'CloudAppEvents'
    )

    $workspaceResults = @()
    $tableResults     = @()

    foreach ($workspace in $onboardedWorkspaces) {
        $collectedData = $retentionByWorkspace[$workspace.WorkspaceId]
        $workspaceRetentionDays = $null
        $workspaceCriterion     = 'Investigate'
        $workspaceReason        = ''
        $presentTableCount      = 0

        if ($collectedData.WorkspaceQueryError) {
            $workspaceReason = 'The workspace retention request failed.'
        }
        elseif ($null -eq $collectedData.WorkspaceResponse.properties.retentionInDays) {
            $workspaceReason = 'The workspace response did not contain retentionInDays.'
        }
        else {
            try {
                $workspaceRetentionDays = [int]$collectedData.WorkspaceResponse.properties.retentionInDays
                $workspaceCriterion = if ($workspaceRetentionDays -ge 90) { 'Pass' } else { 'Fail' }
            }
            catch {
                $workspaceReason = 'The workspace retentionInDays value was not an integer.'
            }
        }

        if ($collectedData.TablesQueryError) {
            foreach ($tableName in $securityRelevantTables) {
                $tableResults += [PSCustomObject]@{
                    SubscriptionName   = $workspace.SubscriptionName
                    SubscriptionId     = $workspace.SubscriptionId
                    WorkspaceName      = $workspace.WorkspaceName
                    WorkspaceId        = $workspace.WorkspaceId
                    TableName          = $tableName
                    RetentionInDays    = $null
                    TotalRetentionDays = $null
                    ArchiveDays        = $null
                    RowStatus          = 'Investigate'
                    StatusDetails      = 'The tables retention request failed.'
                }
            }
        }
        else {
            $tablesByName = @{}
            foreach ($table in $collectedData.Tables) {
                if ($table.name) {
                    $tablesByName[[string]$table.name] = $table
                }
            }
            $presentTableCount = @($securityRelevantTables | Where-Object { $tablesByName.ContainsKey($_) }).Count

            foreach ($tableName in $securityRelevantTables) {
                if (-not $tablesByName.ContainsKey($tableName)) {
                    $tableResults += [PSCustomObject]@{
                        SubscriptionName   = $workspace.SubscriptionName
                        SubscriptionId     = $workspace.SubscriptionId
                        WorkspaceName      = $workspace.WorkspaceName
                        WorkspaceId        = $workspace.WorkspaceId
                        TableName          = $tableName
                        RetentionInDays    = $null
                        TotalRetentionDays = $null
                        ArchiveDays        = $null
                        RowStatus          = 'N/A'
                        StatusDetails      = 'Not present/not ingested.'
                    }
                    continue
                }

                $table              = $tablesByName[$tableName]
                $tableRetentionDays = $null
                $totalRetentionDays = $null
                $archiveDays        = $null
                $tableStatus        = 'Investigate'
                $tableDetails       = ''

                if ($null -eq $table.properties.retentionInDays -or $null -eq $table.properties.totalRetentionInDays) {
                    $tableDetails = 'A required retention field was missing.'
                }
                else {
                    try {
                        $tableRetentionDays = [int]$table.properties.retentionInDays
                        $totalRetentionDays = [int]$table.properties.totalRetentionInDays
                        $archiveDays = if ($null -ne $table.properties.archiveRetentionInDays) {
                            [int]$table.properties.archiveRetentionInDays
                        }
                        else {
                            $totalRetentionDays - $tableRetentionDays
                        }
                        $tableStatus  = if ($totalRetentionDays -ge 365) { 'Pass' } else { 'Fail' }
                        $tableDetails = if ($tableStatus -eq 'Pass') { 'Total retention meets the 365-day threshold.' } else { 'Total retention is below the 365-day threshold.' }
                    }
                    catch {
                        $tableDetails = 'A required retention field was malformed.'
                    }
                }

                $tableResults += [PSCustomObject]@{
                    SubscriptionName   = $workspace.SubscriptionName
                    SubscriptionId     = $workspace.SubscriptionId
                    WorkspaceName      = $workspace.WorkspaceName
                    WorkspaceId        = $workspace.WorkspaceId
                    TableName          = $tableName
                    RetentionInDays    = $tableRetentionDays
                    TotalRetentionDays = $totalRetentionDays
                    ArchiveDays        = $archiveDays
                    RowStatus          = $tableStatus
                    StatusDetails      = $tableDetails
                }
            }
        }

        $workspaceTableResults = @($tableResults | Where-Object { $_.WorkspaceId -eq $workspace.WorkspaceId })
        $presentTableResults   = @($workspaceTableResults | Where-Object { $_.RowStatus -ne 'N/A' })
        $workspaceStatus       = 'Pass'

        if ($workspaceCriterion -eq 'Fail' -or @($presentTableResults | Where-Object { $_.RowStatus -eq 'Fail' }).Count -gt 0) {
            $workspaceStatus = 'Fail'
            $workspaceReason = 'The workspace default or a present table is below its retention threshold.'
        }
        elseif ($workspaceCriterion -eq 'Investigate' -or $collectedData.TablesQueryError -or @($presentTableResults | Where-Object { $_.RowStatus -eq 'Investigate' }).Count -gt 0) {
            $workspaceStatus = 'Investigate'
            if (-not $workspaceReason) {
                $workspaceReason = 'A required query or retention value could not be evaluated.'
            }
        }
        elseif ($presentTableResults.Count -eq 0) {
            $workspaceStatus = 'Investigate'
            $workspaceReason = 'None of the security-relevant tables is present to evaluate.'
        }
        else {
            $workspaceReason = 'The workspace default and all present tables meet their retention thresholds.'
        }

        $workspaceResults += [PSCustomObject]@{
            SubscriptionName      = $workspace.SubscriptionName
            SubscriptionId        = $workspace.SubscriptionId
            WorkspaceName         = $workspace.WorkspaceName
            WorkspaceId           = $workspace.WorkspaceId
            RetentionInDays       = $workspaceRetentionDays
            WorkspaceCriterionMet = $workspaceCriterion -eq 'Pass'
            PresentTableCount     = $presentTableCount
            RowStatus             = $workspaceStatus
            StatusDetails         = $workspaceReason
        }
    }

    foreach ($workspace in @($forbiddenWorkspaces) + @($unresolvedWorkspaces)) {
        $workspaceResults += [PSCustomObject]@{
            SubscriptionName      = $workspace.SubscriptionName
            SubscriptionId        = $workspace.SubscriptionId
            WorkspaceName         = $workspace.WorkspaceName
            WorkspaceId           = $workspace.WorkspaceId
            RetentionInDays       = $null
            WorkspaceCriterionMet = $false
            PresentTableCount     = 0
            RowStatus             = 'Investigate'
            StatusDetails         = 'The Sentinel onboarding state could not be determined.'
        }
    }

    $failedItems      = @($workspaceResults | Where-Object { $_.RowStatus -eq 'Fail' })
    $investigateItems = @($workspaceResults | Where-Object { $_.RowStatus -eq 'Investigate' })
    $passed           = $failedItems.Count -eq 0 -and $investigateItems.Count -eq 0
    $customStatus     = $null

    if ($failedItems.Count -gt 0) {
        $testResultMarkdown = "❌ The workspace default analytics retention is below 90 days, or a present security-relevant table has less than 365 days of total retention.`n`n%TestResult%"
    }
    elseif ($investigateItems.Count -gt 0) {
        $customStatus       = 'Investigate'
        $testResultMarkdown = "⚠️ A workspace-discovery, onboarding, Q1, or Q2 call returned an authorization failure, throttling, service error, or malformed response; or a Sentinel-onboarded workspace exists but none of the security-relevant tables is present to evaluate.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "✅ The workspace default analytics retention is at least 90 days, and every present security-relevant table has at least 365 days of total retention.`n`n%TestResult%"
    }

    #endregion Assessment Logic

    #region Report Generation
    $portalSentinelLink = "https://portal.azure.com/#browse/microsoft.securityinsightsarg%2Fsentinel"
    $workspaceTitle     = 'Retention summary per Microsoft Sentinel workspace'
    $tableTitle         = 'Retention details for security-relevant tables'

    $formatTemplate = @'


## [{0}]({1})

| Subscription | Workspace | Workspace analytics retention | Workspace criterion met | Present allow-listed tables | Workspace status | Reason |
| :----------- | :-------- | ----------------------------: | :---------------------- | --------------------------: | :--------------- | :----- |
{2}

## {3}

| Subscription | Workspace | Table | Analytics retention | Total retention | Archive retention | Status | Reason |
| :----------- | :-------- | :---- | ------------------: | --------------: | ----------------: | :----- | :----- |
{4}
'@

    $workspaceRows  = ''
    foreach ($result in $workspaceResults | Sort-Object SubscriptionName, WorkspaceName) {
        $subLink           = "https://portal.azure.com/#resource/subscriptions/$($result.SubscriptionId)"
        $workspaceLink     = "https://portal.azure.com/#resource$($result.WorkspaceId)"
        $subMd             = "[$(Get-SafeMarkdown $result.SubscriptionName)]($subLink)"
        $workspaceMd       = "[$(Get-SafeMarkdown $result.WorkspaceName)]($workspaceLink)"
        $retentionMd       = if ($null -eq $result.RetentionInDays) { '—' } else { "$($result.RetentionInDays) days" }
        $criterionMd       = if ($null -eq $result.RetentionInDays) { '—' } elseif ($result.WorkspaceCriterionMet) { '✅ Yes' } else { '❌ No' }
        $statusDisplay     = switch ($result.RowStatus) {
            'Pass'        { '✅ Pass' }
            'Fail'        { '❌ Fail' }
            'Investigate' { '⚠️ Investigate' }
        }
        $workspaceRows += "| $subMd | $workspaceMd | $retentionMd | $criterionMd | $($result.PresentTableCount) | $statusDisplay | $($result.StatusDetails) |`n"
    }

    $tableRows      = ''
    $maxDisplay     = 10
    $statusPriority = @{ Fail = 0; Investigate = 1; Pass = 2; 'N/A' = 3 }
    $displayResults = @($tableResults | Sort-Object { $statusPriority[$_.RowStatus] }, SubscriptionName, WorkspaceName, TableName)
    $hasMoreItems   = $displayResults.Count -gt $maxDisplay
    if ($hasMoreItems) {
        $displayResults = @($displayResults | Select-Object -First $maxDisplay)
    }

    foreach ($result in $displayResults) {
        $subLink             = "https://portal.azure.com/#resource/subscriptions/$($result.SubscriptionId)"
        $workspaceLink       = "https://portal.azure.com/#resource$($result.WorkspaceId)"
        $subMd               = "[$(Get-SafeMarkdown $result.SubscriptionName)]($subLink)"
        $workspaceMd         = "[$(Get-SafeMarkdown $result.WorkspaceName)]($workspaceLink)"
        $interactiveMd       = if ($null -eq $result.RetentionInDays) { '—' } else { "$($result.RetentionInDays) days" }
        $totalMd             = if ($null -eq $result.TotalRetentionDays) { '—' } else { "$($result.TotalRetentionDays) days" }
        $archiveMd           = if ($null -eq $result.ArchiveDays) { '—' } else { "$($result.ArchiveDays) days" }
        $statusDisplay       = switch ($result.RowStatus) {
            'Pass'        { '✅ Pass' }
            'Fail'        { '❌ Fail' }
            'N/A'         { 'N/A' }
            'Investigate' { '⚠️ Investigate' }
        }
        $tableRows += "| $subMd | $workspaceMd | $($result.TableName) | $interactiveMd | $totalMd | $archiveMd | $statusDisplay | $($result.StatusDetails) |`n"
    }

    if ($hasMoreItems) {
        $remainingCount = $tableResults.Count - $maxDisplay
        $tableRows += "| … | … | $remainingCount more of $($tableResults.Count) total | … | … | … | … | [View all in Microsoft Sentinel]($portalSentinelLink) |`n"
    }

    if (-not $tableRows) {
        $tableRows = '| No confirmed Sentinel-onboarded workspaces were available for table evaluation. | — | — | — | — | — | — | — |'
    }

    $mdInfo             = $formatTemplate -f $workspaceTitle, $portalSentinelLink, $workspaceRows, $tableTitle, $tableRows
    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo

    #endregion Report Generation

    $params = @{
        TestId = '41204'
        Title  = 'Interactive and long-term retention duration meets the security baseline on every Microsoft Sentinel workspace'
        Status = $passed
        Result = $testResultMarkdown
    }
    if ($customStatus) {
        $params.CustomStatus = $customStatus
    }

    Add-ZtTestResultDetail @params
}
