<#
.SYNOPSIS

#>

function Test-Assessment-21837{
    [ZtTest(
    	Category = 'Devices',
    	ImplementationCost = 'Low',
    	Pillar = 'Identity',
    	RiskLevel = 'High',
    	SfiPillar = 'Protect engineering systems',
    	TenantType = ('Workforce'),
    	TestId = 21837,
    	Title = 'Limit the maximum number of devices per user to 10',
    	UserImpact = 'Medium'
    )]
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking maximum number of devices per user limit'
    Write-ZtProgress -Activity $activity -Status 'Getting policy'

    # Retrieve device registration policy
    Write-ZtProgress -Activity $activity -Status 'Getting device registration policy'
    $policy = Invoke-ZtGraphRequest -RelativeUri 'policies/deviceRegistrationPolicy' -ApiVersion 'beta'
    $userQuota = $null
    if ($policy) { $userQuota = $policy.userDeviceQuota }

    # Evaluate compliance
    $passed = $false
    $customStatus = $null
    $entraDeviceSettingsLink = 'https://entra.microsoft.com/#view/Microsoft_AAD_Devices/DevicesMenuBlade/~/DeviceSettings/menuId/Overview'


    if ($null -eq $userQuota -or $userQuota -le 10) {
        #default is 10
        $passed = $true
        $testResultMarkdown = "[Maximum number of devices per user]($entraDeviceSettingsLink) is set to $userQuota"
    }
    elseif ($userQuota -gt 10 -and $userQuota -le 20) {
        $customStatus = 'Investigate'
        $testResultMarkdown = "[Maximum number of devices per user]($entraDeviceSettingsLink) is set to $userQuota. Consider reducing to 10 or fewer."
    }
    else {
        $testResultMarkdown = "[Maximum number of devices per user]($entraDeviceSettingsLink) is set to $userQuota. Consider reducing to 10 or fewer."
    }

    $params = @{
        TestId = '21837'
        Status = $passed
        Result = $testResultMarkdown
    }
    if ($customStatus) {
        $params.CustomStatus = $customStatus
    }
    Add-ZtTestResultDetail @params
}
