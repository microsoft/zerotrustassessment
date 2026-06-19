<#
.SYNOPSIS
    MAM app access timeout and re-authentication are enforced after idle period.

.DESCRIPTION
    Checks whether assigned Intune App Protection Policies for iOS / iPadOS and Android
    require app access requirements to be rechecked within 30 minutes while the device
    is online, with at least one access gate (app PIN or organizational credentials) enabled.
    Platforms that have no enrolled devices are reported as Skipped and do not affect the
    overall outcome.

.NOTES
    Test ID: 51019
    Category: Devices
    Pillar: Devices
    Required APIs:
      Q1: GET beta/deviceManagement/managedDevices?$filter=operatingSystem eq 'iOS' or operatingSystem eq 'iPadOS'&$top=1
          GET beta/deviceManagement/managedDevices?$filter=operatingSystem eq 'Android'&$top=1
      Q2: GET beta/deviceAppManagement/androidManagedAppProtections?$expand=assignments
      Q3: GET beta/deviceAppManagement/iosManagedAppProtections?$expand=assignments
    Required Permissions: DeviceManagementApps.Read.All, DeviceManagementManagedDevices.Read.All
#>

function Test-Assessment-51019 {
    [ZtTest(
        Category = 'Devices',
        CompatibleLicense = ('INTUNE_A'),
        ImplementationCost = 'Low',
        Pillar = 'Devices',
        RiskLevel = 'Medium',
        SfiPillar = 'Protect identities and secrets',
        TenantType = ('Workforce'),
        TestId = 51019,
        Title = 'MAM app access timeout and re-authentication are enforced after idle period',
        UserImpact = 'Medium'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking MAM app access recheck enforcement'

    # Q1: Determine platform scope — separate try/catch per platform so a failure on one
    # does not suppress results for the other.
    Write-ZtProgress -Activity $activity -Status 'Checking enrolled device platforms'
    $iosDeviceCount     = 0
    $androidDeviceCount = 0
    $iosQ1Error         = $false
    $androidQ1Error     = $false

    try {
        $iosResult      = Invoke-ZtGraphRequest -RelativeUri 'deviceManagement/managedDevices' -Filter "operatingSystem eq 'iOS' or operatingSystem eq 'iPadOS'" -Select 'id' -Top 1 -QueryParameters @{'$count' = 'true'} -ApiVersion beta -DisablePaging -ErrorAction Stop
        $iosDeviceCount = $iosResult.'@odata.count'
    }
    catch {
        $iosQ1Error = $true
        Write-PSFMessage "iOS/iPadOS enrolled-device query (Q1) failed: $_" -Tag Test -Level Warning
    }

    try {
        $androidResult      = Invoke-ZtGraphRequest -RelativeUri 'deviceManagement/managedDevices' -Filter "operatingSystem eq 'Android'" -Select 'id' -Top 1 -QueryParameters @{'$count' = 'true'} -ApiVersion beta -DisablePaging -ErrorAction Stop
        $androidDeviceCount = $androidResult.'@odata.count'
    }
    catch {
        $androidQ1Error = $true
        Write-PSFMessage "Android enrolled-device query (Q1) failed: $_" -Tag Test -Level Warning
    }

    # If both Q1 queries failed, scope cannot be determined at all — stop early.
    if ($iosQ1Error -and $androidQ1Error) {
        $params = @{
            TestId       = '51019'
            Title        = 'MAM app access timeout and re-authentication are enforced after idle period'
            Status       = $false
            Result       = '⚠️ Unable to retrieve enrolled device counts for iOS / iPadOS and Android due to API access errors. Coverage could not be determined. Verify DeviceManagementManagedDevices.Read.All permission is granted and retry.'
            CustomStatus = 'Investigate'
        }
        Add-ZtTestResultDetail @params
        return
    }

    $iosInScope     = -not $iosQ1Error     -and $iosDeviceCount     -gt 0
    $androidInScope = -not $androidQ1Error -and $androidDeviceCount -gt 0

    # A Q1 error means scope is unknown for that platform — treat as Investigate (not Skipped).
    # Skipped is only used when Q1 succeeded and confirmed zero enrolled devices.
    if (-not $iosInScope -and -not $androidInScope -and -not $iosQ1Error -and -not $androidQ1Error) {
        Add-ZtTestResultDetail -SkippedBecause NotApplicable -Result 'No iOS / iPadOS or Android devices are enrolled in this tenant.'
        return
    }

    # Q2: Android App Protection Policies — separate try/catch so an iOS failure does not suppress Android results.
    $androidPolicies = @()
    $androidError    = $false
    if ($androidInScope) {
        Write-ZtProgress -Activity $activity -Status 'Getting Android App Protection Policies'
        try {
            $androidPolicies = @(Invoke-ZtGraphRequest -RelativeUri 'deviceAppManagement/androidManagedAppProtections?$expand=assignments' -ApiVersion beta -ErrorAction Stop)
        }
        catch {
            $androidError = $true
            Write-PSFMessage "Android App Protection Policy query failed: $_" -Tag Test -Level Warning
        }
    }

    # Q3: iOS/iPadOS App Protection Policies — separate try/catch so an Android failure does not suppress iOS results.
    $iosPolicies = @()
    $iosError    = $false
    if ($iosInScope) {
        Write-ZtProgress -Activity $activity -Status 'Getting iOS/iPadOS App Protection Policies'
        try {
            $iosPolicies = @(Invoke-ZtGraphRequest -RelativeUri 'deviceAppManagement/iosManagedAppProtections?$expand=assignments' -ApiVersion beta -ErrorAction Stop)
        }
        catch {
            $iosError = $true
            Write-PSFMessage "iOS/iPadOS App Protection Policy query failed: $_" -Tag Test -Level Warning
        }
    }
    #endregion Data Collection

    #region Assessment Logic
    # A policy qualifies when: assigned, online recheck <= 30 min, at least one access gate active.
    # periodOnlineBeforeAccessCheck is an ISO 8601 duration (e.g. PT30M, PT1H, PT0S).
    # PT0S (immediate recheck = 0 min) is the strictest valid setting and qualifies.
    # Null / empty means no timeout is configured — the policy does not qualify.
    # Convert ISO 8601 duration to TimeSpan for numeric comparison against 30-minute threshold.
    $androidQualifying = @()
    if (-not $androidError) {
        foreach ($policy in $androidPolicies) {
            if ($policy.isAssigned -eq $true -and
                -not [string]::IsNullOrEmpty($policy.periodOnlineBeforeAccessCheck) -and
                ($policy.pinRequired -eq $true -or $policy.organizationalCredentialsRequired -eq $true)) {
                try {
                    $timeSpan = [System.Xml.XmlConvert]::ToTimeSpan($policy.periodOnlineBeforeAccessCheck)
                    if ($timeSpan.TotalMinutes -le 30) {
                        $androidQualifying += $policy
                    }
                }
                catch {
                    Write-PSFMessage "Android policy '$($policy.displayName)' has malformed periodOnlineBeforeAccessCheck '$($policy.periodOnlineBeforeAccessCheck)'; treating as non-qualifying." -Tag Test -Level Warning
                }
            }
        }
    }

    $iosQualifying = @()
    if (-not $iosError) {
        foreach ($policy in $iosPolicies) {
            if ($policy.isAssigned -eq $true -and
                -not [string]::IsNullOrEmpty($policy.periodOnlineBeforeAccessCheck) -and
                ($policy.pinRequired -eq $true -or $policy.organizationalCredentialsRequired -eq $true)) {
                try {
                    $timeSpan = [System.Xml.XmlConvert]::ToTimeSpan($policy.periodOnlineBeforeAccessCheck)
                    if ($timeSpan.TotalMinutes -le 30) {
                        $iosQualifying += $policy
                    }
                }
                catch {
                    Write-PSFMessage "iOS/iPadOS policy '$($policy.displayName)' has malformed periodOnlineBeforeAccessCheck '$($policy.periodOnlineBeforeAccessCheck)'; treating as non-qualifying." -Tag Test -Level Warning
                }
            }
        }
    }

    $androidVerdict = if ($androidQ1Error)                   { 'Investigate' }
                      elseif (-not $androidInScope)           { 'Skipped'     }
                      elseif ($androidError)                  { 'Investigate' }
                      elseif ($androidQualifying.Count -gt 0) { 'Pass'        }
                      else                                    { 'Fail'        }

    $iosVerdict     = if ($iosQ1Error)                       { 'Investigate' }
                      elseif (-not $iosInScope)               { 'Skipped'     }
                      elseif ($iosError)                      { 'Investigate' }
                      elseif ($iosQualifying.Count -gt 0)     { 'Pass'        }
                      else                                    { 'Fail'        }

    $anyInvestigate = ($androidVerdict -eq 'Investigate') -or ($iosVerdict -eq 'Investigate')

    # Overall: pass only when every in-scope platform passes (Investigate counts as non-pass).
    $passed = -not $anyInvestigate -and (-not $iosInScope -or $iosVerdict -eq 'Pass') -and (-not $androidInScope -or $androidVerdict -eq 'Pass')

    $investigateMsg = 'The Intune App Protection Policies API returned an authorization (401/403) or transient (5xx) error, so coverage could not be determined. Re-run after verifying caller permissions — Global Reader at tenant scope.'

    if ($anyInvestigate) {
        $testResultMarkdown = "⚠️ $investigateMsg`n`n%TestResult%"
    }
    elseif ($passed) {
        $testResultMarkdown = "✅ For every in-scope mobile platform with enrolled devices, assigned MAM App Protection Policies recheck app access requirements within 30 minutes and enforce an access gate such as app PIN or organizational credentials.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "❌ One or more in-scope mobile platforms (iOS / iPadOS, Android) has no assigned App Protection Policy that enforces a 30-minute-or-less app access recheck window with an app PIN or organizational credential gate.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    $portalUrl = 'https://intune.microsoft.com/#view/Microsoft_Intune_DeviceSettings/AppsMenu/~/protection'

    # Overall verdict line rendered above the two per-platform sections.
    $overallVerdictLine = if ($anyInvestigate) { 'Overall: Investigate' }
                          elseif ($passed)     { 'Overall: Pass' }
                          else                 { 'Overall: Fail' }
    $mdInfo = "$overallVerdictLine`n`n"

    foreach ($platformConfig in @(
        [PSCustomObject]@{ Name = 'iOS / iPadOS'; InScope = $iosInScope;     Verdict = $iosVerdict;     Error = ($iosQ1Error -or $iosError);         Policies = $iosPolicies;     DeviceCount = $iosDeviceCount;     OdataType = '%23microsoft.graph.iosManagedAppProtection'     },
        [PSCustomObject]@{ Name = 'Android';      InScope = $androidInScope; Verdict = $androidVerdict; Error = ($androidQ1Error -or $androidError); Policies = $androidPolicies; DeviceCount = $androidDeviceCount; OdataType = '%23microsoft.graph.androidManagedAppProtection' }
    )) {
        $platformTitle = "$($platformConfig.Name) App Protection Policies — Access Recheck Enforcement"

        if ($platformConfig.Error) {
            $mdInfo += "### [$platformTitle]($portalUrl)`n`n"
            $mdInfo += "**Status: Investigate** — Unable to retrieve $($platformConfig.Name) app protection policies or device enrollment status. Verify permissions and re-run the assessment.`n`n"
            continue
        }

        if (-not $platformConfig.InScope) {
            $mdInfo += "### [$platformTitle]($portalUrl)`n`n"
            $mdInfo += "**Status: Skipped** — No $($platformConfig.Name) devices enrolled in this tenant.`n`n"
            continue
        }

        $allPolicies  = @($platformConfig.Policies)
        # Reuse qualifying counts already computed in Assessment Logic — no need to re-filter.
        $qualifyCount = if ($platformConfig.Name -eq 'Android') { $androidQualifying.Count } else { $iosQualifying.Count }

        $verdictMd  = if ($platformConfig.Verdict -eq 'Pass') { 'Pass' } else { 'Fail' }
        $statusLine = "**Status: $verdictMd** — $($platformConfig.DeviceCount) $($platformConfig.Name) devices enrolled; $qualifyCount of $($allPolicies.Count) policies qualify."

        $displayedPolicies = if ($allPolicies.Count -gt 10) { $allPolicies[0..9] } else { $allPolicies }

        $tableRows = ''
        foreach ($policy in $displayedPolicies) {
            $encodedName   = [uri]::EscapeDataString($policy.displayName)
            $policyLink    = "https://intune.microsoft.com/#view/Microsoft_Intune/PolicyInstanceMenuBlade/~/0/policyId/$($policy.id)/policyOdataType/$($platformConfig.OdataType)/policyName/$encodedName"
            $policyName    = Get-SafeMarkdown $policy.displayName
            $onlineRecheck = if ([string]::IsNullOrEmpty($policy.periodOnlineBeforeAccessCheck)) { '—' } else { $policy.periodOnlineBeforeAccessCheck }
            $pinMd         = if ($policy.pinRequired) { '✅ Yes' } else { '❌ No' }
            $orgCredsMd    = if ($policy.organizationalCredentialsRequired) { '✅ Yes' } else { '❌ No' }
            $assignedMd    = if ($policy.isAssigned) { '✅ Yes' } else { '❌ No' }
            # Per-policy verdict: Pass when all qualifying conditions are met.
            $qualifies     = $false
            if ($policy.isAssigned -eq $true -and
                -not [string]::IsNullOrEmpty($policy.periodOnlineBeforeAccessCheck) -and
                ($policy.pinRequired -eq $true -or $policy.organizationalCredentialsRequired -eq $true)) {
                try {
                    $timeSpan = [System.Xml.XmlConvert]::ToTimeSpan($policy.periodOnlineBeforeAccessCheck)
                    $qualifies = ($timeSpan.TotalMinutes -le 30)
                }
                catch {
                    # Malformed duration — treat as non-qualifying
                    $qualifies = $false
                }
            }
            $policyStatus  = if ($qualifies) { '✅ Pass' } else { '❌ Fail' }
            $tableRows    += "| [$policyName]($policyLink) | $onlineRecheck | $pinMd | $orgCredsMd | $assignedMd | $policyStatus |`n"
        }

        if ($allPolicies.Count -gt 10) {
            $tableRows += "| ... and $($allPolicies.Count - 10) more policies | | | | | |`n"
        }

        $mdInfo += "### [$platformTitle]($portalUrl)`n`n$statusLine`n`n"
        $mdInfo += "| Policy name | Online recheck | App PIN required | Organizational credentials required | Assigned | Status |`n"
        $mdInfo += "| :---------- | :------------- | :--------------- | :---------------------------------- | :------- | :----- |`n"
        $mdInfo += $tableRows
        $mdInfo += "`n"
    }

    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '51019'
        Title  = 'MAM app access timeout and re-authentication are enforced after idle period'
        Status = $passed
        Result = $testResultMarkdown
    }
    if ($anyInvestigate) { $params['CustomStatus'] = 'Investigate' }
    Add-ZtTestResultDetail @params
}
