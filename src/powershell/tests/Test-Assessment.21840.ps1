<#
.SYNOPSIS
    Checks if security key attestation is enforced in the FIDO2 authentication method policy.
#>

function Test-Assessment-21840{
    [ZtTest(
    	Category = 'Credential management',
    	ImplementationCost = 'Low',
    	MinimumLicense = ('Free'),
    	Pillar = 'Identity',
    	RiskLevel = 'High',
    	SfiPillar = 'Protect identities and secrets',
    	TenantType = ('Workforce','External'),
    	TestId = 21840,
    	Title = 'Security key attestation is enforced',
    	UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking Security key attestation is enforced'
    Write-ZtProgress -Activity $activity -Status 'Getting policy'

    # Query FIDO2 authentication method configuration
    $fido2Config = Invoke-ZtGraphRequest -RelativeUri 'authenticationMethodsPolicy/authenticationMethodConfigurations/FIDO2' -ApiVersion beta

    $isAttestationEnforced = $fido2Config.isAttestationEnforced
    $keyRestrictions = $fido2Config.keyRestrictions

    $portalLink = "https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ConfigureAuthMethodsBlade/authMethod~/%7B%22%40odata.type%22%3A%22%23microsoft.graph.fido2AuthenticationMethodConfiguration%22%2C%22id%22%3A%22Fido2%22%2C%22state%22%3A%22enabled%22%2C%22isSelfServiceRegistrationAllowed%22%3Atrue%2C%22isAttestationEnforced%22%3Afalse%2C%22excludeTargets%22%3A%5B%7B%22id%22%3A%2243b7bc87-77eb-4263-abad-e3c2478f0a35%22%2C%22targetType%22%3A%22group%22%2C%22displayName%22%3A%22eam-block-user%22%7D%5D%2C%22keyRestrictions%22%3A%7B%22isEnforced%22%3Afalse%2C%22enforcementType%22%3A%22allow%22%2C%22aaGuids%22%3A%5B%22de1e552d-db1d-4423-a619-566b625cdc84%22%2C%2290a3ccdf-635c-4729-a248-9b709135078f%22%2C%2277010bd7-212a-4fc9-b236-d2ca5e9d4084%22%2C%22b6ede29c-3772-412c-8a78-539c1f4c62d2%22%2C%22ee041bce-25e5-4cdb-8f86-897fd6418464%22%2C%2273bb0cd4-e502-49b8-9c6f-b59445bf720b%22%5D%7D%2C%22includeTargets%40odata.context%22%3A%22https%3A%2F%2Fgraph.microsoft.com%2Fbeta%2F%24metadata%23policies%2FauthenticationMethodsPolicy%2FauthenticationMethodConfigurations('Fido2')%2Fmicrosoft.graph.fido2AuthenticationMethodConfiguration%2FincludeTargets%22%2C%22includeTargets%22%3A%5B%7B%22targetType%22%3A%22group%22%2C%22id%22%3A%22all_users%22%2C%22isRegistrationRequired%22%3Afalse%7D%5D%2C%22enabled%22%3Atrue%2C%22target%22%3A%22All%20users%2C%20excluding%201%20group%22%2C%22isAllUsers%22%3Atrue%2C%22voiceDisabled%22%3Afalse%7D/canModify~/true/voiceDisabled~/false/userMemberIds~/%5B%5D/userId/1ce4078f-f795-4baf-aa55-1fdfcc2ebfe6/isCiamTenant~/false/isCiamTrialTenant~/false"

    # Build details section for markdown (bulleted list)
    $mdInfo = "`n## [Security key attestation policy details]($portalLink)`n"

    # Add visual indicator for attestation enforcement
    $attestationStatus = if ($isAttestationEnforced -eq $true) { "True ✅" } else { "False ❌" }
    $mdInfo += "- **Enforce attestation** : $attestationStatus`n"
    if ($null -ne $keyRestrictions) {
        $mdInfo += "- **Key restriction policy** :`n"
        if ($null -ne $keyRestrictions.isEnforced) {
            $mdInfo += "  - **Enforce key restrictions** : $($keyRestrictions.isEnforced)`n"
        } else {
            $mdInfo += "  - **Enforce key restrictions** : Not configured`n"
        }
        if ($null -ne $keyRestrictions.EnforcementType) {
            $mdInfo += "  - **Restrict specific keys** : $((Get-Culture).TextInfo.ToTitleCase($keyRestrictions.EnforcementType.ToLower()))`n"
        }else{
            $mdInfo += "  - **Restrict specific keys** : Not configured`n"
        }

        # Add aaGuids if present
        if ($null -ne $keyRestrictions.aaGuids -and $keyRestrictions.aaGuids.Count -gt 0) {
            $mdInfo += "  - **AAGUID** :`n"
            foreach ($guid in $keyRestrictions.aaGuids) {
                $mdInfo += "    - $guid`n"
            }
        }
    }

    # Pass/fail logic
    if ($isAttestationEnforced -eq $true) {
        $passed = $true
        $testResultMarkdown = "Security key attestation is properly enforced, ensuring only verified hardware authenticators can be registered.$mdInfo"
    } else {
        $passed = $false
        $testResultMarkdown = "Security key attestation is not enforced, allowing unverified or potentially compromised security keys to be registered.$mdInfo"
    }

    $params = @{
        TestId             = '21840'
        Status             = $passed
        Result             = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
