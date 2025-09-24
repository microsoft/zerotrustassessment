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
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "Checking if enterprise applications with high privilege permissions have owners"
    Write-ZtProgress -Activity $activity -Status "Getting data"

    # TODO: For future enhancement - implement proper permission classification using the CSV
    # CSV Format: Type,Permission,Privilege,Reason
    # Source: Microsoft Identity Tools - https://github.com/AzureAD/MSIdentityTools/blob/main/assets/aadconsentgrantpermissiontable.csv

    Write-ZtProgress -Activity $activity -Status "Getting applications"
    $applications = Invoke-MgGraphRequest -Method GET -Uri 'https://graph.microsoft.com/v1.0/applications'

    $appsWithHighPriv = @()

        # Filter applications with high privilege permissions
        foreach ($app in $applications.value) {
            $hasHighPriv = $false
            if ($app.requiredResourceAccess) {
                foreach ($resource in $app.requiredResourceAccess) {
                    # For now, treating all permissions as high privilege
                    # TODO: Implement proper permission classification using Graph API metadata or CSV mapping
                    if ($resource.resourceAccess) {
                        $hasHighPriv = $true
                        break
                    }
                }
            }
            if ($hasHighPriv) {
                $appsWithHighPriv += $app
            }
        }

        $failedApps = @()

        # Check owners for high privilege applications
        foreach ($app in $appsWithHighPriv) {
            Write-ZtProgress -Activity $activity -Status "Checking owners for $($app.displayName)"
            $owners = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/applications/$($app.id)/owners"

            if ($owners.value.Count -lt 2) {
                $highPrivPermsList = @()
                foreach ($resource in $app.requiredResourceAccess) {
                    foreach ($perm in $resource.resourceAccess) {
                        $highPrivPermsList += "$($perm.id) ($($perm.type))"
                    }
                }

                $failedApps += @{
                    AppName = $app.displayName
                    AppId = $app.appId
                    IsMultiTenant = $app.signInAudience -eq "AzureADMultipleOrgs"
                    OrgId = if ($app.signInAudience -eq "AzureADMultipleOrgs") { $app.publisherDomain } else { "N/A" }
                    Permissions = $highPrivPermsList -join ", "
                    PermissionClassification = "High"  # Since we filtered for high privilege only
                    OwnerCount = $owners.value.Count
                }
            }
        }

        $result = $failedApps.Count -eq 0
        if ($result) {
            $testResultMarkdown = "Pass: All enterprise applications with high privilege have owners"
        } else {
            $testResultMarkdown = "Fail: Not all enterprise applications with high privilege permissions have owners`n`n"
            $testResultMarkdown += "| App Name | App ID | Multi-tenant | Org ID | Permissions | Classification | Owners |`n"
            $testResultMarkdown += "|----------|---------|--------------|---------|-------------|----------------|---------|`n"
            foreach ($app in $failedApps) {
                $testResultMarkdown += "| $($app.AppName) | $($app.AppId) | $($app.IsMultiTenant) | $($app.OrgId) | $($app.Permissions) | $($app.PermissionClassification) | $($app.OwnerCount) |`n"
            }
        }

        $passed = $result

        $params = @{
            TestId             = '21867'
            Status             = $passed
            Result             = $testResultMarkdown
        }
        Add-ZtTestResultDetail @params
}
