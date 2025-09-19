<#
.SYNOPSIS
    Assessment 21892 – Verifies that all sign-in activity is restricted to managed devices.
#>

function Test-Assessment-21892{
    [ZtTest(
    	Category = 'Access control',
    	ImplementationCost = 'High',
    	Pillar = 'Identity',
    	RiskLevel = 'Medium',
    	SfiPillar = 'Protect identities and secrets',
    	TenantType = ('Workforce','External'),
    	TestId = 21892,
    	Title = 'All sign-in activity comes from managed devices',
    	UserImpact = 'High'
    )]
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "Checking that all sign-in activity comes from managed devices"
    Write-ZtProgress -Activity $activity -Status "Getting Conditional Access policies"

    # Get all enabled Conditional Access policies
    $policies = Invoke-ZtGraphRequest -RelativeUri "identity/conditionalAccess/policies?\$filter=state eq 'enabled'" -ApiVersion v1.0

    $matchingPolicies    = @()
    $nonMatchingPolicies = @()

    foreach ($policy in $policies) {
        $appliesToAllUsers = ($policy.conditions.users.includeUsers -contains "All")
        $appliesToAllApps  = ($policy.conditions.applications.includeApplications -contains "All")
        $builtInControls   = $policy.grantControls.builtInControls
        $operator          = $policy.grantControls.operator

        $isCompliantDeviceOnly = ($builtInControls.Count -eq 1 -and $builtInControls -contains "compliantDevice")
        $isCompliantOrHybrid   = (
            ($builtInControls -contains "compliantDevice") -and
            ($builtInControls -contains "domainJoinedDevice") -and
            ($operator -eq "OR")
        )
        $hasRequiredDeviceControls = ($isCompliantDeviceOnly -or $isCompliantOrHybrid)

        $meetsCriteria = (
            $appliesToAllUsers -and
            $appliesToAllApps  -and
            $hasRequiredDeviceControls
        )

        $detail = [PSCustomObject]@{
            PolicyId        = $policy.id
            DisplayName     = $policy.displayName
            State           = $policy.state
            Created         = $policy.createdDateTime
            Modified        = $policy.modifiedDateTime
            DeviceControls  = if ($hasRequiredDeviceControls) { 'Yes' } else { 'No' }
            MeetsCriteria   = $meetsCriteria
        }

        if ($meetsCriteria) {
            $matchingPolicies    += $detail
        } else {
            $nonMatchingPolicies += $detail
        }
    }

    $passed = ($matchingPolicies | Measure-Object).Count -gt 0
    $testResultMarkdown = ""

    if ($passed) {
        $testResultMarkdown += "Pass: All sign-in activity comes from managed devices`n`n%TestResult%"
    } else {
        $testResultMarkdown += "Fail: Not all sign-in activity comes from managed devices`n`n%TestResult%"
    }

    $mdInfo = ""
    $mdInfo += "| Policy ID | Name | State | Created | Modified | Device state controls |`n"
    $mdInfo += "| :--- | :--- | :--- | :--- | :--- | :--- |`n"
    foreach ($item in ($matchingPolicies + $nonMatchingPolicies)) {
        $mdInfo += "| $($item.PolicyId) | $(Get-SafeMarkdown $item.DisplayName) | $($item.State) | $(Get-FormattedDate $item.Created) | $(Get-FormattedDate $item.Modified) | $($item.DeviceControls) |`n"
    }
    $mdInfo += "`n[Configure Conditional Access policies for device compliance](https://learn.microsoft.com/entra/identity/conditional-access/policy-all-users-device-compliance)"

    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo

    Add-ZtTestResultDetail -TestId '21892' -Title 'All sign-in activity comes from managed devices' `
        -UserImpact High -Risk High -ImplementationCost High `
        -AppliesTo Identity -Tag Identity `
        -Status $passed -Result $testResultMarkdown
}
