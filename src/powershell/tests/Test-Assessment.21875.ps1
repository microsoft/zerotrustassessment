<#
.SYNOPSIS

#>

function Test-Assessment-21875 {
    [ZtTest(
    	Category = 'External collaboration',
    	ImplementationCost = 'Medium',
    	Pillar = 'Identity',
    	RiskLevel = 'Medium',
    	SfiPillar = 'Protect tenants and isolate production systems',
    	TenantType = ('Workforce','External'),
    	TestId = 21875,
    	Title = 'All entitlement management assignment policies that apply to external users require connected organizations',
    	UserImpact = 'Medium'
    )]
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose
    if ((Get-MgContext).Environment -ne 'Global') {
        Write-PSFMessage "This test is only applicable to the Global environment." -Tag Test -Level VeryVerbose
        return
    }

    if ( -not (Get-ZtLicense EntraIDP2) ) {
        Add-ZtTestResultDetail -SkippedBecause NotLicensedEntraIDP2
        return
    }

    $activity = 'Checking entitlement management assignment policies for external users'
    Write-ZtProgress -Activity $activity -Status 'Querying assignment policies via Microsoft Graph API'

    # Call Microsoft Graph API to get assignment policies with expanded access package details

    $response = Invoke-ZtGraphRequest -RelativeUri 'identityGovernance/entitlementManagement/assignmentPolicies?$expand=accessPackage' -ApiVersion v1.0

    $targetScopes = @('specificConnectedOrganizationUsers', 'allConfiguredConnectedOrganizationUsers', 'allExternalUsers')
    $results = $response | Where-Object { $_.allowedTargetScope -in $targetScopes }
    if ($results) {
        # Map to expected property names and determine per-policy status
        $results = $results | ForEach-Object {
            $status = switch ($_.allowedTargetScope) {
                'allExternalUsers' {
                    '❌ Fail'
                }
                'allConfiguredConnectedOrganizationUsers' {
                    '⚠️ Investigate'
                }
                'specificConnectedOrganizationUsers' {
                    '✅ Pass'
                }
            }
            [PSCustomObject]@{
                AccessPackageName    = $_.accessPackage.displayName
                AssignmentPolicyName = $_.displayName
                allowedTargetScope   = $_.allowedTargetScope
                Status               = $status
            }
        }
    }


    $testResultMarkdown = ''

    $customStatus = $null
    if ($results.Count -eq 0) {
        $testResultMarkdown = 'No assignment policies found that target external users.'
        $testPassed = $true
    }
    elseif (($results | Where-Object { $_.allowedTargetScope -eq 'allExternalUsers' }).Count -gt 0) {
        $testResultMarkdown = 'Assignment policies without connected organization restrictions were found.'
        $testPassed = $false
    }
    elseif (($results | Where-Object { $_.allowedTargetScope -eq 'allConfiguredConnectedOrganizationUsers' }).Count -gt 0) {
        $testResultMarkdown = 'Assignment policies that allow any connected organization were found.'
        $testPassed = $true
        $customStatus = 'Investigate'
    }
    elseif (($results | Where-Object { $_.allowedTargetScope -eq 'specificConnectedOrganizationUsers' }).Count -eq $results.Count) {
        $testResultMarkdown = 'All assignment policies targeting external users are restricted to specific connected organizations.'
        $testPassed = $true
    }

    # Summary table of all evaluated policies with status
    if ($results.Count -gt 0) {
        $testResultMarkdown += "`n## Evaluated assignment policies`n| Access package | Assignment policy | Target scope | Status |`n| :--- | :--- | :--- | :--- |`n"
        foreach ($item in $results) {
            $accessPackageLink = 'https://entra.microsoft.com/#view/Microsoft_AAD_ERM/DashboardBlade/~/elmEntitlement/menuId/'
            $testResultMarkdown += "| [$(Get-SafeMarkdown($item.AccessPackageName))]($accessPackageLink) | $(Get-SafeMarkdown($item.AssignmentPolicyName)) | $($item.allowedTargetScope) | $($item.Status) |`n"
        }
    }

    $params = @{
        TestId = '21875'
        Status = $testPassed
        Result = $testResultMarkdown
    }
    if ($customStatus) {
        $params.CustomStatus = $customStatus
    }

    Add-ZtTestResultDetail @params
}
