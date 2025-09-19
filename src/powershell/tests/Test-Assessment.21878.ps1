<#
.SYNOPSIS
    Assessment – Verifies that all entitlement management policies have expiration dates configured.
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

    $activity = "Checking expiration settings for entitlement management policies"
    Write-ZtProgress -Activity $activity -Status "Getting assignment policies"

    # Get all entitlement management assignment policies with expiration info
    $policies = Invoke-ZtGraphRequest -RelativeUri "identityGovernance/entitlementManagement/assignmentPolicies" -ApiVersion v1.0

    $matchingPolicies    = @()
    $nonMatchingPolicies = @()

    foreach ($policy in $policies) {
        $expiration = $policy.expiration
        $hasDuration = ($expiration.duration) -and ($expiration.type -eq "afterDuration")
        $hasEndDate  = ($expiration.endDateTime) -and ($expiration.type -eq "afterDateTime")
        $meetsCriteria = ($hasDuration -or $hasEndDate)

        $detail = [PSCustomObject]@{
            Id             = $policy.id
            Name           = $policy.displayName
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

    $passed = ($nonMatchingPolicies | Measure-Object).Count -eq 0
    $testResultMarkdown = ""

    if ($passed) {
        $testResultMarkdown += "Pass: All entitlement management policies have expiration dates configured`n`n%TestResult%"
    } else {
        $testResultMarkdown += "Fail: Not all entitlement management policies have expiration dates`n`n%TestResult%"
    }

    $mdInfo = ""
    $mdInfo += "| ID | Policy Name | Expiration Type | Duration | End DateTime |`n"
    $mdInfo += "| :--- | :--- | :--- | :--- | :--- |`n"
    foreach ($item in ($matchingPolicies + $nonMatchingPolicies)) {
        $mdInfo += "| $($item.Id) | $(Get-SafeMarkdown $item.Name) | $($item.ExpirationType) | $($item.Duration) | $($item.EndDateTime) |`n"
    }
    $mdInfo += "`n[Configure expiration settings for access package policies](https://learn.microsoft.com/entra/id-governance/entitlement-management-access-package-lifecycle)"

    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo

    Add-ZtTestResultDetail -TestId 'EntitlementPolicyExpiration' -Title 'All entitlement management policies have expiration dates configured' `
        -UserImpact Medium -Risk Medium -ImplementationCost Low `
        -AppliesTo Identity -Tag EntitlementManagement `
        -Status $passed -Result $testResultMarkdown
}
