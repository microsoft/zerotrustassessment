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
        TenantType = ('Workforce', 'External'),
        TestId = 21892,
        Title = 'All sign-in activity comes from managed devices',
        UserImpact = 'High'
    )]
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose
    if ( -not (Get-ZtLicense EntraIDP1) ) {
        Add-ZtTestResultDetail -SkippedBecause NotLicensedEntraIDP1
        return
    }

    $activity = "Checking that all sign-in activity comes from managed devices"
    Write-ZtProgress -Activity $activity -Status "Getting Conditional Access policies"

    # Get all enabled Conditional Access policies
    $policies = Invoke-ZtGraphRequest -RelativeUri "identity/conditionalAccess/policies" -ApiVersion v1.0

    $matchingPolicies = @()

    foreach ($policy in $policies) {
        $appliesToAllUsers = ($policy.conditions.users.includeUsers -contains "All")
        $appliesToAllApps = ($policy.conditions.applications.includeApplications -contains "All")
        $compliantDevice = ($policy.grantControls.builtInControls -contains "compliantDevice")
        $hybridJoinedDevice = ($policy.grantControls.builtInControls -contains "domainJoinedDevice")
        $enabled = $policy.state -eq "enabled"

        if ($compliantDevice -or $hybridJoinedDevice) {
            $status = $enabled -and $appliesToAllUsers -and $appliesToAllApps -and ($compliantDevice -or $hybridJoinedDevice)
            $detail = [PSCustomObject]@{
                PolicyId           = $policy.id
                PolicyState        = $policy.state
                DisplayName        = $policy.displayName
                AllUsers           = $appliesToAllUsers
                AllApps            = $appliesToAllApps
                CompliantDevice    = $compliantDevice
                HybridJoinedDevice = $hybridJoinedDevice
                Status             = $status
            }
            $matchingPolicies += $detail
        }
    }

    $passed = ($matchingPolicies.where{ $_.Status -eq $true } | Measure-Object).Count -gt 0

    $testResultMarkdown = ""
    if ($passed) {
        $testResultMarkdown += "✅ All sign-in activity comes from managed devices.`n"
    }
    else {
        $testResultMarkdown += "❌ Not all sign-in activity comes from managed devices.`n"
    }

    if ( -not $matchingPolicies) {
        $testResultMarkdown += "`nNo Conditional Access policies were found that require a compliant device or a hybrid joined device. This means that sign-in activity is not restricted to managed devices.`n"
    }
    else {
        $testResultMarkdown += "`n### Managed device conditional access policy summary`n"
        $testResultMarkdown += "`nThe table below lists all Conditional Access policies that require a compliant device or a hybrid joined device.`n"

        $testResultMarkdown += "| Name | All users | All apps | Compliant device | Hybrid joined device | Policy state | Status |`n"
        $testResultMarkdown += "| :--- | :---:  | :---: | :---: | :---: | :--- | :--- |`n"

        $matchingPolicies = $matchingPolicies | Sort-Object -Property @{ Expression = { -not $_.Status } }, DisplayName

        foreach ($item in $matchingPolicies) {
            $status = Get-ZtPassFail -Condition $item.Status -IncludeText
            $policyState = Get-ZtCaPolicyState -State $item.PolicyState
            $portalLink = "https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/$($item.PolicyId)"
            $testResultMarkdown += "| [$(Get-SafeMarkdown $item.DisplayName)]($portalLink) | $(Get-ZtPassFail $item.AllUsers -EmojiType 'Bubble') | $(Get-ZtPassFail $item.AllApps -EmojiType 'Bubble') | $(Get-ZtPassFail $item.CompliantDevice -EmojiType 'Bubble') | $(Get-ZtPassFail $item.HybridJoinedDevice -EmojiType 'Bubble') | $policyState | $status |`n"
        }
    }

    $testResultParams = @{
        TestId = '21892'
        Status = $passed
        Result = $testResultMarkdown
    }
    Add-ZtTestResultDetail @testResultParams
}
