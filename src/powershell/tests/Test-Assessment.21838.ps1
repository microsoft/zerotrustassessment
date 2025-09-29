<#
.SYNOPSIS

#>

function Test-Assessment-21838 {
    [ZtTest(
    	Category = 'Access control',
    	ImplementationCost = 'Low',
    	Pillar = 'Identity',
    	RiskLevel = 'High',
    	SfiPillar = 'Protect identities and secrets',
    	TenantType = ('Workforce','External'),
    	TestId = 21838,
    	Title = 'Security key authentication method enabled',
    	UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking security key authentication method enabled'
    Write-ZtProgress -Activity $activity -Status 'Getting FIDO2 authentication method policy'

    # Query FIDO2 authentication method configuration
    $fido2Config = Invoke-ZtGraphRequest -RelativeUri 'authenticationMethodsPolicy/authenticationMethodConfigurations/FIDO2' -ApiVersion beta

    # Check if FIDO2 authentication method is enabled
    $fido2Enabled = $fido2Config.state -eq 'enabled'

    if ($fido2Enabled) {
        $passed = $true
        $testResultMarkdown = "Security key authentication method is enabled for your tenant, providing hardware-backed phishing-resistant authentication.`n`n%TestResult%"
        $statusEmoji = '✅'
    } else {
        $passed = $false
        $testResultMarkdown = "Security key authentication method is not enabled; users cannot register FIDO2 security keys for strong authentication.`n`n%TestResult%"
        $statusEmoji = '❌'
    }

    # Build the detailed sections of the markdown
    $reportTitle = 'FIDO2 security key authentication settings'

    # Create a here-string with format placeholders {0}, {1}, etc.
    $formatTemplate = @"

## {0}

$statusEmoji **FIDO2 authentication method**
- Status: $((Get-Culture).TextInfo.ToTitleCase($fido2Config.state.ToLower()))
- Include targets: $(if ($fido2Config.includeTargets -is [array] -and $fido2Config.includeTargets.Count -gt 0) { ($fido2Config.includeTargets | ForEach-Object { Get-ZtAuthenticatorFeatureSettingTarget -Target $_ }) -join ', ' } else { 'None' })
- Exclude targets: $(if ($fido2Config.excludeTargets -is [array] -and $fido2Config.excludeTargets.Count -gt 0) { ($fido2Config.excludeTargets | ForEach-Object { Get-ZtAuthenticatorFeatureSettingTarget -Target $_ }) -join ', ' } else { 'None' })


"@

    # Format the template by replacing placeholders with values
    $mdInfo = $formatTemplate -f $reportTitle

    # Replace the placeholder with the detailed information
    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo

    $params = @{
        TestId             = '21838'
        Status             = $passed
        Result             = $testResultMarkdown
    }
    Add-ZtTestResultDetail @params

}
