<#
.SYNOPSIS
    Checks if organization has reduced password surface area by enabling multiple passwordless authentication methods
#>

function Test-Assessment-21889{
    [ZtTest(
    	Category = 'Access control',
    	ImplementationCost = 'Medium',
    	Pillar = 'Identity',
    	RiskLevel = 'High',
    	SfiPillar = 'Protect identities and secrets',
    	TenantType = ('Workforce','External'),
    	TestId = 21889,
    	Title = 'Reduce the user-visible password surface area',
    	UserImpact = 'Medium'
    )]
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking passwordless authentication methods configuration'
    Write-ZtProgress -Activity $activity -Status 'Getting authentication methods policy'

    # Get authentication methods policy
    $authMethodsPolicy = Invoke-ZtGraphRequest -RelativeUri 'policies/authenticationMethodsPolicy' -ApiVersion beta

    if (-not $authMethodsPolicy) {
        $testResultMarkdown = 'Unable to retrieve authentication methods policy.'
        $params = @{
            TestId = '21889'
            Status = $false
            Result = $testResultMarkdown
        }
        Add-ZtTestResultDetail @params
        return
    }

    # Extract FIDO2 and Microsoft Authenticator configurations
    $fido2Config = $authMethodsPolicy.authenticationMethodConfigurations | Where-Object { $_.id -eq 'Fido2' }
    $authenticatorConfig = $authMethodsPolicy.authenticationMethodConfigurations | Where-Object { $_.id -eq 'MicrosoftAuthenticator' }

    # Check FIDO2 configuration
    $fido2Enabled = $fido2Config.state -eq 'enabled'
    $fido2HasTargets = $fido2Config.includeTargets.Count -gt 0
    $fido2Valid = $fido2Enabled -and $fido2HasTargets

    # Check Microsoft Authenticator configuration
    $authEnabled = $authenticatorConfig.state -eq 'enabled'
    $authHasTargets = $authenticatorConfig.includeTargets.Count -gt 0
    $authMode = $authenticatorConfig.featureSettings.authenticationMode
    # Handle null or empty authMode
    if ([string]::IsNullOrEmpty($authMode)) {
        $authMode = 'Not configured'
        $authModeValid = $false
    } else {
        $authModeValid = ($authMode -eq 'any') -or ($authMode -eq 'deviceBasedPush')
    }
    $authValid = $authEnabled -and $authHasTargets -and $authModeValid

    # Determine pass/fail
    $passed = $fido2Valid -and $authValid

    # Build result message
    if ($passed) {
        $testResultMarkdown = 'Your organization has implemented multiple passwordless authentication methods reducing password exposure.%TestResult%'
    } else {
        $testResultMarkdown = 'Your organization relies heavily on password-based authentication, creating security vulnerabilities.%TestResult%'
    }

    # Build detailed markdown table
    $mdInfo = "`n## Passwordless authentication methods`n`n"
    $mdInfo += "| Method | State | Include targets | Authentication mode | Status |`n"
    $mdInfo += "| :----- | :---- | :-------------- | :------------------ | :----- |`n"

    # FIDO2 row
    $fido2State = if ($fido2Enabled) { '✅ Enabled' } else { '❌ Disabled' }
    $fido2TargetsDisplay = if ($fido2Config.includeTargets -is [array] -and $fido2Config.includeTargets.Count -gt 0) {
        ($fido2Config.includeTargets | ForEach-Object { Get-ZtAuthenticatorFeatureSettingTarget -Target $_ }) -join ', '
    } else {
        'None'
    }
    $fido2Status = if ($fido2Valid) { '✅ Pass' } else { '❌ Fail' }
    $mdInfo += "| FIDO2 Security Keys | $fido2State | $fido2TargetsDisplay | N/A | $fido2Status |`n"

    # Microsoft Authenticator row
    $authState = if ($authEnabled) { '✅ Enabled' } else { '❌ Disabled' }
    $authTargetsDisplay = if ($authenticatorConfig.includeTargets -is [array] -and $authenticatorConfig.includeTargets.Count -gt 0) {
        ($authenticatorConfig.includeTargets | ForEach-Object { Get-ZtAuthenticatorFeatureSettingTarget -Target $_ }) -join ', '
    } else {
        'None'
    }
    $authModeDisplay = if ($authModeValid) { "✅ $authMode" } else { "❌ $authMode" }
    $authStatus = if ($authValid) { '✅ Pass' } else { '❌ Fail' }
    $mdInfo += "| Microsoft Authenticator | $authState | $authTargetsDisplay | $authModeDisplay | $authStatus |`n"

    # Replace placeholder
    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo

    # Add test result
    $params = @{
        TestId = '21889'
        Status = $passed
        Result = $testResultMarkdown
    }
    Add-ZtTestResultDetail @params
}
