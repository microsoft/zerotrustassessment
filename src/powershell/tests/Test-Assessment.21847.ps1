<#
.SYNOPSIS

#>

function Test-Assessment-21847 {
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "Checking Password protection for on-premises is enabled"
    Write-ZtProgress -Activity $activity -Status "Getting organization details"

    # Q1: Check if tenant has on-premises sync
    $orgResponse = Invoke-ZtGraphRequest -RelativeUri "organization?`$select=id,displayName,onPremisesSyncEnabled,onPremisesLastSyncDateTime" -ApiVersion v1.0

    if ($orgResponse.onPremisesSyncEnabled -ne $true)  {
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

            $mdInfo = "`n## Password Protection Settings`n`n"
            $mdInfo += "| Setting | Value |`n"
            $mdInfo += "| :---- | :---- |`n"
            $mdInfo += "| EnableBannedPasswordCheckOnPremises | $($enabledSetting.value) |`n"
            $mdInfo += "| BannedPasswordCheckOnPremisesMode | $($modeSetting.value) |`n"

            if ($enabledSetting.value -eq $true -and $modeSetting.value -eq "Enforce") {
                $passed = $true
                $testResultMarkdown = "✅ **Pass**: Entra password protection is enabled and enforced.%TestResult%"
            }
            else {
                $passed = $false
                $testResultMarkdown = "❌ **Fail**: Entra password protection is not enabled or not enforced.%TestResult%"
            }
        }
    }

    # Replace the placeholder with the detailed information
    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo

    $params = @{
        TestId             = '21847'
        Title             = "Password protection for on-premises is enabled"
        UserImpact        = 'Low'
        Risk              = 'High'
        ImplementationCost = 'Medium'
        AppliesTo         = 'Identity'
        Tag               = 'Identity'
        Status            = $passed
        Result            = $testResultMarkdown
    }
    Add-ZtTestResultDetail @params
}
