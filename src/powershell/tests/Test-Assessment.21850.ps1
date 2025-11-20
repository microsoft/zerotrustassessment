<#
.SYNOPSIS

#>

function Test-Assessment-21850 {
    [ZtTest(
    	Category = 'Credential management',
    	ImplementationCost = 'Low',
    	MinimumLicense = ('P1'),
    	Pillar = 'Identity',
    	RiskLevel = 'Medium',
    	SfiPillar = 'Protect identities and secrets',
    	TenantType = ('Workforce','External'),
    	TestId = 21850,
    	Title = 'Smart lockout threshold set to 10 or less',
    	UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "Checking Smart lockout threshold isn't greater than 10"
    Write-ZtProgress -Activity $activity -Status 'Getting password rule settings'

    # Get the Password Rule Settings template
    $allSettings = Invoke-ZtGraphRequest -RelativeUri 'settings' -ApiVersion beta

    $passwordRuleSettings = $allSettings |  Where-Object { $_.displayName -eq "Password Rule Settings" }

    $mdInfo = ""

    if ($null -eq $passwordRuleSettings) {
        # Test failed - Template not found
        $passed = $false
        $testResultMarkdown = "Password rule settings template not found.%TestResult%"
    }
    else {
        $portalLink = 'https://entra.microsoft.com/#view/Microsoft_AAD_IAM/AuthenticationMethodsMenuBlade/~/PasswordProtection/fromNav/'

        # Get the lockout threshold setting
        $lockoutThresholdSetting = $passwordRuleSettings.values | Where-Object { $_.name -eq "LockoutThreshold" }
        if ($null -eq $lockoutThresholdSetting) {
            # Test failed - Lockout threshold setting not found
            $passed = $false
            $testResultMarkdown = "Lockout threshold setting not found in [password rule settings]($portalLink).%TestResult%"
        }
        else {
            $lockoutThreshold = [int]$lockoutThresholdSetting.Value

            # Build info table
            $mdInfo = "`n## Smart lockout configuration`n`n"
            $mdInfo += "| Setting | Value |`n"
            $mdInfo += "| :---- | :---- |`n"
            $mdInfo += "| [Lockout threshold]($portalLink) | $(Get-SafeMarkdown($lockoutThreshold)) attempts|`n"

            if ($lockoutThreshold -le 10) {
                $passed = $true
                $testResultMarkdown = "Smart lockout threshold is set to 10 or below.%TestResult%"
            }
            else {
                $passed = $false
                $testResultMarkdown = "Smart lockout threshold is configured above 10.%TestResult%"
            }
        }
    }
    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo

    $params = @{
        TestId             = '21850'
        Status             = $passed
        Result             = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
