<#
.SYNOPSIS

#>

function Test-Assessment-21841{
    [ZtTest(
    	Category = 'Access control',
    	ImplementationCost = 'Low',
    	Pillar = 'Identity',
    	RiskLevel = 'Low',
    	SfiPillar = 'Protect identities and secrets',
    	TenantType = ('Workforce','External'),
    	TestId = 21841,
    	Title = 'Authenticator app report suspicious activity is enabled',
    	UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "Checking Authenticator app report suspicious activity is enabled"
    Write-ZtProgress -Activity $activity -Status "Getting policy"

    $authMethodPolicy = Invoke-ZtGraphRequest -RelativeUri "policies/authenticationMethodsPolicy" -ApiVersion 'beta'

    $result = $false
    $testResultMarkdown = ""

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

        if($stateEnabled -and $targetAllUsers) {
            $result = $true
            $testResultMarkdown += "Authenticator app report suspicious activity is enabled for all users."
        }
        else {
            if(-not $stateEnabled) {
                $testResultMarkdown = "Authenticator app report suspicious activity is not enabled."
            }
            elseif(-not $targetAllUsers) {
                $testResultMarkdown += "Authenticator app report suspicious activity is not configured for all users."
            }
        }
    }
    else {
        $testResultMarkdown += "Authentication methods policy or report suspicious activity settings are not available."
    }

    $passed = $result

    $params = @{
        TestId             = '21841'
        Title              = "Authenticator app report suspicious activity is enabled"
        UserImpact         = 'Low'
        Risk               = 'Low'
        ImplementationCost = 'Low'
        AppliesTo          = 'Identity'
        Tag                = 'Identity'
        Status             = $passed
        Result             = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
