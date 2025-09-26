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
    Write-ZtProgress -Activity $activity -Status 'Getting data'

    # Check if we have data in the database
    $sqlCount = 'SELECT COUNT(*) ItemCount FROM Application WHERE ID IS NOT NULL'
    $resultCount = Invoke-DatabaseQuery -Database $Database -Sql $sqlCount
    $hasData = $resultCount.ItemCount -gt 0

    if (-not $hasData) {
        $testResultMarkdown = 'No applications found in the tenant to evaluate. The test result is inconclusive as there are no applications to assess.'

        Add-ZtTestResultDetail -TestId '21867' -Title 'Enterprise applications with high privilege Microsoft Graph API permissions have owners' `
            -UserImpact Low -Risk High -ImplementationCost Medium `
            -AppliesTo Identity -Tag Application `
            -Status $false -Result $testResultMarkdown
        return
    }

    # Load permission classification from CSV
    $csvPath = Join-Path -Path $PSScriptRoot -ChildPath '..\assets\aadconsentgrantpermissiontable.csv'
    $permissionClassification = Import-Csv -Path $csvPath
    $highPrivPermissions = $permissionClassification | Where-Object { $_.Privilege -eq 'High' }

    Write-ZtProgress -Activity $activity -Status 'Getting all applications from database'

    # Q1: Get all enterprise applications from database
    $sqlApplications = @"
    SELECT
        id,
        appId,
        displayName,
        requiredResourceAccess,
        signInAudience,
        publisherDomain
    FROM Application
    ORDER BY displayName
"@

    $allApplications = Invoke-DatabaseQuery -Database $Database -Sql $sqlApplications

    if ($allApplications.Count -eq 0) {
        $testResultMarkdown = 'No applications found in the tenant. All applications are compliant.'

        Add-ZtTestResultDetail -TestId '21867' -Title 'Enterprise applications with high privilege Microsoft Graph API permissions have owners' `
            -UserImpact Low -Risk High -ImplementationCost Medium `
            -AppliesTo Identity -Tag Application `
            -Status $true -Result $testResultMarkdown
        return
    }

    Write-ZtProgress -Activity $activity -Status 'Client-side filtering: applications with high privilege permissions using CSV classification'

    $highPrivApps = @()

    # Client-side filtering: Check each application for high privilege permissions per requiredResourceAccess property
    foreach ($app in $allApplications) {
        $hasHighPriv = $false
        $highPrivPermsList = @()

        if ($app.requiredResourceAccess -and $app.requiredResourceAccess -ne '[]') {
            try {
                # Handle the LIST type from DuckDB
                $resourceAccess = $null
                if ($app.requiredResourceAccess -is [System.Collections.IEnumerable] -and $app.requiredResourceAccess -isnot [string]) {
                    # If it's already a collection, use it directly
                    $resourceAccess = $app.requiredResourceAccess
                } else {
                    # Try to parse as JSON
                    $resourceAccess = $app.requiredResourceAccess | ConvertFrom-Json
                }

                # Client-side validation of application permissions per requiredResourceAccess property
                foreach ($resource in $resourceAccess) {
                    if ($resource.resourceAccess) {
                        foreach ($permission in $resource.resourceAccess) {
                            $permType = if ($permission.type -eq 'Role') { 'Application' } else { 'Delegated' }

                            # Try to resolve permission name for CSV matching
                            $permissionName = $null
                            try {
                                $resourceSP = Invoke-ZtGraphRequest -RelativeUri "servicePrincipals?`$filter=appId eq '$($resource.resourceAppId)'" -ApiVersion 'beta'
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

                            # Client-side filtering using CSV classification - check if permission is high privilege
                            if ($permissionName) {
                                $isHighPriv = $highPrivPermissions | Where-Object {
                                    $_.Type -eq $permType -and $_.Permission -eq $permissionName
                                }

                                if ($isHighPriv) {
                                    $hasHighPriv = $true
                                    $highPrivPermsList += "$permissionName ($permType)"
                                }
                            }
                        }
                    }
                    if ($hasHighPriv) {
                        break
                    }
                }
            } catch {
                Write-PSFMessage "Failed to parse requiredResourceAccess for app $($app.displayName): $($_.Exception.Message)" -Level Verbose
                continue
            }
        }

        # Filter Q1 to only applications that have at least one permission that is deemed "High" privilege
        if ($hasHighPriv) {
            $app | Add-Member -MemberType NoteProperty -Name 'HighPrivPermissions' -Value ($highPrivPermsList -join ', ') -Force
            $highPrivApps += $app
        }
    }

    if ($highPrivApps.Count -eq 0) {
        $testResultMarkdown = 'All enterprise applications with high privilege have owners'

        Add-ZtTestResultDetail -TestId '21867' -Title 'Enterprise applications with high privilege Microsoft Graph API permissions have owners' `
            -UserImpact Low -Risk High -ImplementationCost Medium `
            -AppliesTo Identity -Tag Application `
            -Status $true -Result $testResultMarkdown
        return
    }

    Write-ZtProgress -Activity $activity -Status 'Checking owners for high privilege applications'

    $failedApps = @()

    # Q2: For each application from client side filtering of Q1 (using the 'id' property), execute Q2 to check for owners
    foreach ($app in $highPrivApps) {
        Write-ZtProgress -Activity $activity -Status "Checking owners for $($app.displayName)"

        try {
            # Execute Q2: applications/{id}/owners to check for owners
            $owners = Invoke-ZtGraphRequest -RelativeUri "applications/$($app.id)/owners" -ApiVersion 'beta'
            $ownerCount = if ($owners) { $owners.Count } else { 0 }

            # Check if Q2 returns any results - if the owners collection is empty, mark as fail for that application
            # Applications with at least two owners in the owners collection pass the check
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
            # Assume no owners if we can't retrieve them - mark as fail
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

    $result = $failedApps.Count -eq 0

    if ($result) {
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

    $passed = $result

    Add-ZtTestResultDetail -TestId '21867' -Title 'Enterprise applications with high privilege Microsoft Graph API permissions have owners' `
        -UserImpact Low -Risk High -ImplementationCost Medium `
        -AppliesTo Identity -Tag Application `
        -Status $passed -Result $testResultMarkdown
}
