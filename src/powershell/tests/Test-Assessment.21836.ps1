<#
.SYNOPSIS
    Checks Workload Identities are not assigned privileged roles
#>

function Test-Assessment-21836{
    [ZtTest(
    	Category = 'Application management',
    	ImplementationCost = 'Medium',
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
SELECT principalId, principalDisplayName, userPrincipalName, roleDisplayName, roleDefinitionId, privilegeType, isPrivileged, "@odata.type"
FROM vwRole
WHERE isPrivileged = 1 AND "@odata.type" in ('#microsoft.graph.servicePrincipal', '#microsoft.graph.managedIdentity')
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
            $roleName = $assignment.roleDisplayName
            $assignmentType = $assignment.privilegeType

            $spLink = 'https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/{0}' -f $principalId
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
