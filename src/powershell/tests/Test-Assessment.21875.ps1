<#
.SYNOPSIS

#>

function Test-Assessment-21875{
    [ZtTest(
    	Category = 'Access control',
    	ImplementationCost = 'Medium',
    	Pillar = 'Identity',
    	RiskLevel = 'Medium',
    	SfiPillar = 'Protect identities and secrets',
    	TenantType = ('Workforce','External'),
    	TestId = 21875,
    	Title = 'Tenant has all external organizations allowed to collaborate as connected organization',
    	UserImpact = 'Medium'
    )]
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking entitlement management assignment policies for external users'
    Write-ZtProgress -Activity $activity -Status 'Querying assignment policies via Microsoft Graph API'

    # Call Microsoft Graph API to get assignment policies with expanded access package details

    $response = Invoke-ZtGraphRequest -RelativeUri 'identityGovernance/entitlementManagement/assignmentPolicies?$expand=accessPackage' -ApiVersion v1.0

    $targetScopes = @('specificConnectedOrganizationUsers', 'allConfiguredConnectedOrganizationUsers', 'allExternalUsers')
    $results = $response | Where-Object { $_.allowedTargetScope -in $targetScopes }

    # Map to expected property names and determine per-policy status
    $results = $results | ForEach-Object {
        $status = switch ($_.allowedTargetScope) {
            'allExternalUsers' { '❌ Fail' }
            'allConfiguredConnectedOrganizationUsers' { '⚠️ Investigate' }
            'specificConnectedOrganizationUsers' { '✅ Pass' }
            default { '❓ Unknown' }
        }
        [PSCustomObject]@{
            AccessPackageName = $_.accessPackage.displayName
            AssignmentPolicyName = $_.displayName
            allowedTargetScope = $_.allowedTargetScope
            Status = $status
        }
    }

    $testResultMarkdown = ''

    $customStatus = $null
    if ($results.Count -eq 0) {
        $testResultMarkdown = 'No assignment policies found that target external users.'
        $testPassed = $true
    } elseif (($results | Where-Object { $_.allowedTargetScope -eq 'allExternalUsers' }).Count -gt 0) {
        $testResultMarkdown = 'Assignment policies without connected organization restrictions were found.'
        $testPassed = $false
    } elseif (($results | Where-Object { $_.allowedTargetScope -eq 'allConfiguredConnectedOrganizationUsers' }).Count -gt 0) {
        $testResultMarkdown = 'Assignment policies that allow any connected organization were found.'
        $testPassed = $true
        $customStatus = 'Investigate'
    } elseif (($results | Where-Object { $_.allowedTargetScope -eq 'specificConnectedOrganizationUsers' }).Count -eq $results.Count) {
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
