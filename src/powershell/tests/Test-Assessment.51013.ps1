<#
.SYNOPSIS
    App Protection Policies block managed-app access when user re-authentication fails (disabled Entra ID accounts, blocked sign-ins, expired tokens)

.DESCRIPTION
    Checks whether at least one assigned App Protection Policy on both iOS/iPadOS and Android
    enforces a block or wipe action when the managed app cannot re-authenticate the user.
    Per-platform scope is determined first by counting enrolled devices; a platform with zero
    enrolled devices is reported as Skipped rather than a false Fail.

.NOTES
    Test ID: 51013
    Category: Devices
    Pillar: Devices
    Required API: Microsoft Graph v1.0, beta
    Q1: deviceManagement/managedDevices - enrolled device counts per platform (v1.0)
    Q2: deviceAppManagement/iosManagedAppProtections (id, displayName, appActionIfUnableToAuthenticateUser, isAssigned) (beta)
    Q3: deviceAppManagement/androidManagedAppProtections (id, displayName, appActionIfUnableToAuthenticateUser, isAssigned) (beta)
#>

function Test-Assessment-51013 {
    [ZtTest(
        Category = 'Devices',
        ImplementationCost = 'Low',
        CompatibleLicense = ('INTUNE_A'),
        Pillar = 'Devices',
        RiskLevel = 'High',
        SfiPillar = 'Protect identities and secrets',
        TenantType = ('Workforce'),
        TestId = 51013,
        Title = 'App Protection Policies block managed-app access when user re-authentication fails (disabled Entra ID accounts, blocked sign-ins, expired tokens)',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking App Protection Policies for authentication failure enforcement'

    # Q1: Count enrolled iOS / iPadOS and Android devices to determine per-platform scope.
    # ConsistencyLevel defaults to eventual in Invoke-ZtGraphRequest; $count=true requires it.
    Write-ZtProgress -Activity $activity -Status 'Counting enrolled iOS / iPadOS devices'
    $iosDeviceCount     = 0
    $androidDeviceCount = 0

    try {
        $iosRaw = Invoke-ZtGraphRequest -RelativeUri 'deviceManagement/managedDevices' -Filter "operatingSystem eq 'iOS' or operatingSystem eq 'iPadOS'" -Select 'id' -Top 1 -QueryParameters @{ '$count' = 'true' } -DisablePaging -ApiVersion v1.0 -ErrorAction Stop
        $iosDeviceCount = $iosRaw.'@odata.count'

        Write-ZtProgress -Activity $activity -Status 'Counting enrolled Android devices'
        $androidRaw = Invoke-ZtGraphRequest -RelativeUri 'deviceManagement/managedDevices' -Filter "operatingSystem eq 'Android'" -Select 'id' -Top 1 -QueryParameters @{ '$count' = 'true' } -DisablePaging -ApiVersion v1.0 -ErrorAction Stop
        $androidDeviceCount = $androidRaw.'@odata.count'
    }
    catch {
        $statusCode = Get-ZtHttpStatusCode -ErrorRecord $_
        if ($statusCode -in @(401, 403)) {
            Write-PSFMessage "Error counting enrolled devices: HTTP $statusCode - insufficient permissions to read managedDevices." -Tag Test -Level Warning
        }
        else {
            Write-PSFMessage "Error counting enrolled devices: $($_.Exception.Message)" -Tag Test -Level Warning
        }
        $params = @{
            TestId       = '51013'
            Title        = 'App Protection Policies block managed-app access when user re-authentication fails (disabled Entra ID accounts, blocked sign-ins, expired tokens)'
            Status       = $false
            Result       = '⚠️ The Intune App Protection Policies API returned an authorization (401/403) or transient (5xx) error, so coverage could not be determined. Re-run after verifying caller permissions - Global Reader at tenant scope.'
            CustomStatus = 'Investigate'
        }
        Add-ZtTestResultDetail @params
        return
    }

    # Determine per-platform scope.
    $iosInScope     = $iosDeviceCount -gt 0
    $androidInScope = $androidDeviceCount -gt 0

    # If neither platform has enrolled devices this check is not applicable.
    if (-not $iosInScope -and -not $androidInScope) {
        Write-PSFMessage 'No iOS / iPadOS or Android devices enrolled - skipping App Protection Policy auth-failure check.' -Tag Test -Level VeryVerbose
        Add-ZtTestResultDetail -SkippedBecause NotApplicable
        return
    }

    # Q2 / Q3: Retrieve App Protection Policies for both platforms.
    Write-ZtProgress -Activity $activity -Status 'Getting iOS app protection policies'
    $iosPolicies     = @()
    $androidPolicies = @()

    try {
        $iosPolicies = @(Invoke-ZtGraphRequest -RelativeUri 'deviceAppManagement/iosManagedAppProtections' -Select 'id,displayName,appActionIfUnableToAuthenticateUser,isAssigned' -ApiVersion beta -ErrorAction Stop)

        Write-ZtProgress -Activity $activity -Status 'Getting Android app protection policies'
        $androidPolicies = @(Invoke-ZtGraphRequest -RelativeUri 'deviceAppManagement/androidManagedAppProtections' -Select 'id,displayName,appActionIfUnableToAuthenticateUser,isAssigned' -ApiVersion beta -ErrorAction Stop)
    }
    catch {
        $statusCode = Get-ZtHttpStatusCode -ErrorRecord $_
        if ($statusCode -in @(401, 403)) {
            Write-PSFMessage "Error querying App Protection Policies: HTTP $statusCode - insufficient permissions to read App Protection Policies." -Tag Test -Level Warning
        }
        else {
            Write-PSFMessage "Error querying App Protection Policies: $($_.Exception.Message)" -Tag Test -Level Warning
        }
        $params = @{
            TestId       = '51013'
            Title        = 'App Protection Policies block managed-app access when user re-authentication fails (disabled Entra ID accounts, blocked sign-ins, expired tokens)'
            Status       = $false
            Result       = '⚠️ The Intune App Protection Policies API returned an authorization (401/403) or transient (5xx) error, so coverage could not be determined. Re-run after verifying caller permissions - Global Reader at tenant scope.'
            CustomStatus = 'Investigate'
        }
        Add-ZtTestResultDetail @params
        return
    }
    #endregion Data Collection

    #region Assessment Logic
    # Only block or wipe constitute hard enforcement; warn, blockWhenSettingIsSupported, and null do not.
    $passingActions = @('block', 'wipe')

    $iosQualifyCount     = ($iosPolicies | Where-Object { $_.appActionIfUnableToAuthenticateUser -in $passingActions -and $_.isAssigned -eq $true }).Count
    $androidQualifyCount = ($androidPolicies | Where-Object { $_.appActionIfUnableToAuthenticateUser -in $passingActions -and $_.isAssigned -eq $true }).Count

    # A platform that is out of scope (no enrolled devices) is treated as passing and does not fail the overall check.
    $iosPass     = -not $iosInScope -or ($iosQualifyCount -gt 0)
    $androidPass = -not $androidInScope -or ($androidQualifyCount -gt 0)
    $passed      = $iosPass -and $androidPass

    if ($passed) {
        $testResultMarkdown = "✅ For every in-scope mobile platform with enrolled devices, an assigned App Protection Policy blocks or wipes managed-app access when the managed app cannot re-authenticate the user (disabled account, blocked sign-in, revoked token).`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "❌ One or more in-scope mobile platforms (iOS / iPadOS, Android) has no assigned App Protection Policy that blocks or wipes managed-app access on authentication failure - disabled accounts and revoked tokens retain a multi-hour window of access to corporate data on personally owned phones.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    $portalLink = 'https://intune.microsoft.com/#view/Microsoft_Intune_DeviceSettings/AppsMenu/~/protection'

    # Overall verdict line (rendered above the two platform sections).
    $overallVerdict = if ($passed) { 'Overall: Pass' } else { 'Overall: Fail' }
    $mdSections     = "`n**$overallVerdict**`n"

    foreach ($platformEntry in @(
        [pscustomobject]@{ Label = 'iOS / iPadOS'; Policies = $iosPolicies;     OdataType = 'iosManagedAppProtection';     InScope = $iosInScope;     DeviceCount = $iosDeviceCount;     QualifyCount = $iosQualifyCount;     Pass = $iosPass },
        [pscustomobject]@{ Label = 'Android';      Policies = $androidPolicies; OdataType = 'androidManagedAppProtection'; InScope = $androidInScope; DeviceCount = $androidDeviceCount; QualifyCount = $androidQualifyCount; Pass = $androidPass }
    )) {
        $platformLabel    = $platformEntry.Label
        $platformPolicies = @($platformEntry.Policies)
        $totalCount       = $platformPolicies.Count

        if (-not $platformEntry.InScope) {
            # Platform has no enrolled devices - render a Skipped stub (no table).
            $mdSections += @"

### $platformLabel App Protection Policies - Auth Failure Action

**Status: Skipped** - No $platformLabel devices enrolled in this tenant.

"@
            continue
        }

        $platformVerdict = if ($platformEntry.Pass) { 'Pass' } else { 'Fail' }
        $platformHeader  = "**Status: $platformVerdict** - $($platformEntry.DeviceCount) $platformLabel devices enrolled; $($platformEntry.QualifyCount) of $totalCount policies qualify."

        $tableRows = ''
        # Cap output at 10 rows per platform; append a summary row when the list is longer (per spec).
        $displayedPolicies = if ($totalCount -gt 10) { $platformPolicies[0..9] } else { $platformPolicies }
        foreach ($policy in $displayedPolicies) {
            $policyName    = Get-SafeMarkdown -Text $policy.displayName
            $encodedName   = [Uri]::EscapeDataString($policy.displayName)
            $policyLink    = 'https://intune.microsoft.com/#view/Microsoft_Intune/PolicyInstanceMenuBlade/~/0/policyId/{0}/policyOdataType/%23microsoft.graph.{1}/policyName/{2}' -f $policy.id, $platformEntry.OdataType, $encodedName
            # Map null/empty action to "not configured"; otherwise keep the enum value as-is.
            $actionLabel   = if ([string]::IsNullOrEmpty($policy.appActionIfUnableToAuthenticateUser)) { 'not configured' } else { $policy.appActionIfUnableToAuthenticateUser }
            $assignedLabel = if ($policy.isAssigned -eq $true) { '✅ Yes' } else { '❌ No' }
            $rowPassed     = ($policy.appActionIfUnableToAuthenticateUser -in $passingActions) -and ($policy.isAssigned -eq $true)
            $statusLabel   = if ($rowPassed) { '✅ Pass' } else { '❌ Fail' }
            $tableRows    += "| [$policyName]($policyLink) | $actionLabel | $assignedLabel | $statusLabel |`n"
        }

        if ($totalCount -gt 10) {
            $tableRows += "| ... and $($totalCount - 10) more policies | | | |`n"
        }

        $formatTemplate = @'

### {0} App Protection Policies - Auth Failure Action

{1}

| Policy Name | Action on Auth Failure | Assigned | Status |
| :---------- | :--------------------- | :------- | :----- |
{2}
'@
        $mdSections += $formatTemplate -f $platformLabel, $platformHeader, $tableRows
    }

    $formatOuter = @'

## [App Protection Policies - Unable to Authenticate Action]({0})
{1}
'@
    $mdInfo = $formatOuter -f $portalLink, $mdSections

    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '51013'
        Title  = 'App Protection Policies block managed-app access when user re-authentication fails (disabled Entra ID accounts, blocked sign-ins, expired tokens)'
        Status = $passed
        Result = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
