<#
.SYNOPSIS
    Checks if local administrators are managed on Microsoft Entra joined devices.
#>

function Test-Assessment-21955{
    [ZtTest(
        Category = 'Access control',
        ImplementationCost = 'Low',
        Pillar = 'Identity',
        RiskLevel = 'High',
        SfiPillar = 'Protect identities and secrets',
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


    # Build details section for markdown (bulleted list)
    $mdInfo = "`n## [Local administrator settings details]($portalLink)`n"

    if($null -ne $enableGlobalAdmins)
    {
        if($enableGlobalAdmins -eq $true)
        {
            $mdInfo += "- **Global administrator role is added as local administrator on the device during Microsoft Entra join** : **Yes** ✅`n"
        }
        else{
            $mdInfo += "- **Global administrator role is added as local administrator on the device during Microsoft Entra join** : **No** ❌`n"
        }
    }
    else{
        $mdInfo += "- **Global administrator role is added as local administrator on the device during Microsoft Entra join** : Not configured`n"
    }

    # Pass/fail logic
    if ($enableGlobalAdmins -eq $true) {
        $passed = $true
        $testResultMarkdown = "Local administrators on Microsoft Entra joined devices are managed by the organization.$mdInfo"
    } else {
        $passed = $false
        $testResultMarkdown = "Local administrators on Microsoft Entra joined devices are not managed by the organization.$mdInfo"
    }

    $params = @{
        TestId             = '21955'
        Status             = $passed
        Result             = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
