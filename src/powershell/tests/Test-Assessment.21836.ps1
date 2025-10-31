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
    Write-ZtProgress -Activity $activity -Status "Getting privileged roles"

    # Query 1 (Q1): Get all privileged roles
    $privilegedRoles = Get-ZtRole -IncludePrivilegedRoles

    if ($null -eq $privilegedRoles -or $privilegedRoles.Count -eq 0) {
        $testResultMarkdown = "## Privileged Roles Not Found`n`n"
        $testResultMarkdown += "*Could not find any privileged roles in the tenant.*`n`n"

        Add-ZtTestResultDetail -Status $false -Result $testResultMarkdown
        return
    }

    Write-ZtProgress -Activity $activity -Status "Getting role assignments for workload identities"

    # Query 2 (Q2): Get role assignments from database
    $roleAssignments = Invoke-DatabaseQuery -Database $Database -Sql "SELECT principal, roleDefinitionId FROM RoleAssignment"

    # Filter to workload identities (ServicePrincipal/ManagedIdentity) with privileged roles
    $privilegedRoleIds = $privilegedRoles.id
    $workloadIdentitiesWithPrivilegedRoles = @($roleAssignments | Where-Object {
        # Check if principal is a workload identity (ServicePrincipal includes both SP and Managed Identities)
        $isWorkloadIdentity = ($_.principal.'@odata.type' -eq '#microsoft.graph.servicePrincipal' -or $_.principal.'@odata.type' -eq '#microsoft.graph.managedIdentity')

        # Check if role is privileged
        $isPrivilegedRole = $privilegedRoleIds -contains $_.roleDefinitionId

        # Return only workload identities with privileged roles
        $isWorkloadIdentity -and $isPrivilegedRole
    })

    if ($workloadIdentitiesWithPrivilegedRoles.Count -gt 0) {
        $testResultMarkdown += "**Found workload identities assigned to privileged roles.**`n"
        $testResultMarkdown += "| Service Principal Name | Service Principal ID | Privileged Roles |`n"
        $testResultMarkdown += "| :--- | :--- | :--- |`n"

        # Group assignments by service principal
        $groupedByPrincipal = $workloadIdentitiesWithPrivilegedRoles | Group-Object -Property { $_.principal.id }

        foreach ($principalGroup in $groupedByPrincipal) {
            $firstAssignment = $principalGroup.Group[0]
            $principalName = $firstAssignment.principal.displayName
            $principalId = $firstAssignment.principal.id

            # Collect all role names for this service principal
            $roleNames = @()
            foreach ($assignment in $principalGroup.Group) {
                $role = $privilegedRoles | Where-Object { $_.id -eq $assignment.roleDefinitionId }
                $roleName = if ($role) { $role.displayName } else { $assignment.roleDefinitionId }
                $roleNames += $roleName
            }

            # Join role names with comma
            $rolesDisplay = $roleNames -join ', '

            $spLink = 'https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/{0}/appId/{1}/preferredSingleSignOnMode~/null/servicePrincipalType/Application/fromNav/' -f $principalId, $firstAssignment.principal.appId
            $testResultMarkdown += "| [$(Get-SafeMarkdown $principalName)]($spLink) | $principalId | $rolesDisplay |`n"
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
