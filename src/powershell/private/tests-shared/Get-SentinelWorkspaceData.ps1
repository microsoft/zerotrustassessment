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
        if ($_.Exception.Message -match '403|Forbidden') {
            Write-PSFMessage "Azure Resource Graph query returned 403 Forbidden — insufficient permissions to enumerate Log Analytics workspaces." -Tag Test -Level Warning
            return 'Forbidden'
        }
        Write-PSFMessage "Azure Resource Graph query failed: $($_.Exception.Message)" -Tag Test -Level Warning
        return $null
    }

    # Q3: For each workspace query the Sentinel onboarding state.
    # HTTP 200 = onboarded; HTTP 404 = not onboarded.
    # -FullResponse prevents a 404 from throwing so the status code can be inspected.
    $results = @()
    foreach ($workspace in $allWorkspaces) {
        Write-ZtProgress -Activity $Activity -Status "Checking Sentinel onboarding on workspace '$($workspace.workspaceName)'"

        $sentinelOnboarded = $false
        try {
            $sentinelPath = "$($workspace.workspaceId)/providers/Microsoft.SecurityInsights/onboardingStates/default?api-version=2024-03-01"
            $response = Invoke-ZtAzureRequest -Path $sentinelPath -FullResponse -ErrorAction Stop
            $sentinelOnboarded = ($response.StatusCode -eq 200)
        }
        catch {
            Write-PSFMessage "Error checking Sentinel onboarding for workspace '$($workspace.workspaceName)': $_" -Tag Test -Level Warning
        }

        $results += [PSCustomObject]@{
            SubscriptionName  = $workspace.subscriptionName
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
