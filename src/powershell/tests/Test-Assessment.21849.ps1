<#
.SYNOPSIS
    Checks if Smart lockout duration is set to a minimum of 60 seconds.
#>

function Test-Assessment-21849{
    [ZtTest(
    	Category = 'Access control',
    	ImplementationCost = 'Low',
    	Pillar = 'Identity',
    	RiskLevel = 'Medium',
    	SfiPillar = 'Protect identities and secrets',
    	TenantType = ('Workforce','External'),
    	TestId = 21849,
    	Title = 'Smart lockout duration is set to a minimum of 60',
    	UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking Smart lockout duration is set to a minimum of 60'
    Write-ZtProgress -Activity $activity -Status 'Getting password rule settings'

    # Get the password rule settings
    $groupSettings = Invoke-ZtGraphRequest -RelativeUri 'Settings' -ApiVersion beta
    $passwordRuleSettings = $groupSettings | Where-Object { $_.displayName -eq 'Password Rule Settings' }

    $passed = $true
    $testResultMarkdown = ""

    $portalLink = 'https://entra.microsoft.com/#view/Microsoft_AAD_IAM/AuthenticationMethodsMenuBlade/~/PasswordProtection/fromNav/'

    if ($null -eq $passwordRuleSettings) {
        $passed = $true

        $mdInfo = "`n## Smart Lockout Settings`n`n"
        $mdInfo += "| Setting | Value |`n"
        $mdInfo += "| :---- | :---- |`n"
        $mdInfo += "| [Lockout Duration (seconds)]($portalLink) | 60 (Default) |`n"

        $testResultMarkdown = "Smart Lockout duration is configured to 60 seconds or higher.$mdInfo"
    }
    else {
        # Get the detailed settings for the Password Rule Settings group
        Write-ZtProgress -Activity $activity -Status 'Checking lockout duration setting'

        $lockoutDurationSetting = $passwordRuleSettings.values | Where-Object { $_.name -eq 'LockoutDurationInSeconds' }

        if ($null -eq $lockoutDurationSetting) {
            $passed = $true

            $mdInfo = "`n## Smart Lockout Settings`n`n"
            $mdInfo += "| Setting | Value |`n"
            $mdInfo += "| :---- | :---- |`n"
            $mdInfo += "| [Lockout Duration (seconds)]($portalLink) | 60 (Default) |`n"

            $testResultMarkdown = "Smart Lockout duration is configured to 60 seconds or higher.$mdInfo"
        }
        else {
            $lockoutDuration = [int]$lockoutDurationSetting.value

            $mdInfo = "`n## Smart Lockout Settings`n`n"
            $mdInfo += "| Setting | Value |`n"
            $mdInfo += "| :---- | :---- |`n"
            $mdInfo += "| [Lockout Duration (seconds)]($portalLink) | $lockoutDuration |`n"

            if ($lockoutDuration -ge 60) {
                $passed = $true
                $testResultMarkdown = "Smart Lockout duration is configured to 60 seconds or higher.$mdInfo"
            }
            else {
                $passed = $false
                $testResultMarkdown = "Smart Lockout duration is configured below 60 seconds.$mdInfo"
            }
        }
    }

    $params = @{
        TestId = '21849'
        Status = $passed
        Result = $testResultMarkdown
    }
    Add-ZtTestResultDetail @params
}
