<#
.SYNOPSIS

#>

function Test-Assessment-21802 {
    [ZtTest(
    	Category = 'Access control',
    	ImplementationCost = 'Low',
    	Pillar = 'Identity',
    	RiskLevel = 'Medium',
    	SfiPillar = 'Protect identities and secrets',
    	TenantType = ('Workforce','External'),
    	TestId = 21802,
    	Title = 'Authenticator app shows sign-in context',
    	UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking Authenticator app shows sign-in context'
    Write-ZtProgress -Activity $activity -Status 'Getting authentication method policy'

    # Query Microsoft Authenticator authentication method configuration
    $authenticatorConfig = Invoke-ZtGraphRequest -RelativeUri 'authenticationMethodsPolicy/authenticationMethodConfigurations/MicrosoftAuthenticator' -ApiVersion beta
    function Test-AuthenticatorFeatureSetting {
        [CmdletBinding()]
        param(
            [Parameter(Mandatory)]
            [object]$FeatureSetting
        )

        $FeatureSetting.state -eq 'enabled' -and
        $FeatureSetting.includeTarget.id -eq 'all_users' -and
        $FeatureSetting.excludeTarget.id -eq '00000000-0000-0000-0000-000000000000'
    }

    # Check if both app information and location information are properly configured
    $appInfoEnabled = Test-AuthenticatorFeatureSetting -FeatureSetting $authenticatorConfig.featureSettings.displayAppInformationRequiredState
    $locationInfoEnabled = Test-AuthenticatorFeatureSetting -FeatureSetting $authenticatorConfig.featureSettings.displayLocationInformationRequiredState

    if ($appInfoEnabled -and $locationInfoEnabled) {
        $passed = $true
        $testResultMarkdown = "Microsoft Authenticator shows application name and geographic location in push notifications.`n`n%TestResult%"
    } else {
        $passed = $false
        $testResultMarkdown = "Microsoft Authenticator notifications lack sign-in context.`n`n%TestResult%"
    }

    if ($appInfoEnabled) {$appEmoji = '✅'} else {$appEmoji = '❌'}
    if ($locationInfoEnabled) {$locationEmoji = '✅'} else {$locationEmoji = '❌'}

    # Build the detailed sections of the markdown

    # Define variables to insert into the format string
    $reportTitle = 'Microsoft Authenticator settings'

    # Create a here-string with format placeholders {0}, {1}, etc.
    $formatTemplate = @"

## {0}


Feature settings:

$appEmoji **Application name**
- Status: $((Get-Culture).TextInfo.ToTitleCase($authenticatorConfig.featureSettings.displayAppInformationRequiredState.state.ToLower()))
- Include target: $(if ($authenticatorConfig.featureSettings.displayAppInformationRequiredState.includeTarget -is [array]) { ($authenticatorConfig.featureSettings.displayAppInformationRequiredState.includeTarget | ForEach-Object { Get-ZtAuthenticatorFeatureSettingTarget -Target $_ }) -join ', ' } else { Get-ZtAuthenticatorFeatureSettingTarget -Target $authenticatorConfig.featureSettings.displayAppInformationRequiredState.includeTarget })
- Exclude target: $(if ($authenticatorConfig.featureSettings.displayAppInformationRequiredState.excludeTarget -is [array]) { ($authenticatorConfig.featureSettings.displayAppInformationRequiredState.excludeTarget | ForEach-Object { Get-ZtAuthenticatorFeatureSettingTarget -Target $_ }) -join ', ' } else { Get-ZtAuthenticatorFeatureSettingTarget -Target $authenticatorConfig.featureSettings.displayAppInformationRequiredState.excludeTarget })

$locationEmoji **Geographic location**
- Status: $((Get-Culture).TextInfo.ToTitleCase($authenticatorConfig.featureSettings.displayLocationInformationRequiredState.state.ToLower()))
- Include target: $(if ($authenticatorConfig.featureSettings.displayLocationInformationRequiredState.includeTarget -is [array]) { ($authenticatorConfig.featureSettings.displayLocationInformationRequiredState.includeTarget | ForEach-Object { Get-ZtAuthenticatorFeatureSettingTarget -Target $_ }) -join ', ' } else { Get-ZtAuthenticatorFeatureSettingTarget -Target $authenticatorConfig.featureSettings.displayLocationInformationRequiredState.includeTarget })
- Exclude target: $(if ($authenticatorConfig.featureSettings.displayLocationInformationRequiredState.excludeTarget -is [array]) { ($authenticatorConfig.featureSettings.displayLocationInformationRequiredState.excludeTarget | ForEach-Object { Get-ZtAuthenticatorFeatureSettingTarget -Target $_ }) -join ', ' } else { Get-ZtAuthenticatorFeatureSettingTarget -Target $authenticatorConfig.featureSettings.displayLocationInformationRequiredState.excludeTarget })

"@

    # Format the template by replacing placeholders with values
    $mdInfo = $formatTemplate -f $reportTitle

    # Replace the placeholder with the detailed information
    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo

    $params = @{
        TestId             = '21802'
        Status             = $passed
        Result             = $testResultMarkdown
    }
    Add-ZtTestResultDetail @params

}
