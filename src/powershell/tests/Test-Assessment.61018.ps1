<#
.SYNOPSIS
    Checks that the Microsoft Purview Information Protection Content Hub solution is installed on the Microsoft Sentinel workspace.

.DESCRIPTION
    Verifies that the Microsoft Purview Information Protection solution is installed from the Content Hub on at least one
    Microsoft Sentinel-onboarded Log Analytics workspace.

.NOTES
    Test ID: 61018
    Category: AI Threat Detection
    Pillar: AI
    Required API: Azure Resource Manager (management.azure.com)
    Depends on: 61002 (Sentinel onboarding precondition)
#>

# Enumerates all Log Analytics workspaces across accessible subscriptions using a single
# Azure Resource Graph query (spec Q1+Q2), then checks the Sentinel onboarding state for
# each workspace (spec Q3) via the Microsoft.SecurityInsights/onboardingStates/default endpoint.
#
# Returns an array of [PSCustomObject] (SubscriptionName, WorkspaceName, ResourceGroup,
# WorkspaceId, SentinelOnboarded).
# Returns $null when the ARG query fails so the caller can issue a skip.
function Get-SentinelWorkspaceData {
    [CmdletBinding()]
    param(
        [string]$Activity = 'Fetching Sentinel workspace data'
    )

    # Q1 + Q2: Single ARG query joins subscription names onto workspace records so one
    # round-trip covers both steps.  ARG respects caller RBAC automatically.
    $argQuery = @"
resources
| where type =~ 'microsoft.operationalinsights/workspaces'
| join kind=leftouter (
    resourcecontainers
    | where type =~ 'microsoft.resources/subscriptions'
    | where tostring(properties.state) =~ 'Enabled'
    | project subscriptionName=name, subscriptionId
) on subscriptionId
| project
    workspaceName=name,
    workspaceId=id,
    resourceGroup,
    subscriptionId,
    subscriptionName
| order by subscriptionName asc, workspaceName asc
"@

    Write-ZtProgress -Activity $Activity -Status 'Enumerating Log Analytics workspaces via Resource Graph'
    $allWorkspaces = @()
    try {
        $allWorkspaces = @(Invoke-ZtAzureResourceGraphRequest -Query $argQuery)
        Write-PSFMessage "ARG query returned $($allWorkspaces.Count) Log Analytics workspace(s)." -Tag Test -Level VeryVerbose
    }
    catch {
        $httpStatusCode = $null
        if ($_.Exception.Message -match 'with status (\d+):') {
            $httpStatusCode = [int]$Matches[1]
        }
        elseif ($_.Exception.Response) {
            $httpStatusCode = [int]$_.Exception.Response.StatusCode
        }

        if ($httpStatusCode -in @(401, 403)) {
            Write-PSFMessage "Azure Resource Graph query returned $httpStatusCode — insufficient permissions to enumerate Log Analytics workspaces." -Tag Test -Level Warning
            return 'Forbidden'
        }
        Write-PSFMessage "Azure Resource Graph query failed: $($_.Exception.Message)" -Tag Test -Level Warning
        return $null
    }

    # Q3: For each workspace query the Sentinel onboarding state.
    # HTTP 200 = onboarded; HTTP 404 = not onboarded; HTTP 401/403 = permission error.
    # -FullResponse prevents non-2xx responses from throwing so the status code can be
    # inspected explicitly.  Anything other than 200/404 is treated as an error.
    $results = @()
    foreach ($workspace in $allWorkspaces) {
        Write-ZtProgress -Activity $Activity -Status "Checking Sentinel onboarding on workspace '$($workspace.workspaceName)'"

        $sentinelOnboarded = $false
        try {
            $sentinelPath = "$($workspace.workspaceId)/providers/Microsoft.SecurityInsights/onboardingStates/default?api-version=2024-03-01"
            $response = Invoke-ZtAzureRequest -Path $sentinelPath -FullResponse -ErrorAction Stop

            switch ([int]$response.StatusCode) {
                200 { $sentinelOnboarded = $true }
                404 { $sentinelOnboarded = $false }
                { $_ -in @(401, 403) } {
                    Write-PSFMessage "Sentinel onboarding check for workspace '$($workspace.workspaceName)' returned $($response.StatusCode) — insufficient permissions." -Tag Test -Level Warning
                    return 'Forbidden'
                }
                default {
                    Write-PSFMessage "Sentinel onboarding check for workspace '$($workspace.workspaceName)' returned unexpected status $($response.StatusCode)." -Tag Test -Level Warning
                }
            }
        }
        catch {
            Write-PSFMessage "Error checking Sentinel onboarding for workspace '$($workspace.workspaceName)': $_" -Tag Test -Level Warning
        }

        $results += [PSCustomObject]@{
            SubscriptionName  = $workspace.subscriptionName
            SubscriptionId    = $workspace.subscriptionId
            WorkspaceName     = $workspace.workspaceName
            ResourceGroup     = $workspace.resourceGroup
            WorkspaceId       = $workspace.workspaceId
            SentinelOnboarded = $sentinelOnboarded
        }
    }

    # Use the unary comma operator so an empty array is preserved as an array
    # (not collapsed to $null by the pipeline) and the caller can distinguish
    # "no workspaces found" from an ARG failure ($null return above).
    return , $results
}

function Test-Assessment-61018 {
    [ZtTest(
        Category = 'AI Threat Detection',
        MinimumLicense = ('MIP_S_CLP1', 'Consumption-based: Microsoft Sentinel'),
        CompatibleLicense = ('MIP_S_CLP1'),
        ImplementationCost = 'Low',
        Pillar = 'AI',
        RiskLevel = 'Medium',
        Service = ('Azure'),
        SfiPillar = 'Monitor and detect cyberthreats',
        TenantType = ('Workforce'),
        TestId = 61018,
        Title = 'Microsoft Purview Information Protection data connector is enabled on the Microsoft Sentinel workspace',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose
    $activity = 'Checking Microsoft Purview Information Protection Content Hub solution on Sentinel workspaces'

    # Q1 + Q2 + onboarding check: returns 'Forbidden' on 401/403, $null on other failure.
    $allWorkspaces = Get-SentinelWorkspaceData -Activity $activity
    if ($null -eq $allWorkspaces -or $allWorkspaces -eq 'Forbidden') {
        $params = @{
            TestId = '61018'
            Title  = 'Microsoft Purview Information Protection data connector is enabled on the Microsoft Sentinel workspace'
            Status = $false
            Result = '❌ No Sentinel-onboarded workspace in tenant.'
        }
        Add-ZtTestResultDetail @params
        return
    }

    $workspaceResults = @()

    foreach ($workspace in ($allWorkspaces | Where-Object { $_.SentinelOnboarded })) {
        $packageName = 'Not found'
        $rowStatus   = 'Fail'

        # Q3: List installed Content Hub solutions and look for Microsoft Purview Information Protection
        Write-ZtProgress -Activity $activity -Status "Checking content packages on $($workspace.WorkspaceName) in subscription $($workspace.SubscriptionName)"
        $packagesPath = "$($workspace.WorkspaceId)/providers/Microsoft.SecurityInsights/contentPackages?api-version=2024-09-01"

        try {
            $packages   = @(Invoke-ZtAzureRequest -Path $packagesPath -ErrorAction Stop)
            $mipPackage = $packages | Where-Object { $_.properties.displayName -ieq 'Microsoft Purview Information Protection' } | Select-Object -First 1
            if ($mipPackage) {
                $packageName = 'Microsoft Purview Information Protection'
                $rowStatus   = 'Pass'
            }
        }
        catch {
            $packageName = 'Error'
            $rowStatus = 'Investigate'
            Write-PSFMessage "Error querying content packages for workspace '$($workspace.WorkspaceName)' in subscription '$($workspace.SubscriptionName)': $_" -Tag Test -Level Warning
        }

        $workspaceResults += [PSCustomObject]@{
            SubscriptionName = $workspace.SubscriptionName
            SubscriptionId   = $workspace.SubscriptionId
            WorkspaceName    = $workspace.WorkspaceName
            ResourceGroup    = $workspace.ResourceGroup
            WorkspaceId      = $workspace.WorkspaceId
            PackageName      = $packageName
            RowStatus        = $rowStatus
        }
    }

    #endregion Data Collection

    #region Assessment Logic

    $passedItems      = @($workspaceResults | Where-Object { $_.RowStatus -eq 'Pass' })
    $investigateItems = @($workspaceResults | Where-Object { $_.RowStatus -eq 'Investigate' })

    $passed       = $passedItems.Count -gt 0
    $customStatus = $null

    if (-not $passed -and $investigateItems.Count -gt 0) {
        $customStatus       = 'Investigate'
        $testResultMarkdown = "⚠️ The Content Hub API returned an authorization (401/403) or transient (5xx) error on at least one workspace, so the Microsoft Purview Information Protection solution state could not be determined for those workspaces. Re-run after verifying Microsoft Sentinel Reader on each affected workspace's resource group.`n`n%TestResult%"
    }
    elseif ($passed) {
        $testResultMarkdown = "✅ The Microsoft Purview Information Protection data connector is enabled on at least one Sentinel-onboarded workspace.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "❌ The Microsoft Purview Information Protection data connector is not enabled on any Sentinel-onboarded workspace.`n`n%TestResult%"
    }

    #endregion Assessment Logic

    #region Report Generation

    $portalSentinelLink = 'https://portal.azure.com/#view/HubsExtension/BrowseResource/resourceType/microsoft.securityinsightsarg%2Fsentinel'
    $tableTitle         = 'Sentinel Content Hub solutions per workspace'

    $formatTemplate = @'


## [{0}]({1})

| Subscription | Workspace | Content package | Status |
| :----------- | :-------- | :-------------- | :----- |
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
        $subLink            = "https://portal.azure.com/#resource/subscriptions/$($result.SubscriptionId)"
        $sentinelId         = "/subscriptions/$($result.SubscriptionId)/resourcegroups/$($result.ResourceGroup)/providers/microsoft.securityinsightsarg/sentinel/$($result.WorkspaceName)"
        $workspaceLink      = "https://portal.azure.com/#view/Microsoft_Azure_Security_Insights/MainMenuBlade/~/DataConnectors/id/$($sentinelId -replace '/', '%2F')"
        $subMd         = "[$(Get-SafeMarkdown $result.SubscriptionName)]($subLink)"
        $workspaceMd   = "[$(Get-SafeMarkdown $result.WorkspaceName)]($workspaceLink)"
        $packageMd     = $result.PackageName
        $statusDisplay = switch ($result.RowStatus) {
            'Pass'        { '✅ Pass' }
            'Fail'        { '❌ Fail' }
            'Investigate' { '⚠️ Investigate' }
        }
        $tableRows += "| $subMd | $workspaceMd | $packageMd | $statusDisplay |`n"
    }

    if ($hasMoreItems) {
        $remainingCount = $workspaceResults.Count - $maxDisplay
        $tableRows += "`n... and $remainingCount more. [View all in Microsoft Sentinel]($portalSentinelLink)`n"
    }

    $mdInfo             = $formatTemplate -f $tableTitle, $portalSentinelLink, $tableRows
    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo

    #endregion Report Generation

    $params = @{
        TestId = '61018'
        Title  = 'Microsoft Purview Information Protection data connector is enabled on the Microsoft Sentinel workspace'
        Status = $passed
        Result = $testResultMarkdown
    }
    if ($customStatus) {
        $params.CustomStatus = $customStatus
    }

    Add-ZtTestResultDetail @params
}
