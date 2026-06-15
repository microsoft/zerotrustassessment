<#
.SYNOPSIS
    Multi Admin Approval is enabled in Intune to require a second admin to approve sensitive tenant changes.

.DESCRIPTION
    Checks whether at least one Intune Multi Admin Approval (MAA) access policy exists with an approver
    group assigned. Without MAA, a single compromised admin account can push apps, run scripts, wipe
    devices, modify compliance or configuration policies, and change role assignments with no second
    pair of eyes. A policy only enforces the approval gate when it has at least one approver group
    configured in approverGroupIds.

.NOTES
    Test ID: 51015
    Category: Devices
    Pillar: Devices
    Required API: Microsoft Graph beta — deviceManagement/operationApprovalPolicies
                  Q1: list (id, displayName, policyType, policyPlatform, lastModifiedDateTime)
                  Q2: per-policy detail (approverGroupIds)
#>

function Test-Assessment-51015 {
    [ZtTest(
        Category = 'Devices',
        MinimumLicense = ('INTUNE_A'),
        CompatibleLicense = ('INTUNE_A'),
        ImplementationCost = 'Medium',
        Pillar = 'Devices',
        RiskLevel = 'High',
        SfiPillar = 'Protect identities and secrets',
        TenantType = ('Workforce'),
        TestId = 51015,
        Title = 'Multi Admin Approval is enabled in Intune to require a second admin to approve sensitive tenant changes',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking Intune Multi Admin Approval access policies'
    Write-ZtProgress -Activity $activity -Status 'Getting access policies'

    # ── STUB DATA (remove before merge) ────────────────────────────────────────
    # Covers all three row states:
    #   policy-pass    → Q2 succeeds, approverGroupIds populated  → ✅ Pass
    #   policy-fail    → Q2 succeeds, approverGroupIds empty      → ❌ Fail
    #   policy-unknown → Q2 intentionally absent from $policyDetails → ⚠️ Unknown
    $policies = @(
        [PSCustomObject]@{ id = 'policy-pass';    displayName = 'Stub — App Deployment Approval'; policyType = 'app';    policyPlatform = 'windows10AndLater'; lastModifiedDateTime = '2026-01-15T10:00:00Z' }
        [PSCustomObject]@{ id = 'policy-fail';    displayName = 'Stub — Script Run Approval';     policyType = 'script'; policyPlatform = 'windows10AndLater'; lastModifiedDateTime = '2026-02-20T14:30:00Z' }
        [PSCustomObject]@{ id = 'policy-unknown'; displayName = 'Stub — Q2 Failed Policy';        policyType = 'app';    policyPlatform = 'androidForWork';    lastModifiedDateTime = '2026-03-01T08:00:00Z' }
    )
    $policyDetails = @{
        'policy-pass' = [PSCustomObject]@{ id = 'policy-pass'; approverGroupIds = @('group-aaa-111', 'group-bbb-222') }
        'policy-fail' = [PSCustomObject]@{ id = 'policy-fail'; approverGroupIds = @() }
        # 'policy-unknown' intentionally omitted — simulates a Q2 fetch failure
    }
    # ── END STUB DATA ────────────────────────────────────────────────────────
    #endregion Data Collection

    #region Assessment Logic
    # Guard: Q1 found policies but every Q2 detail call failed — cannot evaluate confidently.
    if ($policies.Count -gt 0 -and $policyDetails.Count -eq 0) {
        $params = @{
            TestId       = '51015'
            Title        = 'Multi Admin Approval is enabled in Intune to require a second admin to approve sensitive tenant changes'
            Status       = $false
            Result       = '⚠️ Unable to retrieve Intune Multi Admin Approval policy details for evaluation. Please retry and verify the required permissions.'
            CustomStatus = 'Investigate'
        }
        Add-ZtTestResultDetail @params
        return
    }

    # Pass: at least one Q2 policy detail has a non-empty approverGroupIds collection.
    # Fail: zero policies exist, OR every Q2 detail has an empty approverGroupIds.
    $passed = @($policyDetails.Values | Where-Object { $_ -and $_.approverGroupIds -and $_.approverGroupIds.Count -gt 0 }).Count -gt 0

    if ($passed) {
        $testResultMarkdown = "✅ At least one Intune Multi Admin Approval access policy exists with an approver group assigned, so a second administrator must approve protected actions before they take effect.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "❌ No Intune Multi Admin Approval access policy is configured with an approver group — a single compromised admin account can perform sensitive tenant actions (app push, script run, device wipe, policy change, role change) with no second-administrator gate.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    $mdInfo = ''
    $portalUrl = 'https://intune.microsoft.com/#view/Microsoft_Intune_DeviceSettings/TenantAdminMenu/~/multiAdminApproval'

    if ($policies.Count -gt 0) {
        $tableRows = ''
        # Cap output at 10 rows; append a summary row when the list is longer.
        $displayedPolicies = if ($policies.Count -gt 10) {
            $policies[0..9]
        }
        else {
            $policies
        }

        foreach ($policy in $displayedPolicies) {
            $policyName = Get-SafeMarkdown $policy.displayName
            $policyType = $policy.policyType
            $platform = $policy.policyPlatform
            $lastModified = Get-FormattedDate $policy.lastModifiedDateTime
            # Use Q2 detail for approverGroupIds.
            # Distinguish Q2 fetch failure ($null detail) from a genuine policy with no approver group.
            $detail = $policyDetails[$policy.id]
            if ($null -eq $detail) {
                $approverGroupCount = 'Error'
                $rowStatus = '⚠️ Unknown'
            }
            elseif ($detail.approverGroupIds -and $detail.approverGroupIds.Count -gt 0) {
                $approverGroupCount = $detail.approverGroupIds.Count
                $rowStatus = '✅ Pass'
            }
            else {
                $approverGroupCount = 0
                $rowStatus = '❌ Fail'
            }
            $policyLink = "https://intune.microsoft.com/#view/Microsoft_Intune_DeviceSettings/AccessPolicyPropertiesSummary/policyId/$($policy.id)"

            $tableRows += "| [$policyName]($policyLink) | $policyType | $platform | $approverGroupCount | $lastModified | $rowStatus |`n"
        }

        if ($policies.Count -gt 10) {
            $tableRows += "| ... ($($policies.Count) total) | | | | | |`n"
        }

        $formatTemplate = @'

## [Intune Multi Admin Approval access policies]({1})

| Policy name | Policy type | Platform | Approver group count | Last modified | Status |
| :---------- | :---------- | :------- | :------------------- | :------------ | :----- |
{0}
'@
        $mdInfo = $formatTemplate -f $tableRows, $portalUrl
    }

    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '51015'
        Title  = 'Multi Admin Approval is enabled in Intune to require a second admin to approve sensitive tenant changes'
        Status = $passed
        Result = $testResultMarkdown
    }
    Add-ZtTestResultDetail @params
}
