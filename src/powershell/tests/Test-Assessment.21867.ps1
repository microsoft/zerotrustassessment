<#
.SYNOPSIS
    Tests if all enterprise applications with high privilege permissions have at least two owners.
#>

function Test-Assessment-21867 {
    [ZtTest(
    	Category = 'Application management',
    	ImplementationCost = 'Medium',
    	Pillar = 'Identity',
    	RiskLevel = 'High',
    	SfiPillar = 'Monitor and detect cyberthreats',
    	TenantType = ('Workforce','External'),
    	TestId = 21867,
    	Title = 'Enterprise applications with high privilege Microsoft Graph API permissions have owners',
    	UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param(
        $Database
    )

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking if enterprise applications with high privilege permissions have owners'
    Write-ZtProgress -Activity $activity -Status 'Getting applications with resource access from database'

    # Q1: Get only applications that have requiredResourceAccess (filter at database level to avoid loading all apps)
    $sqlApplications = @"
SELECT
    id,
    appId,
    displayName,
    requiredResourceAccess,
    signInAudience,
    publisherDomain
FROM Application
WHERE requiredResourceAccess IS NOT NULL
    AND requiredResourceAccess != '[]'
    AND len(requiredResourceAccess) > 0
ORDER BY displayName
"@

    $applicationsWithPermissions = Invoke-DatabaseQuery -Database $Database -Sql $sqlApplications

    Write-ZtProgress -Activity $activity -Status 'Filtering applications with high privilege permissions'

    $highPrivApps = @()

    # Filter applications that have high privilege permissions
    foreach ($app in $applicationsWithPermissions) {
        $delegatePermissions = @()
        $applicationPermissions = @()
        try {
            $resourceAccess = $null
            if ($app.requiredResourceAccess -is [System.Collections.IEnumerable] -and $app.requiredResourceAccess -isnot [string]) {
                $resourceAccess = $app.requiredResourceAccess
            } else {
                $resourceAccess = $app.requiredResourceAccess | ConvertFrom-Json
            }
            foreach ($resource in $resourceAccess) {
                    if ($resource.resourceAccess) {
                        foreach ($permission in $resource.resourceAccess) {
                            $permType = if ($permission.type -eq 'Role') { 'Application' } else { 'Delegated' }
                            $permissionName = $null
                            try {
                                $resourceSP = Invoke-ZtGraphRequest -RelativeUri "servicePrincipals?`$filter=appId eq '$($resource.resourceAppId)'" -ApiVersion beta
                                if ($resourceSP -and $resourceSP.Count -gt 0) {
                                    if ($permType -eq 'Application') {
                                        $permObj = $resourceSP[0].appRoles | Where-Object { $_.id -eq $permission.id }
                                    } else {
                                        $permObj = $resourceSP[0].oauth2PermissionScopes | Where-Object { $_.id -eq $permission.id }
                                    }
                                    if ($permObj) {
                                        $permissionName = $permObj.value
                                    }
                                }
                            } catch {
                                Write-PSFMessage "Failed to resolve permission $($permission.id) for resource $($resource.resourceAppId)" -Level Verbose
                            }
                            if ($permissionName) {
                                if ($permType -eq 'Application') {
                                    $applicationPermissions += $permissionName
                                } else {
                                    $delegatePermissions += $permissionName
                                }
                            }
                        }
                    }
                }
        } catch {
            Write-PSFMessage "Failed to parse requiredResourceAccess for app $($app.displayName): $($_.Exception.Message)" -Level Verbose
            continue
        }
        $app.DelegatePermissions = $delegatePermissions
        $app.AppPermissions = $applicationPermissions
        $app = Add-GraphRisk $app
        if ($app.IsRisky) {
            $app | Add-Member -MemberType NoteProperty -Name 'HighPrivPermissions' -Value ((@($delegatePermissions + $applicationPermissions) -join ', ')) -Force
            $highPrivApps += $app
        }
    }

    if ($highPrivApps.Count -eq 0) {
        $testResultMarkdown = 'All enterprise applications with high privilege have owners'
        $testPassed = $true
    } else {
        Write-ZtProgress -Activity $activity -Status 'Checking owners for high privilege applications'

        $failedApps = @()

        foreach ($app in $highPrivApps) {
            Write-ZtProgress -Activity $activity -Status "Checking owners for $($app.displayName)"
            try {
                $owners = Invoke-ZtGraphRequest -RelativeUri "applications/$($app.id)/owners" -ApiVersion beta
                $ownerCount = if ($owners) { $owners.Count } else { 0 }
                if ($ownerCount -lt 2) {
                    $failedApps += @{
                        AppName = $app.displayName
                        AppId = $app.appId
                        IsMultiTenant = $app.signInAudience -eq 'AzureADMultipleOrgs'
                        OrgId = if ($app.signInAudience -eq 'AzureADMultipleOrgs') { $app.publisherDomain } else { 'N/A' }
                        Permissions = $app.HighPrivPermissions
                        PermissionClassification = 'High'
                        OwnerCount = $ownerCount
                    }
                }
            } catch {
                Write-PSFMessage "Failed to get owners for app $($app.displayName): $($_.Exception.Message)" -Level Warning
                $failedApps += @{
                    AppName = $app.displayName
                    AppId = $app.appId
                    IsMultiTenant = $app.signInAudience -eq 'AzureADMultipleOrgs'
                    OrgId = if ($app.signInAudience -eq 'AzureADMultipleOrgs') { $app.publisherDomain } else { 'N/A' }
                    Permissions = $app.HighPrivPermissions
                    PermissionClassification = 'High'
                    OwnerCount = 0
                }
            }
        }

        $testPassed = $failedApps.Count -eq 0

        if ($testPassed) {
            $testResultMarkdown = 'All enterprise applications with high privilege have owners'
        } else {
            $testResultMarkdown = "Not all enterprise applications with high privilege permissions have owners`n`n"
            $testResultMarkdown += "## Applications lacking sufficient owners`n`n"
            $testResultMarkdown += "| App name | Multi-tenant | Org id | Permissions | Classification | Owners |`n"
            $testResultMarkdown += "|----------|--------------|---------|-------------|----------------|--------|`n"

            foreach ($app in $failedApps) {
                $portalLink = "https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Owners/appId/$($app.AppId)/isMSAApp~/false"
                $testResultMarkdown += "| [$(Get-SafeMarkdown -Text $app.AppName)]($portalLink) | $($app.IsMultiTenant) | $($app.OrgId) | $($app.Permissions) | $($app.PermissionClassification) | $($app.OwnerCount) |`n"
            }
        }
    }

    # Single return point
    Add-ZtTestResultDetail -TestId '21867' -Title 'Enterprise applications with high privilege Microsoft Graph API permissions have owners' `
        -UserImpact Low -Risk High -ImplementationCost Medium `
        -AppliesTo Identity -Tag Application `
        -Status $testPassed -Result $testResultMarkdown
}
