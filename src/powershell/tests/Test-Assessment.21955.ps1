<#
.SYNOPSIS
    Checks if local administrators are managed on Microsoft Entra joined devices.
#>

function Test-Assessment-21955 {
    [ZtTest(
    	Category = 'Devices',
    	ImplementationCost = 'Low',
    	Pillar = 'Identity',
    	RiskLevel = 'High',
    	SfiPillar = 'Protect tenants and isolate production systems',
    	TenantType = ('Workforce','External'),
    	TestId = 21955,
    	Title = 'Manage the local administrators on Microsoft Entra joined devices',
    	UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking Manage the local administrators on Microsoft Entra joined devices'
    Write-ZtProgress -Activity $activity -Status 'Getting policy'

    # Query device registration policy
    $policy = Invoke-ZtGraphRequest -RelativeUri 'policies/deviceRegistrationPolicy' -ApiVersion beta

    $enableGlobalAdmins = ${policy}?.azureADJoin?.localAdmins?.enableGlobalAdmins

    $portalLink = 'https://entra.microsoft.com/#view/Microsoft_AAD_Devices/DevicesMenuBlade/~/DeviceSettings/menuId/Overview'

    $portalLinkMd = "[Global administrator role is added as local administrator on the device during Microsoft Entra join?]($portalLink)`n`n"

    if ($enableGlobalAdmins) {
        $passed = $true
        $testResultMarkdown = "Local administrators on Microsoft Entra joined devices are managed by the organization.`n`n"
        $testResultMarkdown += $portalLinkMd
        $testResultMarkdown += "- **Yes** → ✅"
    }
    else {
        $passed = $false
        $testResultMarkdown = "Local administrators on Microsoft Entra joined devices are not managed by the organization.`n`n"
        $testResultMarkdown += $portalLinkMd
        $testResultMarkdown += "- **No** → ❌"
    }

    $params = @{
        TestId = '21955'
        Status = $passed
        Result = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
