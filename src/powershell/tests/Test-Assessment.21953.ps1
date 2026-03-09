<#
.SYNOPSIS
    Checks if Local Admin Password Solution (LAPS) is deployed in the tenant.
#>

function Test-Assessment-21953{
    [ZtTest(
    	Category = 'Devices',
    	ImplementationCost = 'Medium',
    	MinimumLicense = ('P1'),
    	Pillar = 'Identity',
    	RiskLevel = 'High',
    	SfiPillar = 'Protect identities and secrets',
    	TenantType = ('Workforce','External'),
    	TestId = 21953,
    	Title = 'Local Admin Password Solution is deployed',
    	UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking Local Admin Password Solution is deployed'
    Write-ZtProgress -Activity $activity -Status 'Getting LAPS settings'

    $lapsSettings = Invoke-ZtGraphRequest -RelativeUri 'policies/deviceRegistrationPolicy' -ApiVersion beta

    $passed = $true
    $testResultMarkdown = ""

    if ($null -eq $lapsSettings) {
        $passed = $false
        $testResultMarkdown = 'Device Registration Policy settings were not found in the tenant configuration.'
    }
    else {
        Write-ZtProgress -Activity $activity -Status 'Checking LAPS configuration'

        $portalLink = 'https://entra.microsoft.com/#view/Microsoft_AAD_Devices/DevicesMenuBlade/~/DeviceSettings/menuId/Overview'

        $lapsEnabled = ${lapsSettings}?.localAdminPassword?.isEnabled -eq $true
        $lapsStatus = if ($lapsEnabled) { 'Enabled' } else { 'Disabled' }

        $mdInfo = "`n## Local Admin Password Solution (LAPS) settings`n`n"
        $mdInfo += "| Setting | Status |`n"
        $mdInfo += "| :---- | :---- |`n"
        $mdInfo += "|[Enable Microsoft Entra Local Administrator Password Solution (LAPS)]($portalLink) | $lapsStatus`n"

        if ($lapsEnabled) {
            $passed = $true
            $testResultMarkdown = "Local Admin Password Solution is deployed.$mdInfo"
        }
        else {
            $passed = $false
            $testResultMarkdown = "Local Admin Password Solution is not deployed.$mdInfo"
        }
    }

    $params = @{
        TestId = '21953'
        Status = $passed
        Result = $testResultMarkdown
    }
    Add-ZtTestResultDetail @params
}
