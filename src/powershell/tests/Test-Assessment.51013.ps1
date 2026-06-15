<#
.SYNOPSIS
    App Protection Policies block managed-app access when user re-authentication fails (disabled Entra ID accounts, blocked sign-ins, expired tokens)

.DESCRIPTION
    Checks whether at least one assigned App Protection Policy on both iOS and Android enforces
    a block or wipe action when the managed app cannot re-authenticate the user. Without this
    setting, disabled accounts and revoked tokens retain a multi-hour window of access to
    corporate data on personally owned phones.

.NOTES
    Test ID: 51013
    Category: Devices
    Pillar: Devices
    Required API: Microsoft Graph beta
    Q1: deviceAppManagement/iosManagedAppProtections (id, displayName, appActionIfUnableToAuthenticateUser, isAssigned)
    Q2: deviceAppManagement/androidManagedAppProtections (id, displayName, appActionIfUnableToAuthenticateUser, isAssigned)
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
    Write-ZtProgress -Activity $activity -Status 'Getting iOS app protection policies'

    $iosPolicies = @()
    $androidPolicies = @()

    try {
        # Q1: List all iOS app protection policies — auth-failure action and assignment state.
        $iosPolicies = @(Invoke-ZtGraphRequest -RelativeUri 'deviceAppManagement/iosManagedAppProtections?$select=id,displayName,appActionIfUnableToAuthenticateUser,isAssigned,deployedAppCount' -ApiVersion beta -ErrorAction Stop)

        Write-ZtProgress -Activity $activity -Status 'Getting Android app protection policies'
        # Q2: List all Android app protection policies — auth-failure action and assignment state.
        $androidPolicies = @(Invoke-ZtGraphRequest -RelativeUri 'deviceAppManagement/androidManagedAppProtections?$select=id,displayName,appActionIfUnableToAuthenticateUser,isAssigned,deployedAppCount' -ApiVersion beta -ErrorAction Stop)
    }
    catch {
        if ($_.Exception.Message -match '403|Forbidden|accessDenied') {
            Add-ZtTestResultDetail -SkippedBecause NotLicensedIntune
        }
        else {
            $params = @{
                TestId = '51013'
                Title  = 'App Protection Policies block managed-app access when user re-authentication fails (disabled Entra ID accounts, blocked sign-ins, expired tokens)'
                Status = $false
                Result = "⚠️ An error occurred while querying App Protection Policies: $($_.Exception.Message)"
            }
            Add-ZtTestResultDetail @params
        }
        return
    }
    #endregion Data Collection

    #region Assessment Logic
    # Only block or wipe constitute hard enforcement; warn, blockWhenSettingIsSupported, and null do not.
    $passingActions = @('block', 'wipe')

    $iosPass = ($iosPolicies | Where-Object {
        $_.appActionIfUnableToAuthenticateUser -in $passingActions -and $_.isAssigned -eq $true
    }).Count -gt 0

    $androidPass = ($androidPolicies | Where-Object {
        $_.appActionIfUnableToAuthenticateUser -in $passingActions -and $_.isAssigned -eq $true
    }).Count -gt 0

    $passed = $iosPass -and $androidPass

    if ($passed) {
        $testResultMarkdown = "✅ An assigned App Protection Policy blocks or wipes managed-app access on both iOS and Android when the managed app cannot re-authenticate the user (disabled account, blocked sign-in, revoked token).`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "❌ No assigned App Protection Policy blocks or wipes managed-app access on authentication failure for iOS, Android, or both — disabled accounts and revoked tokens retain a multi-hour window of access to corporate data on personally owned phones.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    $portalLink = 'https://intune.microsoft.com/#view/Microsoft_Intune_DeviceSettings/AppsMenu/~/protection'
    $maxRowsPerPlatform = 10
    $tableRows = ''

    foreach ($platformEntry in @(
        [pscustomobject]@{ Platform = 'iOS/iPadOS'; Policies = $iosPolicies;     OdataType = 'iosManagedAppProtection' },
        [pscustomobject]@{ Platform = 'Android';    Policies = $androidPolicies; OdataType = 'androidManagedAppProtection' }
    )) {
        $platformLabel   = $platformEntry.Platform
        $platformPolicies = @($platformEntry.Policies)
        $totalCount      = $platformPolicies.Count
        $displayPolicies = $platformPolicies | Select-Object -First $maxRowsPerPlatform

        foreach ($policy in $displayPolicies) {
            $policyName    = Get-SafeMarkdown -Text $policy.displayName
            $encodedName   = [Uri]::EscapeDataString($policy.displayName)
            $policyLink    = 'https://intune.microsoft.com/#view/Microsoft_Intune/PolicyInstanceMenuBlade/~/0/policyId/{0}/policyOdataType/%23microsoft.graph.{1}/policyName/{2}' -f $policy.id, $platformEntry.OdataType, $encodedName
            # Map null/empty action to "not configured"; otherwise keep the enum value as-is.
            $actionLabel   = if ([string]::IsNullOrEmpty($policy.appActionIfUnableToAuthenticateUser)) { 'not configured' } else { $policy.appActionIfUnableToAuthenticateUser }
            $assignedLabel = if ($policy.isAssigned -eq $true) { '✅ Yes' } else { '❌ No' }
            $rowPassed     = ($policy.appActionIfUnableToAuthenticateUser -in $passingActions) -and ($policy.isAssigned -eq $true)
            $statusLabel   = if ($rowPassed) { '✅ Pass' } else { '❌ Fail' }
            $tableRows    += "| $platformLabel | [$policyName]($policyLink) | $actionLabel | $assignedLabel | $statusLabel |`n"
        }

        # Truncate: show first 10 rows per platform plus a summary row when the total exceeds 10.
        if ($totalCount -gt $maxRowsPerPlatform) {
            $tableRows += "| $platformLabel | ... | | | $totalCount policies total |`n"
        }
    }

    if ($tableRows.Length -gt 0) {
        $formatTemplate = @'

## [App Protection Policies - Unable to Authenticate Action]({0})

| Platform | Policy name | Action on auth failure | Assigned | Status |
| :------- | :---------- | :--------------------- | :------- | :----- |
{1}
'@
        $mdInfo = $formatTemplate -f $portalLink, $tableRows
    }
    else {
        $mdInfo = "`nNo App Protection Policies are configured in this tenant.`n"
    }

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
