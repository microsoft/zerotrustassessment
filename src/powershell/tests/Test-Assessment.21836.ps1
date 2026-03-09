<#
.SYNOPSIS
    Checks Workload Identities are not assigned privileged roles
#>

function Test-Assessment-21836{
    [ZtTest(
    	Category = 'Application management',
    	ImplementationCost = 'Medium',
    	MinimumLicense = ('P1'),
    	Pillar = 'Identity',
    	RiskLevel = 'High',
    	SfiPillar = 'Protect engineering systems',
    	TenantType = ('Workforce','External'),
    	TestId = 21836,
    	Title = 'Workload Identities are not assigned privileged roles',
    	UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "Checking Workload identities assigned privileged roles"
    Write-ZtProgress -Activity $activity -Status "Getting workload identities with privileged roles"

    # Get workload identities with privileged roles in a single query
    $sql = @"
SELECT vr.principalId, vr.principalDisplayName, sp.appId, vr.userPrincipalName, vr.roleDisplayName, vr.roleDefinitionId, vr.privilegeType, vr.isPrivileged, vr."@odata.type"
FROM vwRole vr
LEFT JOIN ServicePrincipal sp ON vr.principalId = sp.id
WHERE vr.isPrivileged = 1 AND vr."@odata.type" in ('#microsoft.graph.servicePrincipal', '#microsoft.graph.managedIdentity')
"@

    $workloadIdentitiesWithPrivilegedRoles = @(Invoke-DatabaseQuery -Database $Database -Sql $sql)

    if ($workloadIdentitiesWithPrivilegedRoles.Count -gt 0) {
        $testResultMarkdown += "**Found workload identities assigned to privileged roles.**`n"
        $testResultMarkdown += "| Service Principal Name | Privileged Role | Assignment Type |`n"
        $testResultMarkdown += "| :--- | :--- | :--- |`n"

        # Sort by principal display name
        $sortedAssignments = $workloadIdentitiesWithPrivilegedRoles | Sort-Object -Property principalDisplayName

        foreach ($assignment in $sortedAssignments) {
            $principalName = $assignment.principalDisplayName
            $principalId = $assignment.principalId
            $principalAppId = $assignment.appId
            $roleName = $assignment.roleDisplayName
            $assignmentType = $assignment.privilegeType

            $spLink = 'https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/{0}/appId/{1}/preferredSingleSignOnMode~/null/servicePrincipalType/Application/fromNav/' -f $principalId, $principalAppId
            $testResultMarkdown += "| [$(Get-SafeMarkdown $principalName)]($spLink) | $roleName | $assignmentType |`n"
        }
        $testResultMarkdown += "`n"

        $passed = $false
        $testResultMarkdown += "`n**Recommendation:** Review and remove privileged role assignments from workload identities unless absolutely necessary. Use least-privilege principles and consider alternative approaches like managed identities with specific API permissions instead of directory roles.`n"
    } else {
        $passed = $true
        $testResultMarkdown += "✅ **No workload identities found with privileged role assignments.**`n"
    }

    Add-ZtTestResultDetail -Status $passed -Result $testResultMarkdown
}
