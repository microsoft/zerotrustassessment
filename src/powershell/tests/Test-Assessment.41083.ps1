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
    #endregion Data Collection

    #region Assessment Logic
    $enabledPolicies = @($enabledPolicies)

    $policyResults = foreach ($policy in $enabledPolicies) {
        $signInRiskLevels = @($policy.conditions.signInRiskLevels)
        $userRiskLevels = @($policy.conditions.userRiskLevels)
        $hasRiskCondition = ($signInRiskLevels -contains 'high') -or ($userRiskLevels -contains 'high')

        $authenticationStrength = $policy.grantControls.authenticationStrength
        $hasAuthenticationStrength = $null -ne $authenticationStrength -and -not [string]::IsNullOrWhiteSpace($authenticationStrength.id)

        $builtInControls = @($policy.grantControls.builtInControls | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })

        [PSCustomObject]@{
            PolicyDisplayName      = $policy.displayName
            PolicyId               = $policy.id
            State                  = $policy.state
            SignInRiskLevels       = if ($signInRiskLevels.Count -gt 0) { $signInRiskLevels -join ', ' } else { 'None' }
            UserRiskLevels         = if ($userRiskLevels.Count -gt 0) { $userRiskLevels -join ', ' } else { 'None' }
            AuthenticationStrength = if ($hasAuthenticationStrength) { $authenticationStrength.displayName } else { 'None' }
            BuiltInControls        = if ($builtInControls.Count -gt 0) { $builtInControls -join ', ' } else { 'None' }
            HasRiskCondition       = $hasRiskCondition
            Matches                = $hasRiskCondition -and $hasAuthenticationStrength
        }
    }

    $policyResults = @($policyResults)
    $riskPolicies = @($policyResults | Where-Object HasRiskCondition)
    $matchingPolicies = @($riskPolicies | Where-Object Matches)

    $passed = $false
    if ($matchingPolicies.Count -gt 0) {
        $passed = $true
        $testResultMarkdown = "✅ At least one enabled Conditional Access policy combines an identity risk condition with an authentication strength grant control, so a step-up challenge raised by a risky in-session action is enforced.`n`n%TestResult%"
    }
    elseif ($riskPolicies.Count -gt 0) {
        $testResultMarkdown = "❌ Enabled Conditional Access policies use an identity risk condition but grant access with multifactor authentication only. Upgrade them to a phishing-resistant authentication strength.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "❌ No enabled Conditional Access policy combines a risk condition with an authentication-strength grant control.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    $portalUrl = 'https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/ConditionalAccessBlade'
    $policyUrlTemplate = 'https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/{0}'
    $maxDisplay = 10
    $displayPolicies = @($riskPolicies | Sort-Object -Property PolicyDisplayName | Select-Object -First $maxDisplay)

    $tableRows = ''
    foreach ($policy in $displayPolicies) {
        $policyName = "[$(Get-SafeMarkdown -Text $policy.PolicyDisplayName)]($($policyUrlTemplate -f $policy.PolicyId))"
        $signInRisk = Get-SafeMarkdown -Text $policy.SignInRiskLevels
        $userRisk = Get-SafeMarkdown -Text $policy.UserRiskLevels
        $authStrength = Get-SafeMarkdown -Text $policy.AuthenticationStrength
        $builtInControls = Get-SafeMarkdown -Text $policy.BuiltInControls
        $status = if ($policy.Matches) { '✅ Pass' } else { '❌ Fail' }
        $tableRows += "| $policyName | $($policy.State) | $signInRisk | $userRisk | $authStrength | $builtInControls | $status |`n"
    }

    if ($displayPolicies.Count -eq 0) {
        $tableRows = "| No enabled policy uses a risk condition | — | — | — | — | — | ❌ Fail |`n"
    }
    elseif ($riskPolicies.Count -gt $maxDisplay) {
        $remaining = $riskPolicies.Count - $maxDisplay
        $tableRows += "`n... and $remaining more. [Microsoft Entra > Conditional Access > Policies]($portalUrl)`n"
    }

    $formatTemplate = @'


## [Microsoft Entra > Conditional Access > Policies]({0})

| Policy display name | State | Sign-in risk levels | User risk levels | Authentication strength | Built-in controls | Status |
| :------------------ | :---- | :------------------ | :--------------- | :---------------------- | :---------------- | :----- |
{1}
'@

    $mdInfo = $formatTemplate -f $portalUrl, $tableRows
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
