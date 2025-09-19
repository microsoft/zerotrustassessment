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

    $activity = "Checking entitlement management assignment policies for expiration dates"
    Write-ZtProgress -Activity $activity -Status "Getting assignment policies"

    # Query entitlement management assignment policies
    $policies = Invoke-ZtGraphRequest -RelativeUri "identityGovernance/entitlementManagement/assignmentPolicies" -ApiVersion v1.0

    $matchingPolicies    = @()
    $nonMatchingPolicies = @()

    foreach ($policy in $policies) {
        $expiration    = $policy.expiration
        $hasDuration   = ($expiration.duration) -and ($expiration.type -eq "afterDuration")
        $hasEndDate    = ($expiration.endDateTime) -and ($expiration.type -eq "afterDateTime")
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

    $passed = ($nonMatchingPolicies | Measure-Object).Count -eq 0
    $testResultMarkdown = ""

    if ($passed) {
        $testResultMarkdown += "Pass: All entitlement management policies have expiration dates configured`n`n%TestResult%"
    } else {
        $testResultMarkdown += "Fail: Not all entitlement management policies have expiration dates configured`n`n%TestResult%"
    }

    $mdInfo  = "| Policy ID | Name | Expiration Type | Duration | End DateTime | Meets Criteria |`n"
    $mdInfo += "| :--- | :--- | :--- | :--- | :--- | :--- |`n"
    foreach ($item in ($matchingPolicies + $nonMatchingPolicies)) {
        $mdInfo += "| $($item.PolicyId) | $(Get-SafeMarkdown $item.DisplayName) | $($item.ExpirationType) | $($item.Duration) | $($item.EndDateTime) | $($item.MeetsCriteria) |`n"
    }
    $mdInfo += "`n[Configure expiration settings for access package policies](https://learn.microsoft.com/entra/id-governance/entitlement-management-access-package-lifecycle)"

    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo

    $params = @{
        TestId             = '21878'
        Title              = 'All entitlement management policies have expiration dates configured'
        UserImpact         = 'Medium'
        Risk               = 'Medium'
        ImplementationCost = 'Low'
        AppliesTo          = 'Identity'
        Tag                = 'Identity'
        Status             = $passed
        Result             = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
