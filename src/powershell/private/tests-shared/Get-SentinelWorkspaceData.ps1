# Enumerates all enabled subscriptions accessible to the caller (Q1), then enumerates all
# Log Analytics workspaces across those subscriptions (Q2) using separate Azure Resource Graph
# queries, then checks the Sentinel onboarding state for each workspace (Q3) via the
# Microsoft.SecurityInsights/onboardingStates/default endpoint.
#
# Returns an array of [PSCustomObject] (SubscriptionName, SubscriptionId, WorkspaceName,
# ResourceGroup, WorkspaceId, SentinelOnboarded, PermissionError).
#   PermissionError=$true means the Q3 Sentinel onboarding check returned 401/403 for that
#   workspace; SentinelOnboarded is $false in that case and must not be treated as a real result.
# Returns 'Forbidden'       when a 401/403 is received from Q1 or Q2 ARG queries.
# Returns 'NoSubscriptions' when Q1 succeeds but no enabled subscriptions are accessible.
# Returns 'NoWorkspaces'    when Q2 succeeds but no Log Analytics workspaces are found.
# Returns $null             when an unexpected ARG failure occurs.
function Get-SentinelWorkspaceData {
    [CmdletBinding()]
    param(
        [string]$Activity = 'Fetching Sentinel workspace data'
    )

    # Q1: Enumerate all enabled subscriptions accessible to the caller.
    $q1Query = @"
resourcecontainers
| where type =~ 'microsoft.resources/subscriptions'
| where tostring(properties.state) =~ 'Enabled'
| project subscriptionName=name, subscriptionId
| order by subscriptionName asc
"@

    Write-ZtProgress -Activity $Activity -Status 'Enumerating accessible subscriptions via Resource Graph (Q1)'
    $subscriptions = @()
    try {
        $subscriptions = @(Invoke-ZtAzureResourceGraphRequest -Query $q1Query)
        Write-PSFMessage "Q1 returned $($subscriptions.Count) enabled subscription(s)." -Tag Test -Level VeryVerbose
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
            Write-PSFMessage "Q1 Resource Graph query returned $httpStatusCode — insufficient permissions to enumerate subscriptions." -Tag Test -Level Warning
            return 'Forbidden'
        }
        Write-PSFMessage "Q1 Resource Graph query failed: $($_.Exception.Message)" -Tag Test -Level Warning
        return $null
    }

    if ($subscriptions.Count -eq 0) {
        Write-PSFMessage 'Q1 returned no enabled subscriptions accessible to the caller.' -Tag Test -Level Warning
        return 'NoSubscriptions'
    }

    # Q2: Enumerate all Log Analytics workspaces across accessible subscriptions.
    $q2Query = @"
resources
| where type =~ 'microsoft.operationalinsights/workspaces'
| project
    workspaceName=name,
    workspaceId=id,
    resourceGroup,
    subscriptionId
| order by workspaceName asc
"@

    Write-ZtProgress -Activity $Activity -Status 'Enumerating Log Analytics workspaces via Resource Graph (Q2)'
    $allWorkspaces = @()
    try {
        $allWorkspaces = @(Invoke-ZtAzureResourceGraphRequest -Query $q2Query)
        Write-PSFMessage "Q2 returned $($allWorkspaces.Count) Log Analytics workspace(s)." -Tag Test -Level VeryVerbose
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
            Write-PSFMessage "Q2 Resource Graph query returned $httpStatusCode — insufficient permissions to enumerate Log Analytics workspaces." -Tag Test -Level Warning
            return 'Forbidden'
        }
        Write-PSFMessage "Q2 Resource Graph query failed: $($_.Exception.Message)" -Tag Test -Level Warning
        return $null
    }

    if ($allWorkspaces.Count -eq 0) {
        Write-PSFMessage "Q2 returned no Log Analytics workspaces across $($subscriptions.Count) accessible subscription(s)." -Tag Test -Level Warning
        return 'NoWorkspaces'
    }

    # Build a subscription-name lookup from Q1 results for the client-side join.
    $subscriptionNameById = @{}
    foreach ($sub in $subscriptions) {
        $subscriptionNameById[$sub.subscriptionId] = $sub.subscriptionName
    }

    # Scope Q2 results to enabled subscriptions only.  ARG returns workspaces from all
    # accessible subscriptions regardless of state, so workspaces whose subscriptionId is
    # absent from $subscriptionNameById belong to disabled (or inaccessible) subscriptions
    # and must be excluded before Q3 and before the 'NoWorkspaces' guard.
    $allWorkspaces = @($allWorkspaces | Where-Object { $subscriptionNameById.ContainsKey($_.subscriptionId) })

    if ($allWorkspaces.Count -eq 0) {
        Write-PSFMessage "After scoping to enabled subscriptions, no Log Analytics workspaces remain." -Tag Test -Level Warning
        return 'NoWorkspaces'
    }

    # Q3: For each workspace query the Sentinel onboarding state.
    # HTTP 200 = onboarded; HTTP 404 = not onboarded; HTTP 401/403 = permission error.
    # -FullResponse prevents non-2xx responses from throwing so the status code can be
    # inspected explicitly.  Anything other than 200/404 is treated as an error.
    $results = @()
    foreach ($workspace in $allWorkspaces) {
        Write-ZtProgress -Activity $Activity -Status "Checking Sentinel onboarding on workspace '$($workspace.workspaceName)'"

        $sentinelOnboarded = $false
        $permissionError   = $false
        try {
            $sentinelPath = "$($workspace.workspaceId)/providers/Microsoft.SecurityInsights/onboardingStates/default?api-version=2024-03-01"
            $response = Invoke-ZtAzureRequest -Path $sentinelPath -FullResponse -ErrorAction Stop

            switch ([int]$response.StatusCode) {
                200 { $sentinelOnboarded = $true }
                404 { $sentinelOnboarded = $false }
                { $_ -in @(401, 403) } {
                    Write-PSFMessage "Sentinel onboarding check for workspace '$($workspace.workspaceName)' returned $($response.StatusCode) — insufficient permissions; marking and continuing." -Tag Test -Level Warning
                    $permissionError = $true
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
            SubscriptionName  = $subscriptionNameById[$workspace.subscriptionId]
            SubscriptionId    = $workspace.subscriptionId
            WorkspaceName     = $workspace.workspaceName
            ResourceGroup     = $workspace.resourceGroup
            WorkspaceId       = $workspace.workspaceId
            SentinelOnboarded = $sentinelOnboarded
            PermissionError   = $permissionError
        }
    }

    # Use the unary comma operator so an empty array is preserved as an array
    # (not collapsed to $null by the pipeline) and the caller can distinguish
    # "no workspaces found" from an ARG failure ($null return above).
    return , $results
}
