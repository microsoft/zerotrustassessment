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

    # Q1: List all Intune operation approval policies (Multi Admin Approval).
    # approverGroupIds is intentionally excluded — the list response can omit it; Q2 fetches it reliably per policy.
    $policies = @()
    try {
        $policies = @(Invoke-ZtGraphRequest -RelativeUri 'deviceManagement/operationApprovalPolicies' -Select 'id,displayName,policyType,policyPlatform,lastModifiedDateTime' -ApiVersion beta -ErrorAction Stop)
    }
    catch {
        # Surface all Q1 failures as Investigate so the run continues and the assessor gets a clear message.
        # 403/Forbidden/accessDenied = permission gap; anything else = transient or unexpected error.
        $result = if ($_.Exception.Message -match '403|Forbidden|accessDenied') {
            '⚠️ Insufficient permissions when querying Intune Multi Admin Approval policies. Ensure you have the required access to run this assessment.'
        }
        else {
            "⚠️ An error occurred while querying Intune Multi Admin Approval policies: $($_.Exception.Message)"
        }
        $params = @{
            TestId       = '51015'
            Title        = 'Multi Admin Approval is enabled in Intune to require a second admin to approve sensitive tenant changes'
            Status       = $false
            Result       = $result
            CustomStatus = 'Investigate'
        }
        Add-ZtTestResultDetail @params
        return
    }

    # Q2: Fetch per-policy detail to reliably retrieve approverGroupIds.
    # The list response (Q1) omits approverGroupIds; individual GETs always return it.
    $policyDetails = @{}
    if ($policies.Count -gt 0) {
        Write-ZtProgress -Activity $activity -Status 'Getting policy details'
        foreach ($policy in $policies) {
            try {
                $detail = Invoke-ZtGraphRequest -RelativeUri "deviceManagement/operationApprovalPolicies/$($policy.id)" -ApiVersion beta -ErrorAction Stop
                $policyDetails[$policy.id] = $detail
            }
            catch {
                Write-PSFMessage "Q2 failed for policy $($policy.id): $_" -Tag Test -Level Warning
            }
        }
    }
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
