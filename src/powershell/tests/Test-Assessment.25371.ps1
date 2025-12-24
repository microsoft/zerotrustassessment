<#
.SYNOPSIS
    Validates that Universal Continuous Access Evaluation (Universal CAE) is enabled for network access.

.DESCRIPTION
    This test checks if Universal Continuous Access Evaluation (Universal CAE) is enabled in the tenant
    through Global Secure Access with Conditional Access signaling. Universal CAE ensures network access
    tokens are validated in real-time every time a connection to a new application resource is established.

    Without Universal CAE enabled, GSA tokens remain valid for 60-90 minutes regardless of changes to user state,
    allowing threat actors who obtain a GSA token to continue accessing all GSA-protected network resources even
    after the user's account is disabled, password is reset, or sessions are revoked.

    When critical security events occur (user account deletion, password change, MFA enablement, session revocation,
    or high user risk detection), Universal CAE communicates these signals to Global Secure Access in near real-time,
    prompting immediate reauthentication and blocking unauthorized access.

.NOTES
#>

function Test-Assessment-25371 {
    [ZtTest(
        Category = 'Global Secure Access',
        ImplementationCost = 'Low',
        MinimumLicense = ('AAD_PREMIUM'),
        Pillar = 'Network',
        RiskLevel = 'High',
        SfiPillar = 'Protect networks',
        TenantType = ('Workforce'),
        TestId = 25371,
        Title = 'Network access is validated in real-time through Universal Continuous Access Evaluation',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking Universal CAE configuration'
    Write-ZtProgress -Activity $activity -Status 'Getting Global Secure Access settings'

    # Q1: Check if Global Secure Access is enabled and configured
    # Determine if the organization is using Global Secure Access with Conditional Access signaling enabled
    $gsaSettings = Invoke-ZtGraphRequest -RelativeUri 'networkAccess/settings/conditionalAccess' -ApiVersion beta

    # Q2: Check traffic forwarding profiles status (Prerequisite)
    # Determine which GSA traffic forwarding profiles are active
    Write-ZtProgress -Activity $activity -Status 'Getting traffic forwarding profiles'
    $forwardingProfiles = Invoke-ZtGraphRequest -RelativeUri 'networkAccess/forwardingProfiles' -ApiVersion beta

    # Q3: Check for Conditional Access policies that disable CAE for GSA traffic
    # Query enabled Conditional Access policies to identify any that explicitly disable CAE
    Write-ZtProgress -Activity $activity -Status 'Checking Conditional Access policies'
    $caePolicies = Get-ZtConditionalAccessPolicy | Where-Object { $_.state -eq 'enabled' }

    # Initialize test variables
    $CAPolicyDetails = @()

    if ($caePolicies -and $caePolicies.Count -gt 0) {
        foreach ($policy in $caePolicies) {
            $appCondition = $policy.conditions.applications
            # Primary check: Check if policy targets All applications
            $targetsAllApps = $appCondition.includeApplications -contains "All"

            $CAPolicyDetails += [PSCustomObject]@{
                Id                         = $policy.id
                DisplayName                = $policy.displayName
                State                      = $policy.state
                TargetsAllApps             = $targetsAllApps
                ContinuousAccessEvaluation = $policy.sessionControls.continuousAccessEvaluation.mode
            }
        }
    }
    # Flag policies where CAE is explicitly disabled for all apps
    $ContinuousAccessEvaluationDisabledPolicies = $CAPolicyDetails | Where-Object {
        ($_.TargetsAllApps -eq $true) -and ($_.ContinuousAccessEvaluation -eq 'disabled')
    }

    #endregion Data Collection

    #region Assessment Logic
    # Prerequisite Check: If Q1 shows signalingStatus is not enabled, the check is Not Applicable

    $passed = $true
    $testResultMarkdown = ''
    if (-not $gsaSettings -or $gsaSettings.signalingStatus -ne 'enabled') {
        $passed = $false
        $testResultMarkdown = "ℹ️ Global Secure Access with Conditional Access signaling is not configured in this tenant. Universal CAE is not applicable.`n`n%TestResult%"
    }
    else {
        $passed = $ContinuousAccessEvaluationDisabledPolicies.Count -eq 0

        # Set result message based on findings
        if (-not $passed) {
            $testResultMarkdown = "❌ Universal CAE is disabled either at a tenant level or via conditional access policies.`n`n%TestResult%"
        }
        else {
            $testResultMarkdown = "✅ Universal CAE is enabled for Global Secure Access.`n`n%TestResult%"
        }
    }

    #endregion Assessment Logic

    #region Report Generation
    $mdInfo = ''

    if ($gsaSettings) {
        $mdInfo += "`n## [Global Secure Access Status](https://entra.microsoft.com/#view/Microsoft_Azure_Network_Access/Welcome.ReactView)`n`n"
        $mdInfo += "**Signaling Status**: $(if ($gsaSettings.signalingStatus -eq 'enabled') { '✅ Enabled' } else { '❌ ' + $gsaSettings.signalingStatus })`n"
    }
    else {
        $mdInfo += "`n## [Global Secure Access Status](https://entra.microsoft.com/#view/Microsoft_Azure_Network_Access/Welcome.ReactView)`n`n"
        $mdInfo += "**Status**: ℹ️ Not configured`n`n"
    }

    # Informational: Record enabled traffic forwarding profiles
    if ($null -ne $forwardingProfiles) {
        $mdInfo += "`n## [Active Traffic Profiles](https://entra.microsoft.com/#view/Microsoft_Azure_Network_Access/TrafficForwarding.ReactView)`n`n"
        $mdInfo += "| Name | State | Traffic Type |`n"
        $mdInfo += "| :--- | :--- | :--- |`n"
        foreach ($profile in ($forwardingProfiles | Sort-Object -Property name)) {
            $mdInfo += "| $(Get-SafeMarkdown $profile.name) | $(Get-FormattedPolicyState $profile.state) | $($profile.trafficForwardingType) |`n"
        }
    }
    else {
        $mdInfo += "`n## [Active Traffic Profiles](https://entra.microsoft.com/#view/Microsoft_Azure_Network_Access/TrafficForwarding.ReactView)`n`n"
        $mdInfo += "No active traffic profiles found.`n`n"
    }

    # Report CAE-disabling policies
    if ($ContinuousAccessEvaluationDisabledPolicies.Count -gt 0) {
        $mdInfo += "`n## Policies disabling Continuous Access Evaluation`n`n"
        $mdInfo += "| Policy Name | Policy ID | Continuous Access Evaluation Mode |`n"
        $mdInfo += "| :--- | :--- | :--- |`n"
        foreach ($policy in ($ContinuousAccessEvaluationDisabledPolicies | Sort-Object -Property DisplayName)) {
            $ContinuousAccessEvalIcon = "❌ Disabled"
            $policyLink = "https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/$($policy.Id)"
            $mdInfo += "| [$(Get-SafeMarkdown $policy.DisplayName)]($policyLink) | $($policy.Id) | $ContinuousAccessEvalIcon |`n"
        }
        $mdInfo += "`n"
    }
    else {
        $mdInfo += "`n## [Policies disabling Continuous Access Evaluation](https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/ConditionalAccessBlade/~/Policies)`n`n"
        $mdInfo += "No Conditional Access policies disabling Continuous Access Evaluation were found.`n`n"
    }
    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '25371'
        Title  = 'Network access is validated in real-time through Universal Continuous Access Evaluation'
        Status = $passed
        Result = $testResultMarkdown
    }

    # Add test result details
    Add-ZtTestResultDetail @params
}
