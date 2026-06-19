<#
.SYNOPSIS
    App Protection Policies block managed-app access on jailbroken or rooted mobile devices.

.DESCRIPTION
    Checks whether at least one assigned App Protection Policy (MAM) per in-scope mobile platform
    enforces a hard block or wipe on jailbroken iOS / iPadOS and rooted Android devices. Without this
    gate, the OS sandbox is broken and every other MAM control (cut/copy/paste restrictions, encryption,
    conditional launch) can be bypassed silently, creating a clear exfiltration path for corporate data.
    iOS and Android are evaluated independently: iOS uses deviceComplianceRequired + appActionIfDeviceComplianceRequired;
    Android uses requiredAndroidSafetyNetDeviceAttestationType + appActionIfAndroidSafetyNetDeviceAttestationFailed.

.NOTES
    Test ID: 51014
    Category: Devices
    Pillar: Devices
    Required API: Microsoft Graph beta — deviceManagement/managedDevices (Q1, count only)
                  deviceAppManagement/iosManagedAppProtections (Q2)
                  deviceAppManagement/androidManagedAppProtections (Q3)
#>

function Test-Assessment-51014 {
    [ZtTest(
        Category = 'Devices',
        CompatibleLicense = ('INTUNE_A'),
        ImplementationCost = 'Low',
        Pillar = 'Devices',
        RiskLevel = 'High',
        Service = ('Graph'),
        SfiPillar = 'Protect identities and secrets',
        TenantType = ('Workforce'),
        TestId = 51014,
        Title = 'App Protection Policies block managed-app access on jailbroken or rooted mobile devices',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose
    $activity = 'Checking App Protection Policies for jailbreak and root enforcement'

    # Q1: Count enrolled iOS / iPadOS devices
    Write-ZtProgress -Activity $activity -Status 'Counting enrolled iOS / iPadOS devices'
    $iosInvestigateReason     = $null
    $androidInvestigateReason = $null
    $iosDeviceCount           = 0
    $androidDeviceCount       = 0
    try {
        $iosResult      = Invoke-ZtGraphRequest -RelativeUri 'deviceManagement/managedDevices' -Filter "operatingSystem eq 'iOS' or operatingSystem eq 'iPadOS'" -Select 'id' -Top 1 -QueryParameters @{'$count' = 'true'} -ApiVersion beta -DisablePaging -ErrorAction Stop
        $iosDeviceCount = $iosResult.'@odata.count'
    }
    catch {
        Write-PSFMessage "Failed to retrieve iOS/iPadOS device count: $_" -Level Warning
        $iosInvestigateReason = 'Unable to retrieve enrolled iOS / iPadOS device count. Verify DeviceManagementManagedDevices.Read.All is granted and retry.'
    }

    # Q1 (continued): Count enrolled Android devices
    Write-ZtProgress -Activity $activity -Status 'Counting enrolled Android devices'
    try {
        $androidResult      = Invoke-ZtGraphRequest -RelativeUri 'deviceManagement/managedDevices' -Filter "operatingSystem eq 'Android'" -Select 'id' -Top 1 -QueryParameters @{'$count' = 'true'} -ApiVersion beta -DisablePaging -ErrorAction Stop
        $androidDeviceCount = $androidResult.'@odata.count'
    }
    catch {
        Write-PSFMessage "Failed to retrieve Android device count: $_" -Level Warning
        $androidInvestigateReason = 'Unable to retrieve enrolled Android device count. Verify DeviceManagementManagedDevices.Read.All is granted and retry.'
    }

    # If both Q1 queries failed we cannot determine scope for either platform — early-return Investigate.
    if ($iosInvestigateReason -and $androidInvestigateReason) {
        $params = @{
            TestId       = '51014'
            Title        = 'App Protection Policies block managed-app access on jailbroken or rooted mobile devices'
            Status       = $false
            Result       = '⚠️ Unable to retrieve enrolled device counts for iOS / iPadOS and Android. The API returned an authorization (401/403) or transient (5xx) error, so coverage could not be determined. Re-run after verifying caller permissions — Global Reader at tenant scope.'
            CustomStatus = 'Investigate'
        }
        Add-ZtTestResultDetail @params
        return
    }

    # A platform is in scope only when its Q1 succeeded and returned at least one enrolled device.
    $iosInScope     = ($null -eq $iosInvestigateReason)     -and ($iosDeviceCount     -gt 0)
    $androidInScope = ($null -eq $androidInvestigateReason) -and ($androidDeviceCount -gt 0)

    # If both Q1s succeeded but neither platform has enrolled devices, the check is not applicable.
    if ((-not $iosInScope) -and (-not $androidInScope) -and (-not $iosInvestigateReason) -and (-not $androidInvestigateReason)) {
        Add-ZtTestResultDetail -SkippedBecause NotApplicable -Result 'No iOS / iPadOS or Android devices are enrolled in this tenant; the check is not in scope.'
        return
    }

    # Q2: Retrieve all iOS App Protection Policies (only when iOS is in scope).
    $iosPolicies = @()
    if ($iosInScope) {
        Write-ZtProgress -Activity $activity -Status 'Retrieving iOS App Protection Policies'
        try {
            $iosPolicies = @(Invoke-ZtGraphRequest -RelativeUri 'deviceAppManagement/iosManagedAppProtections' -Select 'id,displayName,deviceComplianceRequired,appActionIfDeviceComplianceRequired,isAssigned' -ApiVersion beta -ErrorAction Stop)
        }
        catch {
            Write-PSFMessage "Failed to retrieve iOS App Protection Policies: $_" -Level Warning
            $iosInvestigateReason = 'Unable to retrieve iOS App Protection Policies. Verify DeviceManagementApps.Read.All is granted and retry.'
        }
    }

    # Q3: Retrieve all Android App Protection Policies (only when Android is in scope).
    $androidPolicies = @()
    if ($androidInScope) {
        Write-ZtProgress -Activity $activity -Status 'Retrieving Android App Protection Policies'
        try {
            $androidPolicies = @(Invoke-ZtGraphRequest -RelativeUri 'deviceAppManagement/androidManagedAppProtections' -Select 'id,displayName,requiredAndroidSafetyNetDeviceAttestationType,appActionIfAndroidSafetyNetDeviceAttestationFailed,isAssigned' -ApiVersion beta -ErrorAction Stop)
        }
        catch {
            Write-PSFMessage "Failed to retrieve Android App Protection Policies: $_" -Level Warning
            $androidInvestigateReason = 'Unable to retrieve Android App Protection Policies. Verify DeviceManagementApps.Read.All is granted and retry.'
        }
    }

    # If both platforms have a reason set (from Q1 or Q2/Q3 failures) neither can be evaluated — early-return Investigate.
    if ($iosInvestigateReason -and $androidInvestigateReason) {
        $params = @{
            TestId       = '51014'
            Title        = 'App Protection Policies block managed-app access on jailbroken or rooted mobile devices'
            Status       = $false
            Result       = '⚠️ The Intune App Protection Policies API returned an authorization (401/403) or transient (5xx) error, so coverage could not be determined. Re-run after verifying caller permissions — Global Reader at tenant scope.'
            CustomStatus = 'Investigate'
        }
        Add-ZtTestResultDetail @params
        return
    }
    #endregion Data Collection

    #region Assessment Logic
    $acceptableActions          = @('block', 'wipe')
    $acceptableAttestationTypes = @('basicIntegrity', 'basicIntegrityAndDeviceCertification')
    $iosDeepLinkTemplate        = 'https://intune.microsoft.com/#view/Microsoft_Intune/PolicyInstanceMenuBlade/~/0/policyId/{0}/policyOdataType/%23microsoft.graph.iosManagedAppProtection/policyName/{1}'
    $androidDeepLinkTemplate    = 'https://intune.microsoft.com/#view/Microsoft_Intune/PolicyInstanceMenuBlade/~/0/policyId/{0}/policyOdataType/%23microsoft.graph.androidManagedAppProtection/policyName/{1}'

    # Annotate each policy with Status and PolicyDeepLink once — used by both pass/fail logic and table rendering
    foreach ($policy in $iosPolicies) {
        $passes      = $policy.deviceComplianceRequired -eq $true -and
                       $policy.appActionIfDeviceComplianceRequired -in $acceptableActions -and
                       $policy.isAssigned -eq $true
        $encodedName = [System.Uri]::EscapeDataString($policy.displayName)
        $policy | Add-Member -MemberType NoteProperty -Name Status         -Value $passes -Force
        $policy | Add-Member -MemberType NoteProperty -Name PolicyDeepLink -Value ($iosDeepLinkTemplate -f $policy.id, $encodedName) -Force
    }

    foreach ($policy in $androidPolicies) {
        # Android root detection uses SafetyNet / Play Integrity attestation properties, not deviceComplianceRequired.
        # requiredAndroidSafetyNetDeviceAttestationType must be non-none, otherwise no attestation runs
        # and the appActionIf...Failed setting never fires — rooted devices silently pass through.
        $passes      = $policy.requiredAndroidSafetyNetDeviceAttestationType -in $acceptableAttestationTypes -and
                       $policy.appActionIfAndroidSafetyNetDeviceAttestationFailed -in $acceptableActions -and
                       $policy.isAssigned -eq $true
        $encodedName = [System.Uri]::EscapeDataString($policy.displayName)
        $policy | Add-Member -MemberType NoteProperty -Name Status         -Value $passes -Force
        $policy | Add-Member -MemberType NoteProperty -Name PolicyDeepLink -Value ($androidDeepLinkTemplate -f $policy.id, $encodedName) -Force
    }

    $iosPassingPolicies     = @($iosPolicies     | Where-Object Status)
    $androidPassingPolicies = @($androidPolicies | Where-Object Status)

    # Per-platform verdict — priority order: Investigate / Skipped / Pass / Fail
    $iosVerdict     = if ($iosInvestigateReason)               { 'Investigate' }
                      elseif (-not $iosInScope)                { 'Skipped' }
                      elseif ($iosPassingPolicies.Count -gt 0) { 'Pass' }
                      else                                     { 'Fail' }
    $androidVerdict = if ($androidInvestigateReason)               { 'Investigate' }
                      elseif (-not $androidInScope)                { 'Skipped' }
                      elseif ($androidPassingPolicies.Count -gt 0) { 'Pass' }
                      else                                         { 'Fail' }

    # Overall verdict — priority: Fail > Investigate > Pass
    $overallVerdict = if ($iosVerdict -eq 'Fail' -or $androidVerdict -eq 'Fail')                    { 'Fail' }
                      elseif ($iosVerdict -eq 'Investigate' -or $androidVerdict -eq 'Investigate')  { 'Investigate' }
                      else                                                                          { 'Pass' }

    $passed       = $overallVerdict -eq 'Pass'
    $customStatus = $null

    if ($overallVerdict -eq 'Investigate') {
        $customStatus       = 'Investigate'
        $testResultMarkdown = "The Intune App Protection Policies API returned an authorization (401/403) or transient (5xx) error, so coverage could not be determined. Re-run after verifying caller permissions — Global Reader at tenant scope.`n`n%TestResult%"
    }
    elseif ($passed) {
        $testResultMarkdown = "✅ For every in-scope mobile platform with enrolled devices, an assigned App Protection Policy blocks or wipes managed-app access on jailbroken / rooted devices.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "❌ One or more in-scope mobile platforms (iOS / iPadOS, Android) has no assigned App Protection Policy that blocks or wipes managed-app access on jailbroken / rooted devices — the MAM data-protection model can be silently bypassed by users on compromised personal devices.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    $portalLink = 'https://intune.microsoft.com/#view/Microsoft_Intune_DeviceSettings/AppsMenu/~/protection'
    $maxRows    = 10

    # Overall verdict line
    $overallMd = "**Overall: $overallVerdict**`n`n"

    # iOS / iPadOS section
    if ($iosVerdict -eq 'Investigate') {
        $iosTableMd = @"

### [iOS / iPadOS App Protection Policies — Jailbreak Gate]($portalLink)

**Status: Investigate** — $iosInvestigateReason

"@
    }
    elseif (-not $iosInScope) {
        $iosTableMd = @"

### [iOS / iPadOS App Protection Policies — Jailbreak Gate]($portalLink)

**Status: Skipped** — No iOS / iPadOS devices enrolled in this tenant.

"@
    }
    else {
        $iosTotalCount   = @($iosPolicies).Count
        $iosQualifyCount = @($iosPassingPolicies).Count
        $iosDeviceLabel  = if ($iosDeviceCount -eq 1) { 'device' } else { 'devices' }
        $iosPolicyLabel  = if ($iosTotalCount  -eq 1) { 'policy qualifies' } else { 'policies qualify' }
        $iosHeaderLine   = "**Status: $iosVerdict** — $iosDeviceCount iOS / iPadOS $iosDeviceLabel enrolled; $iosQualifyCount of $iosTotalCount $iosPolicyLabel."

        if ($iosTotalCount -eq 0) {
            $iosTableMd = @"

### [iOS / iPadOS App Protection Policies — Jailbreak Gate]($portalLink)

$iosHeaderLine

No App Protection Policies found for iOS / iPadOS.

"@
        }
        else {
            $iosRows = ''
            foreach ($policy in ($iosPolicies | Sort-Object @{ Expression = 'Status'; Descending = $true }, displayName | Select-Object -First $maxRows)) {
                $policyNameSafe = Get-SafeMarkdown $policy.displayName
                $complianceCell = if ($policy.deviceComplianceRequired) { '✅ True' } else { '❌ False' }
                $actionCell     = if ($policy.appActionIfDeviceComplianceRequired -in $acceptableActions) { "✅ $($policy.appActionIfDeviceComplianceRequired)" } else { "❌ $($policy.appActionIfDeviceComplianceRequired)" }
                $assignedCell   = if ($policy.isAssigned) { '✅ Yes' } else { '❌ No' }
                $statusCell     = if ($policy.Status) { '✅ Pass' } else { '❌ Fail' }
                $iosRows       += "| [$policyNameSafe]($($policy.PolicyDeepLink)) | $complianceCell | $actionCell | $assignedCell | $statusCell |`n"
            }
            if ($iosTotalCount -gt $maxRows) {
                $iosRows += "| ... | | | | _$iosTotalCount total_ |`n"
            }
            $iosTableMd = @"

### [iOS / iPadOS App Protection Policies — Jailbreak Gate]($portalLink)

$iosHeaderLine

| Policy name | Device compliance required | Action on Non-Compliance | Assigned | Status |
| :---------- | :------------------------- | :----------------------- | :------- | :----- |
$iosRows
"@
        }
    }

    # Android section
    if ($androidVerdict -eq 'Investigate') {
        $androidTableMd = @"

### [Android App Protection Policies — Root Gate]($portalLink)

**Status: Investigate** — $androidInvestigateReason

"@
    }
    elseif (-not $androidInScope) {
        $androidTableMd = @"

### [Android App Protection Policies — Root Gate]($portalLink)

**Status: Skipped** — No Android devices enrolled in this tenant.

"@
    }
    else {
        $androidTotalCount   = @($androidPolicies).Count
        $androidQualifyCount = @($androidPassingPolicies).Count
        $androidDeviceLabel  = if ($androidDeviceCount -eq 1) { 'device' } else { 'devices' }
        $androidPolicyLabel  = if ($androidTotalCount  -eq 1) { 'policy qualifies' } else { 'policies qualify' }
        $androidHeaderLine   = "**Status: $androidVerdict** — $androidDeviceCount Android $androidDeviceLabel enrolled; $androidQualifyCount of $androidTotalCount $androidPolicyLabel."

        if ($androidTotalCount -eq 0) {
            $androidTableMd = @"

### [Android App Protection Policies — Root Gate]($portalLink)

$androidHeaderLine

No App Protection Policies found for Android.

"@
        }
        else {
            $androidRows = ''
            foreach ($policy in ($androidPolicies | Sort-Object @{ Expression = 'Status'; Descending = $true }, displayName | Select-Object -First $maxRows)) {
                $policyNameSafe  = Get-SafeMarkdown $policy.displayName
                $attestationCell = if ($policy.requiredAndroidSafetyNetDeviceAttestationType -in $acceptableAttestationTypes) { "✅ $($policy.requiredAndroidSafetyNetDeviceAttestationType)" } else { "❌ $($policy.requiredAndroidSafetyNetDeviceAttestationType)" }
                $actionCell      = if ($policy.appActionIfAndroidSafetyNetDeviceAttestationFailed -in $acceptableActions) { "✅ $($policy.appActionIfAndroidSafetyNetDeviceAttestationFailed)" } else { "❌ $($policy.appActionIfAndroidSafetyNetDeviceAttestationFailed)" }
                $assignedCell    = if ($policy.isAssigned) { '✅ Yes' } else { '❌ No' }
                $statusCell      = if ($policy.Status) { '✅ Pass' } else { '❌ Fail' }
                $androidRows    += "| [$policyNameSafe]($($policy.PolicyDeepLink)) | $attestationCell | $actionCell | $assignedCell | $statusCell |`n"
            }
            if ($androidTotalCount -gt $maxRows) {
                $androidRows += "| ... | | | | _$androidTotalCount total_ |`n"
            }
            $androidTableMd = @"

### [Android App Protection Policies — Root Gate]($portalLink)

$androidHeaderLine

| Policy name | Attestation type requested | Action on attestation failure | Assigned | Status |
| :---------- | :------------------------- | :---------------------------- | :------- | :----- |
$androidRows
"@
        }
    }

    $mdInfo             = '{0}{1}{2}' -f $overallMd, $iosTableMd, $androidTableMd
    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '51014'
        Title  = 'App Protection Policies block managed-app access on jailbroken or rooted mobile devices'
        Status = $passed
        Result = $testResultMarkdown
    }
    if ($customStatus) {
        $params.CustomStatus = $customStatus
    }
    Add-ZtTestResultDetail @params
}
