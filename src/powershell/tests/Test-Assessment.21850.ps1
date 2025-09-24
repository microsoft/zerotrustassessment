<#
.SYNOPSIS

#>

function Test-Assessment-21850 {
    [ZtTest(
    	Category = 'Access control',
    	ImplementationCost = 'Low',
    	Pillar = 'Identity',
    	RiskLevel = 'Medium',
    	SfiPillar = 'Protect identities and secrets',
    	TenantType = ('Workforce','External'),
    	TestId = 21850,
    	Title = 'Smart lockout threshold isn''t greater than 10',
    	UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "Checking Smart lockout threshold isn't greater than 10"
    Write-ZtProgress -Activity $activity -Status "Getting password rule settings"

    # Get the Password Rule Settings template
    $passwordRuleSettings = Invoke-ZtGraphRequest -RelativeUri "directorySettingTemplates/5cf42378-d67d-4f36-ba46-e8b86229381d" -ApiVersion beta

    $mdInfo = ""

    if ($null -eq $passwordRuleSettings) {
        # Test Failed - Template not found
        $passed = $false
        $testResultMarkdown = "Password Rule Settings template not found.%TestResult%"
    }
    else {
        # Find the LockoutThreshold setting
        $lockoutThresholdSetting = $passwordRuleSettings.values | Where-Object { $_.name -eq "LockoutThreshold" }

        if ($null -eq $lockoutThresholdSetting) {
            # Test Failed - LockoutThreshold Setting not found
            $passed = $false
            $testResultMarkdown = "LockoutThreshold setting not found in Password Rule Settings.%TestResult%"
        }
        else {
            $lockoutThreshold = [int]$lockoutThresholdSetting.defaultValue

            # Build info table
            $mdInfo = "`n## Smart Lockout Configuration`n`n"
            $mdInfo += "| Setting | Value |`n"
            $mdInfo += "| :---- | :---- |`n"
            $mdInfo += "| Lockout Threshold | $lockoutThreshold |`n"

            if ($lockoutThreshold -gt 10) {
                $passed = $true
                $testResultMarkdown = "Smart lockout threshold is configured above 10.%TestResult%"
            }
            else {
                $passed = $false
                $testResultMarkdown = "Smart lockout threshold is set to 10 or below.%TestResult%"
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
