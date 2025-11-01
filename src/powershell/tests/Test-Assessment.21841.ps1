﻿<#
.SYNOPSIS

#>

function Test-Assessment-21841{
    [ZtTest(
    	Category = 'Credential management',
    	ImplementationCost = 'Low',
    	MinimumLicense = ('P1'),
    	Pillar = 'Identity',
    	RiskLevel = 'Medium',
    	SfiPillar = 'Protect identities and secrets',
    	TenantType = ('Workforce','External'),
    	TestId = 21841,
    	Title = 'Microsoft Authenticator app report suspicious activity setting is enabled',
    	UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "Checking Authenticator app report suspicious activity is enabled"
    Write-ZtProgress -Activity $activity -Status "Getting policy"

    $authMethodPolicy = Invoke-ZtGraphRequest -RelativeUri "policies/authenticationMethodsPolicy" -ApiVersion 'beta'

    $result = $false

    # Check if the policy and required properties exist
    if($authMethodPolicy -and $authMethodPolicy.PSObject.Properties['reportSuspiciousActivitySettings']) {
        $reportSettings = $authMethodPolicy.reportSuspiciousActivitySettings

        # Check if state property exists and has the correct value
        $stateEnabled = $reportSettings.PSObject.Properties['state'] -and $reportSettings.state -eq "enabled"

        # Check if includeTarget property exists and has the correct value
        $targetAllUsers = $false
        if($reportSettings.PSObject.Properties['includeTarget'] -and $reportSettings.includeTarget) {
            $targetAllUsers = $reportSettings.includeTarget.PSObject.Properties['id'] -and $reportSettings.includeTarget.id -eq "all_users"
        }

        $portalLink = 'https://entra.microsoft.com/#view/Microsoft_AAD_IAM/AuthenticationMethodsMenuBlade/~/AuthMethodsSettings'
        if($stateEnabled -and $targetAllUsers) {
            $result = $true
            $testResultMarkdown = "Authenticator app report suspicious activity is [enabled for all users]($portalLink)."
        }
        else {
            if(-not $stateEnabled) {
                $testResultMarkdown = "Authenticator app report suspicious activity is [not enabled]($portalLink)."
            }
            elseif(-not $targetAllUsers) {
                $testResultMarkdown = "Authenticator app report suspicious activity is [not configured for all users]($portalLink)."
            }
        }
    }
    else {
        $testResultMarkdown = "Authenticator app report suspicious activity is [not enabled]($portalLink)."
    }

    $passed = $result

    $params = @{
        TestId             = '21841'
        Status             = $passed
        Result             = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
