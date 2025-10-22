<#
.SYNOPSIS
    Common functions for testing enterprise application ownership.

.DESCRIPTION
    This common function contains shared functions used by application ownership tests (24518, 21867, etc.)
    to check if applications have sufficient owners based on permission privilege levels.
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

    # Get applications from database that have permissions and < 2 owners (filtered at SQL level)
    $sqlApp = @"
SELECT
    id,
    appId,
    displayName,
    signInAudience,
    requiredResourceAccess,
    publisherDomain,
    owners
FROM Application
WHERE requiredResourceAccess IS NOT NULL
    AND requiredResourceAccess != '[]'
    AND (
        owners IS NULL
        OR owners = '[]'
        OR json_array_length(owners) < 2
    )
ORDER BY displayName
"@

    $applications = Invoke-DatabaseQuery -Database $Database -Sql $sqlApp

    Write-PSFMessage "Found $($applications.Count) applications with < 2 owners from database" -Level Verbose

    if (-not $applications -or $applications.Count -eq 0) {
        return @()
    }

    # Filter by permission classification using Get-GraphPermissionRisk (same logic as Test-21770)
    $filteredApps = @()

    foreach ($app in $applications) {
        try {
            # DuckDB returns complex types (like requiredResourceAccess) as .NET objects, not JSON strings
            # So we can use them directly without conversion
            $requiredResourceAccess = if ($app.requiredResourceAccess) {
                $app.requiredResourceAccess
            } else {
                @()
            }

            # Build delegate and application permission arrays from requiredResourceAccess
            $delegatePermissions = @()
            $applicationPermissions = @()

            foreach ($req in $requiredResourceAccess) {
                # DuckDB returns dictionaries, so access properties using dictionary syntax
                $resourceAppId = if ($req -is [System.Collections.IDictionary]) { $req['resourceAppId'] } else { $req.resourceAppId }
                $resourceAccess = if ($req -is [System.Collections.IDictionary]) { $req['resourceAccess'] } else { $req.resourceAccess }

                foreach ($perm in $resourceAccess) {
                    $permId = if ($perm -is [System.Collections.IDictionary]) { $perm['id'] } else { $perm.id }
                    $permType = if ($perm -is [System.Collections.IDictionary]) { $perm['type'] } else { $perm.type }

                    if ($permType -eq 'Role') {
                    # Application permission - query appRoles from ServicePrincipal
                    $appRoleSql = @"
SELECT DISTINCT appRole."value" as permissionName
FROM (
    SELECT unnest(appRoles) as appRole
    FROM ServicePrincipal
    WHERE appId = '$resourceAppId'
) roles
WHERE appRole.id = '$permId'
"@
                    $appRoleResult = Invoke-DatabaseQuery -Database $Database -Sql $appRoleSql | Select-Object -First 1
                    if ($appRoleResult -and $appRoleResult.permissionName) {
                        $applicationPermissions += $appRoleResult.permissionName
                    }
                } else {
                    # Delegated permission (Scope) - query oauth2PermissionScopes from Application.api
                    $scopeSql = @"
SELECT DISTINCT scope."value" as permissionName
FROM (
    SELECT unnest(api.oauth2PermissionScopes) as scope
    FROM Application
    WHERE appId = '$resourceAppId'
    AND api IS NOT NULL
    AND api.oauth2PermissionScopes IS NOT NULL
) scopes
WHERE scope.id = '$permId'
"@
                    $scopeResult = Invoke-DatabaseQuery -Database $Database -Sql $scopeSql | Select-Object -First 1
                    if ($scopeResult -and $scopeResult.permissionName) {
                        $delegatePermissions += $scopeResult.permissionName
                    }
                }
            }
        }

        # Add permissions to app object
        $app | Add-Member -MemberType NoteProperty -Name 'DelegatePermissions' -Value $delegatePermissions -Force
        $app | Add-Member -MemberType NoteProperty -Name 'AppPermissions' -Value $applicationPermissions -Force

        # Use Get-GraphRisk to determine risk level (same as Test-21770)
        $app.Risk = Get-GraphRisk -delegatePermissions $delegatePermissions -applicationPermissions $applicationPermissions
        $app.IsRisky = $app.Risk -eq "High" -or $app.Risk -eq "Medium" -or $app.Risk -eq "Low"

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

        # Get owner count from database field
        # DuckDB returns owners as a .NET List object, not JSON
        $ownerCount = 0
        if ($app.owners) {
            if ($app.owners -is [System.Collections.ICollection]) {
                $ownerCount = $app.owners.Count
            } else {
                # Fallback: if it's somehow a string, parse it
                try {
                    $ownersList = $app.owners | ConvertFrom-Json
                    $ownerCount = $ownersList.Count
                } catch {
                    $ownerCount = 0
                }
            }
        }
        $app | Add-Member -MemberType NoteProperty -Name 'OwnerCount' -Value $ownerCount -Force

        # Only include apps with < 2 owners
        if ($app.OwnerCount -lt 2) {
            $filteredApps += $app
        }
        }
        catch {
            Write-PSFMessage "Error processing app $($app.displayName): $_" -Level Warning -ErrorRecord $_ -Tag Test
            continue
        }
    }

    Write-PSFMessage "Filtered to $($filteredApps.Count) applications matching privilege level '$PrivilegeLevel'" -Level Verbose

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

        # Collect unique permissions and their risk classifications using Get-GraphPermissionRisk
        $permissionSet = @{}
        $classificationSet = @{}

        # Use the permissions already resolved in Get-ApplicationsWithInsufficientOwners
        if ($app.DelegatePermissions) {
            foreach ($permName in $app.DelegatePermissions) {
                $permissionSet[$permName] = $true
                $risk = Get-GraphPermissionRisk -Permission $permName -PermissionType 'Delegated'
                if ($risk -and $risk -ne 'Unranked') {
                    $classificationSet[$risk] = $true
                }
            }
        }

        if ($app.AppPermissions) {
            foreach ($permName in $app.AppPermissions) {
                $permissionSet[$permName] = $true
                $risk = Get-GraphPermissionRisk -Permission $permName -PermissionType 'Application'
                if ($risk -and $risk -ne 'Unranked') {
                    $classificationSet[$risk] = $true
                }
            }
        }

        $permList = if ($permissionSet.Count -gt 0) { ($permissionSet.Keys | Sort-Object) -join ', ' } else { 'None' }
        $classList = if ($classificationSet.Count -gt 0) { ($classificationSet.Keys | Sort-Object) -join ', ' } else { $app.Risk ?? 'Unknown' }

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
