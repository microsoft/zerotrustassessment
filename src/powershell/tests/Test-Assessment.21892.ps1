<#
.SYNOPSIS
    Assessment 21892 – Verifies that all sign-in activity is restricted to managed devices.
#>

function Test-Assessment-21892 {
    [ZtTest(
    	Category = 'Access control',
    	ImplementationCost = 'High',
    	Pillar = 'Identity',
    	RiskLevel = 'High',
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
    $policies = Invoke-ZtGraphRequest -RelativeUri "identity/conditionalAccess/policies" -ApiVersion v1.0

    # Separate enabled and report-only policies
    $enabledPolicies     = $policies | Where-Object { $_.state -eq "enabled" }
    $reportOnlyPolicies  = $policies | Where-Object { $_.state -eq "enabledForReportingButNotEnforced" }

    $matchingPolicies    = @()
    $nonMatchingPolicies = @()
    $reportOnlyMatching  = @()

    foreach ($policy in $enabledPolicies) {
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

    # Check report-only policies for criteria
    foreach ($policy in $reportOnlyPolicies) {
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

        if ($meetsCriteria) {
            $reportOnlyMatching += [PSCustomObject]@{
                PolicyId        = $policy.id
                DisplayName     = $policy.displayName
                State           = $policy.state
                Created         = $policy.createdDateTime
                Modified        = $policy.modifiedDateTime
                DeviceControls  = 'Yes'
                MeetsCriteria   = $meetsCriteria
            }
        }
    }

    $passed = ($matchingPolicies | Measure-Object).Count -gt 0
    $totalPolicies = ($policies | Measure-Object).Count
    $matchingCount = ($matchingPolicies | Measure-Object).Count
    $nonMatchingCount = ($nonMatchingPolicies | Measure-Object).Count
    $reportOnlyCount = ($reportOnlyMatching | Measure-Object).Count

    $testResultMarkdown = ""
    if ($passed) {
        $testResultMarkdown += "✅ **Pass:** All sign-in activity comes from managed devices.`n"
    } else {
        $testResultMarkdown += "❌ **Fail:** Not all sign-in activity comes from managed devices.`n"
    }
    $testResultMarkdown += "`n**Total Conditional Access policies checked:** $totalPolicies`n"
    $testResultMarkdown += "**Policies enforcing managed devices:** $matchingCount`n"
    $testResultMarkdown += "**Policies NOT enforcing managed devices:** $nonMatchingCount`n"
    $testResultMarkdown += "**Report-only policies meeting criteria:** $reportOnlyCount`n"

    # Show report-only matching policies at the top with hyperlinks
    if ($reportOnlyCount -gt 0) {
        $testResultMarkdown += "`n#### Report-only policies that meet criteria (can be enabled):`n"
        $testResultMarkdown += "| Policy ID | Name | Created | Modified | Device state controls | Meets Criteria |`n"
        $testResultMarkdown += "| :--- | :--- | :--- | :--- | :--- | :---: |`n"
        foreach ($item in $reportOnlyMatching) {
            $criteriaIcon = if ($item.MeetsCriteria) { "✅" } else { "❌" }
            $portalLink = "https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/$($item.PolicyId)"
            $testResultMarkdown += "| [$($item.PolicyId)]($portalLink) | [$(Get-SafeMarkdown $item.DisplayName)]($portalLink) | $(Get-FormattedDate $item.Created) | $(Get-FormattedDate $item.Modified) | $($item.DeviceControls) | $criteriaIcon |`n"
        }
        $testResultMarkdown += "`n> These report-only policies meet the criteria and can be enabled to enforce managed device sign-in.`n"
    }

    $testResultMarkdown += "`n### Conditional Access Policies Device State Controls`n"
    $testResultMarkdown += "| Policy ID | Name | State | Created | Modified | Device state controls | Meets Criteria |`n"
    $testResultMarkdown += "| :--- | :--- | :--- | :--- | :--- | :--- | :---: |`n"
    foreach ($item in ($matchingPolicies + $nonMatchingPolicies)) {
        $criteriaIcon = if ($item.MeetsCriteria) { "✅" } else { "❌" }
        $portalLink = "https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/$($item.PolicyId)"
        $testResultMarkdown += "| [$($item.PolicyId)]($portalLink) | [$(Get-SafeMarkdown $item.DisplayName)]($portalLink) | $($item.State) | $(Get-FormattedDate $item.Created) | $(Get-FormattedDate $item.Modified) | $($item.DeviceControls) | $criteriaIcon |`n"
    }

    $testResultMarkdown += "`n> [Configure Conditional Access policies for device compliance](https://learn.microsoft.com/entra/identity/conditional-access/policy-all-users-device-compliance)`n"

    $testResultMarkdown += "`n#### Guidance`n"
    $testResultMarkdown += "Conditional Access policies should require sign-ins only from compliant or hybrid Azure AD joined devices. Review policies above and ensure all are configured to enforce device compliance for all users and apps.`n"

    $testResultParams = @{
        TestId             = '21892'
        Status             = $passed
        Result             = $testResultMarkdown
    }
    Add-ZtTestResultDetail @testResultParams
}
