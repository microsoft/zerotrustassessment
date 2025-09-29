<#
.SYNOPSIS
    Assessment 21878 – Verifies that all entitlement management policies have expiration dates configured
#>

function Test-Assessment-21878{
    [ZtTest(
    	Category = 'Access control',
    	ImplementationCost = 'Medium',
    	Pillar = 'Identity',
    	RiskLevel = 'Medium',
    	SfiPillar = 'Protect identities and secrets',
    	TenantType = ('Workforce','External'),
    	TestId = 21878,
    	Title = 'All entitlement management policies have an expiration date',
    	UserImpact = 'Medium'
    )]
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking entitlement management assignment policies for expiration dates'
    Write-ZtProgress -Activity $activity -Status 'Getting assignment policies'

    # Query entitlement management assignment policies
    $policies = Invoke-ZtGraphRequest -RelativeUri 'identityGovernance/entitlementManagement/assignmentPolicies' -ApiVersion v1.0

    $matchingPolicies    = @()
    $nonMatchingPolicies = @()

    foreach ($policy in $policies) {
        $expiration    = $policy.expiration
        $hasDuration   = ($expiration.duration) -and ($expiration.type -eq 'afterDuration')
        $hasEndDate    = ($expiration.endDateTime) -and ($expiration.type -eq 'afterDateTime')
        $meetsCriteria = ($hasDuration -or $hasEndDate)

        $detail = [PSCustomObject]@{
            PolicyId       = $policy.id
            DisplayName    = $policy.displayName
            ExpirationType = $expiration.type
            Duration       = $expiration.duration
            EndDateTime    = $expiration.endDateTime
            MeetsCriteria  = $meetsCriteria
        }

        if ($meetsCriteria) {
            $matchingPolicies    += $detail
        } else {
            $nonMatchingPolicies += $detail
        }
    }

    # Get Global Administrator members count
    $globalAdminRole = Invoke-ZtGraphRequest -RelativeUri 'directoryRoles' -ApiVersion v1.0 | Where-Object { $_.displayName -eq 'Global Administrator' }
    $globalAdminMembersCount = 0
    if ($null -ne $globalAdminRole) {
        $globalAdminMembers = Invoke-ZtGraphRequest -RelativeUri ('directoryRoles/{0}/members' -f $globalAdminRole.id) -ApiVersion v1.0
        $globalAdminMembersCount = ($globalAdminMembers | Measure-Object).Count
    }

    $passed = ($nonMatchingPolicies | Measure-Object).Count -eq 0
    $testResultMarkdown = ''

    if ($passed) {
        $testResultMarkdown += '✅ All entitlement management policies have expiration dates configured.`n'
    } else {
        $testResultMarkdown += '❌ Not all entitlement management policies have expiration dates configured.'
        $testResultMarkdown += "`n"
    }

    $testResultMarkdown += "`n**Total Global Administrator members:** $globalAdminMembersCount`n"

    $mdInfo  = '| Policy ID | Name | Expiration Type | Duration | End DateTime | Meets Criteria |' + "`n"
    $mdInfo += '| :--- | :--- | :--- | :--- | :--- | :---: |' + "`n"
    foreach ($item in ($matchingPolicies + $nonMatchingPolicies)) {
        $duration = if ($item.Duration) { $item.Duration } else { '' }
        $endDateTime = if ($item.EndDateTime) { $item.EndDateTime } else { '' }
        $criteriaIcon = if ($item.MeetsCriteria) { '✅' } else { '❌' }
        $mdInfo += '| {0} | {1} | {2} | {3} | {4} | {5} |' -f $item.PolicyId, (Get-SafeMarkdown $item.DisplayName), $item.ExpirationType, $duration, $endDateTime, $criteriaIcon
        $mdInfo += "`n"
    }
    $mdInfo += "`n[Configure expiration settings for access package policies](https://learn.microsoft.com/entra/id-governance/entitlement-management-access-package-lifecycle)"

    $testResultMarkdown += "`n### Entitlement Management Assignment Policies`n"
    $testResultMarkdown += $mdInfo

    $params = @{
        TestId = '21878'
        Status = $passed
        Result = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
