<#
.SYNOPSIS
    Checks that step-up authentication is required upon risky in-session action.

.NOTES
    Test ID: 41083
    Workshop Task: SECOPS-083
    Pillar: SecOps
    Category: Identity threat protection
    Required permission: Policy.Read.All
#>

function Test-Assessment-41083 {

    [ZtTest(
        Category           = 'Identity threat protection',
        CompatibleLicense  = ('ADALLOM_S_STANDALONE&AAD_PREMIUM_P2'),
        ImplementationCost = 'Medium',
        Pillar             = 'SecOps',
        RiskLevel          = 'High',
        Service            = ('Graph'),
        SfiPillar          = 'Protect identities and secrets',
        TenantType         = ('Workforce'),
        TestId             = 41083,
        Title              = 'Step-up authentication is required upon risky in-session action',
        UserImpact         = 'Medium'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose
    $activity = 'Checking risk-based step-up authentication Conditional Access policies'
    Write-ZtProgress -Activity $activity -Status 'Querying enabled Conditional Access policies'

    try {
        $enabledPolicies = Invoke-ZtGraphRequest -RelativeUri 'identity/conditionalAccess/policies' -ApiVersion beta -Filter "state eq 'enabled'" -Select 'id,displayName,state,conditions,grantControls' -ErrorAction Stop
    }
    catch {
        $httpStatus = Get-ZtHttpStatusCode -ErrorRecord $_
        Write-PSFMessage "Failed to retrieve Conditional Access policies (HTTP $httpStatus): $_" -Tag Test -Level Warning

        $resultMessage = if ($httpStatus -in @(401, 403)) {
            '⚠️ The Conditional Access policy collection could not be retrieved because the assessment account lacks Policy.Read.All permission. Grant the permission and re-run the assessment.'
        }
        else {
            '⚠️ The Conditional Access policy collection could not be retrieved because Microsoft Graph returned a transient or unexpected error. Verify connectivity and re-run the assessment.'
        }

        $params = @{
            TestId       = '41083'
            Title        = 'Step-up authentication is required upon risky in-session action'
            Status       = $false
            Result       = $resultMessage
            CustomStatus = 'Investigate'
        }
        Add-ZtTestResultDetail @params
        return
    }

    $enabledPolicies = @($enabledPolicies)

    Write-ZtProgress -Activity $activity -Status 'Resolving referenced authentication strengths'

    # The strength is returned inline with each policy, but allowedCombinations is not always expanded.
    $strengthCombinations = @{}
    foreach ($policy in $enabledPolicies) {
        $strength = $policy.grantControls.authenticationStrength
        if ($null -eq $strength -or [string]::IsNullOrWhiteSpace($strength.id) -or $strengthCombinations.ContainsKey($strength.id)) { continue }

        $allowedCombinations = @($strength.allowedCombinations | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
        if ($allowedCombinations.Count -eq 0) {
            try {
                $strengthDetail = Invoke-ZtGraphRequest -RelativeUri "identity/conditionalAccess/authenticationStrength/policies/$($strength.id)" -ApiVersion beta -ErrorAction Stop
                $allowedCombinations = @($strengthDetail.allowedCombinations | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
            }
            catch {
                Write-PSFMessage "Failed to retrieve authentication strength $($strength.id): $_" -Tag Test -Level Warning
            }
        }

        $strengthCombinations[$strength.id] = $allowedCombinations
    }
    #endregion Data Collection

    #region Assessment Logic
    # Built-in 'Phishing-resistant MFA' authentication strength.
    $phishingResistantStrengthId = '00000000-0000-0000-0000-000000000004'
    $phishingResistantMethods = @('windowsHelloForBusiness', 'fido2', 'x509CertificateMultiFactor')

    $policyResults = foreach ($policy in $enabledPolicies) {
        $signInRiskLevels = @($policy.conditions.signInRiskLevels | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
        $userRiskLevels   = @($policy.conditions.userRiskLevels   | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
        $hasRiskCondition = ($signInRiskLevels -contains 'high') -or ($userRiskLevels -contains 'high')

        $authenticationStrength = $policy.grantControls.authenticationStrength
        $hasAuthenticationStrength = $null -ne $authenticationStrength -and -not [string]::IsNullOrWhiteSpace($authenticationStrength.id)
        $isPhishingResistant = $false

        if ($hasAuthenticationStrength) {
            if ($authenticationStrength.id -eq $phishingResistantStrengthId) {
                $isPhishingResistant = $true
            }
            else {
                $allowedCombinations = @($strengthCombinations[$authenticationStrength.id])
                $nonResistantCombinations = @($allowedCombinations | Where-Object { $phishingResistantMethods -notcontains $_ })
                $isPhishingResistant = $allowedCombinations.Count -gt 0 -and $nonResistantCombinations.Count -eq 0
            }
        }

        $strengthName = 'None'
        if ($hasAuthenticationStrength) {
            $strengthName = if ([string]::IsNullOrWhiteSpace($authenticationStrength.displayName)) { $authenticationStrength.id } else { $authenticationStrength.displayName }
        }

        $builtInControls = @($policy.grantControls.builtInControls | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })

        # With an OR operator alongside other controls the grant can be satisfied without the strength.
        $strengthAlwaysRequired = $builtInControls.Count -eq 0 -or $policy.grantControls.operator -eq 'AND'

        [PSCustomObject]@{
            PolicyDisplayName      = $policy.displayName
            PolicyId               = $policy.id
            State                  = $policy.state
            SignInRiskLevels       = if ($signInRiskLevels.Count -gt 0) { $signInRiskLevels -join ', ' } else { 'None' }
            UserRiskLevels         = if ($userRiskLevels.Count -gt 0) { $userRiskLevels -join ', ' } else { 'None' }
            AuthenticationStrength = $strengthName
            PhishingResistant      = if ($isPhishingResistant) { 'Yes' } else { 'No' }
            BuiltInControls        = if ($builtInControls.Count -gt 0) { $builtInControls -join ', ' } else { 'None' }
            RequiresMfaControl     = $builtInControls -contains 'mfa'
            HasRiskCondition       = $hasRiskCondition
            IsPhishingResistant    = $isPhishingResistant
            Matches                = $hasRiskCondition -and $isPhishingResistant -and $strengthAlwaysRequired
        }
    }

    $policyResults = @($policyResults)
    $riskPolicies = @($policyResults | Where-Object HasRiskCondition)
    $matchingPolicies = @($riskPolicies | Where-Object Matches)
    $mfaOnlyRiskPolicies = @($riskPolicies | Where-Object { -not $_.IsPhishingResistant -and $_.RequiresMfaControl })

    $passed = $false
    if ($matchingPolicies.Count -gt 0) {
        $passed = $true
        $testResultMarkdown = "✅ At least one enabled Conditional Access policy combines an identity risk condition with a phishing-resistant authentication strength grant control, so a step-up challenge raised by a risky in-session action is enforced.`n`n%TestResult%"
    }
    elseif ($mfaOnlyRiskPolicies.Count -gt 0) {
        $testResultMarkdown = "❌ Enabled Conditional Access policies use an identity risk condition but grant access with the multifactor authentication built-in control instead of a phishing-resistant authentication strength. Upgrade them to the built-in Phishing-resistant MFA strength, or to a custom strength whose allowed combinations only use FIDO2, certificate-based authentication (multifactor), or Windows Hello for Business.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "❌ No enabled Conditional Access policy combines an identity risk condition with a phishing-resistant authentication strength grant control.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    $portalUrl = 'https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/ConditionalAccessBlade'
    $policyUrlTemplate = 'https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/{0}'
    $maxDisplay = 10
    $displayPolicies = @($riskPolicies | Sort-Object -Property PolicyDisplayName | Select-Object -First $maxDisplay)

    if ($displayPolicies.Count -eq 0) {
        $mdInfo = "`n`n## [Microsoft Entra > Conditional Access > Policies]($portalUrl)`n"
    }
    else {
        $tableRows = ''
        foreach ($policy in $displayPolicies) {
            $policyName = "[$(Get-SafeMarkdown -Text $policy.PolicyDisplayName)]($($policyUrlTemplate -f $policy.PolicyId))"
            $signInRisk = Get-SafeMarkdown -Text $policy.SignInRiskLevels
            $userRisk = Get-SafeMarkdown -Text $policy.UserRiskLevels
            $authStrength = Get-SafeMarkdown -Text $policy.AuthenticationStrength
            $phishingResistant = Get-SafeMarkdown -Text $policy.PhishingResistant
            $builtInControls = Get-SafeMarkdown -Text $policy.BuiltInControls
            $status = if ($policy.Matches) { '✅ Pass' } else { '❌ Fail' }
            $tableRows += "| $policyName | $($policy.State) | $signInRisk | $userRisk | $authStrength | $phishingResistant | $builtInControls | $status |`n"
        }

        if ($riskPolicies.Count -gt $maxDisplay) {
            $remaining = $riskPolicies.Count - $maxDisplay
            $tableRows += "`n... and $remaining more. [Microsoft Entra > Conditional Access > Policies]($portalUrl)`n"
        }

        $formatTemplate = @'


## [Microsoft Entra > Conditional Access > Policies]({0})

| Policy display name | State | Sign-in risk levels | User risk levels | Authentication strength | Phishing-resistant | Built-in controls | Status |
| :------------------ | :---- | :------------------ | :--------------- | :---------------------- | :----------------- | :---------------- | :----- |
{1}
'@

        $mdInfo = $formatTemplate -f $portalUrl, $tableRows
    }

    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '41083'
        Title  = 'Step-up authentication is required upon risky in-session action'
        Status = $passed
        Result = $testResultMarkdown
    }
    Add-ZtTestResultDetail @params
}
