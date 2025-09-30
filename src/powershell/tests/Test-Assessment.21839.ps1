<#
.SYNOPSIS
    Checks if Passkey (FIDO2) authentication method is enabled and configured for users in the tenant.
#>

function Test-Assessment-21839{
    [ZtTest(
    	Category = 'Access control',
    	ImplementationCost = 'Medium',
    	Pillar = 'Identity',
    	RiskLevel = 'High',
    	SfiPillar = 'Protect identities and secrets',
    	TenantType = ('Workforce','External'),
    	TestId = 21839,
    	Title = 'Passkey authentication method enabled',
    	UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking Passkey authentication method enabled'
    Write-ZtProgress -Activity $activity -Status 'Getting policy'

    # Query FIDO2 authentication method configuration
    $fido2Config = Invoke-ZtGraphRequest -RelativeUri 'authenticationMethodsPolicy/authenticationMethodConfigurations/FIDO2' -ApiVersion beta

    # Check if FIDO2 authentication method is enabled
    $state = $fido2Config.state
    $includeTargets = $fido2Config.includeTargets
    $isAttestationEnforced = $fido2Config.isAttestationEnforced
    $keyRestrictions = $fido2Config.keyRestrictions

    $fido2Enabled = $state -eq 'enabled'
    $hasIncludeTargets = $includeTargets -and $includeTargets.Count -gt 0

    $portalLink = "https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ConfigureAuthMethodsBlade/authMethod~/%7B%22%40odata.type%22%3A%22%23microsoft.graph.fido2AuthenticationMethodConfiguration%22%2C%22id%22%3A%22Fido2%22%2C%22state%22%3A%22enabled%22%2C%22isSelfServiceRegistrationAllowed%22%3Atrue%2C%22isAttestationEnforced%22%3Afalse%2C%22excludeTargets%22%3A%5B%7B%22id%22%3A%2243b7bc87-77eb-4263-abad-e3c2478f0a35%22%2C%22targetType%22%3A%22group%22%2C%22displayName%22%3A%22eam-block-user%22%7D%5D%2C%22keyRestrictions%22%3A%7B%22isEnforced%22%3Afalse%2C%22enforcementType%22%3A%22allow%22%2C%22aaGuids%22%3A%5B%22de1e552d-db1d-4423-a619-566b625cdc84%22%2C%2290a3ccdf-635c-4729-a248-9b709135078f%22%2C%2277010bd7-212a-4fc9-b236-d2ca5e9d4084%22%2C%22b6ede29c-3772-412c-8a78-539c1f4c62d2%22%2C%22ee041bce-25e5-4cdb-8f86-897fd6418464%22%2C%2273bb0cd4-e502-49b8-9c6f-b59445bf720b%22%5D%7D%2C%22includeTargets%40odata.context%22%3A%22https%3A%2F%2Fgraph.microsoft.com%2Fbeta%2F%24metadata%23policies%2FauthenticationMethodsPolicy%2FauthenticationMethodConfigurations('Fido2')%2Fmicrosoft.graph.fido2AuthenticationMethodConfiguration%2FincludeTargets%22%2C%22includeTargets%22%3A%5B%7B%22targetType%22%3A%22group%22%2C%22id%22%3A%22all_users%22%2C%22isRegistrationRequired%22%3Afalse%7D%5D%2C%22enabled%22%3Atrue%2C%22target%22%3A%22All%20users%2C%20excluding%201%20group%22%2C%22isAllUsers%22%3Atrue%2C%22voiceDisabled%22%3Afalse%7D/canModify~/true/voiceDisabled~/false/userMemberIds~/%5B%5D/userId/1ce4078f-f795-4baf-aa55-1fdfcc2ebfe6/isCiamTenant~/false/isCiamTrialTenant~/false"

    # Build details section for markdown (bulleted list)
    $mdInfo = "`n## [Passkey authentication method details]($portalLink)`n"
    $mdInfo += "- **Status** : $((Get-Culture).TextInfo.ToTitleCase($state.ToLower()))`n"
    $mdInfo += "- **Include Targets** : "
    if ($includeTargets) {
        $mdInfo += ($includeTargets | ForEach-Object { Get-ZtAuthenticatorFeatureSettingTarget -Target $_ }) -join ', '
    } else {
        $mdInfo += 'None'
    }
    $mdInfo += "`n"
    $mdInfo += "- **Enforce attestation** : $isAttestationEnforced`n"
    if ($null -ne $keyRestrictions) {
        $mdInfo += "- **Key restriction policy** :`n"
        if ($null -ne $keyRestrictions.isEnforced) {
            $mdInfo += "  - **Enforce key restrictions** : $($keyRestrictions.isEnforced)`n"
        }
        if ($null -ne $keyRestrictions.EnforcementType) {
            $mdInfo += "  - **Restrict specific keys** : $((Get-Culture).TextInfo.ToTitleCase($keyRestrictions.EnforcementType.ToLower()))`n"
        }
    }

    if($fido2Enabled -and $hasIncludeTargets)
    {
        $passed = $true
        $testResultMarkdown = "Passkey authentication method is enabled and configured for users in your tenant.$mdInfo"
    }
    else
    {
        $passed = $false
        $testResultMarkdown = "Passkey authentication method is not enabled or not configured for any users in your tenant.$mdInfo"
    }

    $params = @{
        TestId             = '21839'
        Status             = $passed
        Result             = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
