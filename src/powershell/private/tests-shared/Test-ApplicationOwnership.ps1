<#
.SYNOPSIS
    Common functions for testing enterprise application ownership and permissions.

.DESCRIPTION
    Functions used by application ownership tests (21770, 24518, 21867, etc.)
    to check applications with permissions, owners, and risk classifications.
#>

<#
.SYNOPSIS
    Get all applications with permissions, classified by risk level.

.DESCRIPTION
    This function queries ServicePrincipal objects with their associated Application data,
    enriches them with permission details and risk classifications.
    Used by tests 21770, 24518, and 21867.
#>

function Get-ApplicationsWithPermissions {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $Database
    )

    # Query ServicePrincipal objects with permissions (same SQL as Test-21770)
    # LEFT JOIN with Application to get owners and other app properties
    $sql = @"
select sp.id, sp.appId, sp.displayName, sp.appOwnerOrganizationId, sp.publisherName,
spsi.lastSignInActivity.lastSignInDateTime,
app.owners, app.signInAudience, app.publisherDomain
from main.ServicePrincipal sp
    left join main.ServicePrincipalSignIn spsi on spsi.appId = sp.appId
    left join main.Application app on app.appId = sp.appId
where sp.id in
    (
        select sp.id
        from main.ServicePrincipal sp
        where sp.oauth2PermissionGrants.scope is not null
    )
    or sp.id in
    (
        select distinct sp.id,
        from (select sp.id, sp.displayName, unnest(sp.appRoleAssignments).AppRoleId as appRoleId
            from main.ServicePrincipal sp) sp
            left join
                (select unnest(main.ServicePrincipal.appRoles).id as id, unnest(main.ServicePrincipal.appRoles)."value" permissionName
                from main.ServicePrincipal) spAppRole
                on sp.appRoleId = spAppRole.id
        where permissionName is not null
    )
order by spsi.lastSignInActivity.lastSignInDateTime
"@

    $results = Invoke-DatabaseQuery -Database $Database -Sql $sql

    Write-PSFMessage "Found $($results.Count) service principals with permissions from database" -Level Verbose

    if (-not $results -or $results.Count -eq 0) {
        return @()
    }

    # Enrich each app with permissions and risk classification (using Test-21770 pattern)
    $enrichedApps = @()

    foreach ($item in $results) {
        try {
            # Add delegate permissions
            $item = Add-DelegatePermissions -item $item -Database $Database

            # Add application permissions
            $item = Add-AppPermissions -item $item -Database $Database

            # Add risk classification
            $item = Add-GraphRisk $item

            # Add owner count from Application.owners field
            $ownerCount = 0
            if ($item.owners) {
                if ($item.owners -is [System.Collections.ICollection]) {
                    $ownerCount = $item.owners.Count
                } else {
                    try {
                        $ownersList = $item.owners | ConvertFrom-Json
                        $ownerCount = $ownersList.Count
                    } catch {
                        $ownerCount = 0
                    }
                }
            }
            $item | Add-Member -MemberType NoteProperty -Name 'OwnerCount' -Value $ownerCount -Force

            $enrichedApps += $item
        }
        catch {
            Write-PSFMessage "Error processing app $($item.displayName): $_" -Level Warning -ErrorRecord $_ -Tag Test
            continue
        }
    }

    Write-PSFMessage "Enriched $($enrichedApps.Count) applications with permissions and risk data" -Level Verbose

    return $enrichedApps
}

<#
.SYNOPSIS
    Get applications with insufficient owners based on privilege level.

.DESCRIPTION
    Filters applications from Get-ApplicationsWithPermissions based on owner count and privilege level.
    Used by tests 24518 and 21867.
#>

function Get-ApplicationsWithInsufficientOwners {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $Database,

        [Parameter(Mandatory = $true)]
        [ValidateSet('High', 'Medium', 'Low', 'ExcludeHigh')]
        [string]$PrivilegeLevel
    )

    # Get all apps with permissions
    $allApps = Get-ApplicationsWithPermissions -Database $Database

    # Filter by privilege level and owner count
    $filteredApps = @()

    foreach ($app in $allApps) {
        # Filter based on privilege level
        $matchesPrivilege = switch ($PrivilegeLevel) {
            'High' { $app.Risk -eq 'High' }
            'Medium' { $app.Risk -eq 'Medium' }
            'Low' { $app.Risk -eq 'Low' }
            'ExcludeHigh' { $app.IsRisky -and $app.Risk -ne 'High' }
        }

        if (-not $matchesPrivilege) {
            continue
        }

        # Only include apps with < 2 owners
        if ($app.OwnerCount -lt 2) {
            $filteredApps += $app
        }
    }

    Write-PSFMessage "Filtered to $($filteredApps.Count) applications with < 2 owners matching privilege level '$PrivilegeLevel'" -Level Verbose

    return $filteredApps
}


function Build-ApplicationOwnershipReport {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [array]$Applications,

        [Parameter(Mandatory = $true)]
        $Database
    )

    if ($Applications.Count -eq 0) {
        return ''
    }

    # Build table header
    $tableHeader =  "| App name | Multi-tenant | Permission  | Classification | Owner count |`n"
    $tableHeader += "| :-------- | :------------ | :---------- | :------------- | :----------- |`n"

    $tableRows = ''

    foreach ($app in $Applications) {
        $isMultiTenant = $app.signInAudience -eq 'AzureADMultipleOrgs'

        # Collect all unique permissions for display
        $allPermissions = @()
        if ($app.DelegatePermissions) { $allPermissions += $app.DelegatePermissions }
        if ($app.AppPermissions) { $allPermissions += $app.AppPermissions }

        $permList = if ($allPermissions.Count -gt 0) {
            ($allPermissions | Select-Object -Unique | Sort-Object) -join ', '
        } else {
            'None'
        }

        # Use the overall app Risk (already calculated by Get-GraphRisk)
        $classList = $app.Risk ?? 'Unranked'

        # Build clickable Entra portal link
        $entraLink = "https://entra.microsoft.com/#view/Microsoft_AAD_IAM/StartboardApplicationsMenuBlade/~/AppAppsPreview/objectId/$($app.id)"
        $safeDisplayName = Get-SafeMarkdown -Text $app.displayName
        $appLink = "[$safeDisplayName]($entraLink)"

        $tableRows += "| $appLink | $isMultiTenant | $permList | $classList | $($app.OwnerCount) |`n"
    }

    return $tableHeader + $tableRows
}

function Test-ApplicationOwnership {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $Database,

        [Parameter(Mandatory = $true)]
        [string]$TestId,

        [Parameter(Mandatory = $true)]
        [ValidateSet('High', 'Medium', 'Low', 'ExcludeHigh')]
        [string]$PrivilegeLevel,

        [Parameter(Mandatory = $true)]
        [string]$PassMessage,

        [Parameter(Mandatory = $true)]
        [string]$FailMessage,

        [Parameter(Mandatory = $true)]
        [string]$ReportTitle,

        [Parameter(Mandatory = $false)]
        [string]$Activity = 'Checking enterprise application ownership'
    )

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    Write-ZtProgress -Activity $Activity -Status 'Getting applications with insufficient owners'

    # Get applications based on privilege level
    $filteredApps = Get-ApplicationsWithInsufficientOwners -Database $Database -PrivilegeLevel $PrivilegeLevel

    # If no problematic apps found, test passes
    if ($filteredApps.Count -eq 0) {
        $passed = $true

        $params = @{
            TestId = $TestId
            Status = $passed
            Result = $PassMessage
        }
        Add-ZtTestResultDetail @params
        return
    }

    # Build report table for apps that failed the check
    Write-ZtProgress -Activity $Activity -Status 'Building report for applications with insufficient owners'

    $reportTable = Build-ApplicationOwnershipReport -Applications $filteredApps -Database $Database

    # Test fails if we have apps with insufficient owners
    $passed = $false
    $testResultMarkdown = "$FailMessage`n`n"
    $testResultMarkdown += "## $ReportTitle`n`n"
    $testResultMarkdown += $reportTable

    $params = @{
        TestId = $TestId
        Status = $passed
        Result = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
