<#
.SYNOPSIS

#>

function Test-Assessment-21847 {

    [ZtTest(
        Category = 'Access control',
        ImplementationCost = 'Medium',
        Pillar = 'Identity',
        RiskLevel = 'High',
        SfiPillar = 'Protect identities and secrets',
        TenantType = ('Workforce'),
        TestId = 21847,
        Title = 'Password protection for on-premises is enabled',
        UserImpact = 'Low'
    )]

    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "Checking Password protection for on-premises is enabled"
    Write-ZtProgress -Activity $activity -Status "Getting organization details"

    # Q1: Check if tenant has on-premises sync
    $orgResponse = Invoke-ZtGraphRequest -RelativeUri "organization?`$select=id,displayName,onPremisesSyncEnabled,onPremisesLastSyncDateTime" -ApiVersion v1.0

    if ($orgResponse.onPremisesSyncEnabled -ne $true) {
        $passed = $true
        $testResultMarkdown = "✅ **Pass**: This tenant is not synchronized to an on-premises environment.%TestResult%"
    }
    else {
        # Q2: Check password protection settings
        Write-ZtProgress -Activity $activity -Status "Checking password protection settings"

        $pwdSettings = Invoke-ZtGraphRequest -RelativeUri "groupSettings" -ApiVersion v1.0 | Where-Object { $_.displayName -eq "Password Rule Settings" }

        if ($null -eq $pwdSettings) {
            $passed = $false
            $testResultMarkdown = "❌ **Fail**: Password protection settings were not found in the tenant configuration.%TestResult%"
        }
        else {
            $settingValues = Invoke-ZtGraphRequest -RelativeUri "groupSettings/$($pwdSettings.id)" -ApiVersion v1.0

            $enabledSetting = $settingValues.values | Where-Object { $_.name -eq "EnableBannedPasswordCheckOnPremises" }
            $modeSetting = $settingValues.values | Where-Object { $_.name -eq "BannedPasswordCheckOnPremisesMode" }

            $isPasswordProtectionEnabled = $enabledSetting.value -eq $true
            $passwordProtectionStatus = if ($isPasswordProtectionEnabled) {
                "✅ Enabled"
            }
            else {
                "❌ Disabled"
            }

            switch ($modeSetting.value) {
                "Enforce" {
                    $modeStatus = "✅ Enforce"
                }
                "Audit" {
                    $modeStatus = "❌ Audit"
                }
                default {
                    $modeStatus = "❌ Not Configured"
                }
            }

            $mdInfo = "`n## Password Protection Settings`n`n"
            $mdInfo += "| Setting | Value |`n"
            $mdInfo += "| :---- | :---- |`n"
            $mdInfo += "| Password Protection for Active Directory Domain Services | $passwordProtectionStatus |`n"
            $mdInfo += "| Enabled Mode (Audit/Enforce) | $($modeStatus) |`n"

            if ($enabledSetting.value -eq $true -and $modeSetting.value -eq "Enforce") {
                $passed = $true
                $testResultMarkdown = "✅ **Pass**: Entra password protection is enabled and enforced.`n%TestResult%"
            }
            else {
                $passed = $false
                if ($enabledSetting.value -ne $true) {
                    $testResultMarkdown = "`n❌ **Fail**: Password protection for on-premises is not enabled.`n%TestResult%"
                }
                else {
                    if ($modeSetting.value -ne "Enforce") {
                        $testResultMarkdown = "`n❌ **Fail**: Password protection for on-premises is not set to 'Enforce' mode.`n%TestResult%"
                    }
                    else {
                        $testResultMarkdown = "`n❌ **Fail**: Entra password protection is not properly configured.`n%TestResult%"
                    }
                }
            }
        }
    }

    # Replace the placeholder with the detailed information
    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo

    $params = @{
        TestId             = '21847'
        Status             = $passed
        Result             = $testResultMarkdown
    }
    Add-ZtTestResultDetail @params
}
