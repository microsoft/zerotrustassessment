<#
.SYNOPSIS

#>

function Test-Assessment-21954{
    [ZtTest(
    	Category = 'Access control',
    	ImplementationCost = 'Low',
    	Pillar = 'Identity',
    	RiskLevel = 'High',
    	SfiPillar = 'Protect identities and secrets',
    	TenantType = ('Workforce','External'),
    	TestId = 21954,
    	Title = 'Restrict non-administrator users from recovering the BitLocker keys for their owned devices',
    	UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking Restrict non-administrator users from recovering the BitLocker keys for their owned devices'
    Write-ZtProgress -Activity $activity -Status 'Getting authorization policy'

    # Query the MS Graph API for authorization policy
    $authPolicy = Invoke-ZtGraphRequest -RelativeUri 'policies/authorizationPolicy' -ApiVersion beta

    # Check if BitLocker key access is restricted
    $passed = $authPolicy.defaultUserRolePermissions.allowedToReadBitlockerKeysForOwnedDevice -eq $false
    $portalLink = 'https://entra.microsoft.com/#view/Microsoft_AAD_Devices/DevicesMenuBlade/~/DeviceSettings/menuId/Overview'
    $testResultMarkdown = if ($passed) {
        "[Non-administrator users are restricted from recovering BitLocker keys for their owned devices]($portalLink)"
    } else {
        "[Non-administrator users can recover BitLocker keys for their owned devices]($portalLink)"
    }

    $params = @{
        TestId             = '21954'
        Status             = $passed
        Result             = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
