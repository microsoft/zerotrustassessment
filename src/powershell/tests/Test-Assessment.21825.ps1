<#
.SYNOPSIS
    Checks Privileged users have short-lived sign-in sessions
#>

#Helper functions region

function Get-AssignedCAPoliciesForRole {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$RoleId,
        [Parameter(Mandatory = $true)]
        [array]$CAPolicies
    )

    # Get all CA policies targeting the specified role
    $assignedPolicies = @($CAPolicies | Where-Object { $_.conditions.users.includeRoles -contains $RoleId })
    return $assignedPolicies
}

function Test-Assessment-21825{
    [ZtTest(
    	Category = 'Access control',
    	ImplementationCost = 'Low',
    	Pillar = 'Identity',
    	RiskLevel = 'Medium',
    	SfiPillar = 'Protect identities and secrets',
    	TenantType = ('Workforce'),
    	TestId = 21825,
    	Title = 'Privileged users have short-lived sign-in sessions',
    	UserImpact = 'Medium'
    )]
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking Privileged user sessions don''t have long lived sign-in sessions'
    Write-ZtProgress -Activity $activity -Status 'Getting privileged role definitions'

    # Query 1 (Q1): Get privileged role definitions
    $privilegedRoles = Get-ZtRole -IncludePrivilegedRoles

    if ($null -eq $privilegedRoles -or $privilegedRoles.Count -eq 0) {
        $testResultMarkdown = "## Privileged Roles Not Found`n`n"
        $testResultMarkdown += "*Could not find any privileged roles in the tenant.*`n`n"

        Add-ZtTestResultDetail -Status $false -Result $testResultMarkdown
        return
    }

    $testResultMarkdown = "## Privileged User Sign-In Sessions`n`n"
    $testResultMarkdown += "**Total Privileged Roles Found:** $($privilegedRoles.Count)`n`n"

    Write-ZtProgress -Activity $activity -Status 'Getting Conditional Access policies'

    # Query 2 (Q2): Get enabled CA policies targeting directory roles
    $caPolicies = Invoke-ZtGraphRequest -RelativeUri 'identity/conditionalAccess/policies' -ApiVersion beta

    # Filter to enabled policies that include roles
    $roleScopedPolicies = @($caPolicies | Where-Object {
        $null -ne $_.conditions.users.includeRoles -and
        $_.conditions.users.includeRoles.Count -gt 0
    })

    $testResultMarkdown += "**CA Policies Targeting Roles:** $($roleScopedPolicies.Count)`n`n"

    # Query 3 (Q3): Analyze session control configuration for sign-in frequency
    $policiesWithSessionControls = @($roleScopedPolicies | Where-Object {
        $null -ne $_.sessionControls -and
        $null -ne $_.sessionControls.signInFrequency
    })

    # Recommended: Sign-in frequency should be 4 hours or less for privileged users
    $recommendedMaxHours = 4
    if( -not (Get-ZtLicense EntraIDP2) ) {
        $recommendedMaxHours = 24
    }
    $testResultMarkdown += "**Recommended Sign In Session Hours:** $recommendedMaxHours`n`n"
    $policiesWithCompliantFreq = @($policiesWithSessionControls | Where-Object {
        $freq = $_.sessionControls.signInFrequency
        if ($freq.type -eq 'hours') {
            $freq.value -le $recommendedMaxHours
        } else {
            $false  # Days are not recommended for privileged users
        }
    })

    $testResultMarkdown += "**Policies with Compliant Frequency (≤$recommendedMaxHours hours):** $($policiesWithCompliantFreq.Count)`n`n"

    # Generate output by privileged role
    $testResultMarkdown += "### Conditional Access Policies by Privileged Role`n`n"

    $allRolesCovered = $true

    foreach ($role in $privilegedRoles) {
        $testResultMarkdown += "#### $($role.displayName)`n`n"

        # Get CA policies assigned to this role
        $assignedPolicies = Get-AssignedCAPoliciesForRole -RoleId $role.id -CAPolicies $caPolicies

        # Filter to only enabled policies
        $enabledPolicies = @($assignedPolicies | Where-Object { $_.state -eq 'enabled' })

        if ($enabledPolicies.Count -gt 0) {
            # Check if at least one compliant enabled policy covers this role
            $compliantForRole = @($enabledPolicies | Where-Object {
                $null -ne $_.sessionControls -and
                $null -ne $_.sessionControls.signInFrequency -and
                $_.sessionControls.signInFrequency.type -eq 'hours' -and
                $_.sessionControls.signInFrequency.value -le $recommendedMaxHours
            })

            $roleStatus = if ($compliantForRole.Count -gt 0) { '✅ Covered' } else { '❌ Not Covered'; $allRolesCovered = $false }
            $testResultMarkdown += "**Status:** $roleStatus`n`n"

            $testResultMarkdown += "| Policy Name | Sign-In Frequency | Compliant |`n"
            $testResultMarkdown += "| :--- | :--- | :--- |`n"

            foreach ($policy in $enabledPolicies) {
                $freqValue = 'Not Configured'
                $isCompliant = '❌'

                if ($null -ne $policy.sessionControls -and $null -ne $policy.sessionControls.signInFrequency) {
                    $freq = $policy.sessionControls.signInFrequency
                    $freqValue = "$($freq.value) $($freq.type)"

                    if ($freq.type -eq 'hours' -and $freq.value -le $recommendedMaxHours) {
                        $isCompliant = '✅'
                    } elseif ($freq.type -eq 'hours') {
                        $isCompliant = "⚠️ ($($freq.value)h > $($recommendedMaxHours)h)"
                    } else {
                        $isCompliant = '❌ (Days not recommended)'
                    }
                }

                $policyLink = "https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/$($policy.id)"
                $testResultMarkdown += "| [$($policy.displayName)]($policyLink) | $freqValue | $isCompliant |`n"
            }
            $testResultMarkdown += "`n"
        } else {
            $testResultMarkdown += "**Status:** ❌ No CA policies assigned`n`n"
            $testResultMarkdown += "*No Conditional Access policies target this privileged role.*`n`n"
            $allRolesCovered = $false
        }
    }

    # Determine pass/fail based on all roles being covered
    $passed = $allRolesCovered -and $privilegedRoles.Count -gt 0

    if ($passed) {
        $testResultMarkdown += "✅ **All privileged roles are covered by enabled policies enforcing short-lived sessions (≤$recommendedMaxHours hours).**`n"
    } else {
        $testResultMarkdown += "❌ **Not all privileged roles are covered by compliant sign-in frequency controls.**`n"
        $testResultMarkdown += "`n**Recommendation:** Configure Conditional Access policies to enforce sign-in frequency of $recommendedMaxHours hours or less for ALL privileged roles.`n"
    }

    Add-ZtTestResultDetail -Status $passed -Result $testResultMarkdown
}
