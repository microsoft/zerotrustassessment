<#
.SYNOPSIS

#>

function Test-Assessment-21802 {
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "Checking Authenticator app shows sign-in context"
    Write-ZtProgress -Activity $activity -Status "Getting authentication method policy"

    # Query Microsoft Authenticator authentication method configuration
    $authenticatorConfig = Invoke-ZtGraphRequest -RelativeUri 'authenticationMethodsPolicy/authenticationMethodConfigurations/MicrosoftAuthenticator' -ApiVersion 'v1.0'
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
    function Get-AuthenticatorFeatureSettingTarget {
        [CmdletBinding()]
        param(
            [Parameter(Mandatory)]
            [object]$Target
        )

        if ($Target.id -eq 'all_users') {
            return "All users"
        }
        elseif ($Target.id -eq '00000000-0000-0000-0000-000000000000') {
            return "No exclusions"
        }
        else {
            if ($Target.targetType -eq 'group') {
                $group = Invoke-ZtGraphRequest -RelativeUri "groups/$($Target.id)" -ApiVersion 'v1.0'
                "Group: $($group.displayName)"
            }
        }
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

    if ($appInfoEnabled) {$appEmoji = "✅"} else {$appEmoji = "❌"}
    if ($locationInfoEnabled) {$locationEmoji = "✅"} else {$locationEmoji = "❌"}

    # Build the detailed sections of the markdown

    # Define variables to insert into the format string
    $reportTitle = "Microsoft Authenticator settings"

    # Create a here-string with format placeholders {0}, {1}, etc.
    $formatTemplate = @"

## {0}


Feature Settings:

$appEmoji **Application Name**
- Status: $((Get-Culture).TextInfo.ToTitleCase($authenticatorConfig.featureSettings.displayAppInformationRequiredState.state.ToLower()))
- Include Target: $(Get-AuthenticatorFeatureSettingTarget -Target $authenticatorConfig.featureSettings.displayAppInformationRequiredState.includeTarget)
- Exclude Target: $(Get-AuthenticatorFeatureSettingTarget -Target $authenticatorConfig.featureSettings.displayAppInformationRequiredState.excludeTarget)

$locationEmoji **Geographic Location**
- Status: $((Get-Culture).TextInfo.ToTitleCase($authenticatorConfig.featureSettings.displayLocationInformationRequiredState.state.ToLower()))
- Include Target: $(Get-AuthenticatorFeatureSettingTarget -Target $authenticatorConfig.featureSettings.displayLocationInformationRequiredState.includeTarget)
- Exclude Target: $(Get-AuthenticatorFeatureSettingTarget -Target $authenticatorConfig.featureSettings.displayLocationInformationRequiredState.excludeTarget)

"@

    # Format the template by replacing placeholders with values
    $mdInfo = $formatTemplate -f $reportTitle

    # Replace the placeholder with the detailed information
    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo

    $params = @{
        TestId             = '21802'
        Title              = 'Authenticator app shows sign-in context'
        UserImpact         = 'Low'
        Risk               = 'Medium'
        ImplementationCost = 'Low'
        AppliesTo          = 'Identity'
        Tag                = 'Identity'
        Status             = $passed
        Result             = $testResultMarkdown
    }
    Add-ZtTestResultDetail @params

}
