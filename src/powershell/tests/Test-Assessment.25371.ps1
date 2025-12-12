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
        Category = 'Private Access',
        ImplementationCost = 'Low',
        MinimumLicense = ('Entra_Premium_Private_Access'),
        Pillar = 'Network',
        RiskLevel = 'High',
        SfiPillar = 'Protect networks',
        TenantType = ('Workforce'),
        TestId = 25371,
        Title = 'Network access is validated in real-time through Universal Continuous Access Evaluation',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param(
        $Database
    )

    #region Helper Functions
function Get-UserDisplayNameById {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$UserIds,
        [Parameter(Mandatory = $true)]
        $Database
    )
    $UserResult = @()
    if($UserIds -eq 'All'){return 'All'}
    foreach ($id in $UserIds) {
        if ($null -eq $id -or $id -eq '') { continue }
        $user = Invoke-DatabaseQuery -Database $Database -Sql "SELECT displayName FROM User WHERE id = '$id'" | Select-Object -First 1
        if ($user -and $user.displayName) {
            $UserResult += $user.displayName
        } else {
            $UserResult += $id
        }
    }
    return $UserResult
}

function Get-GroupDisplayNameById {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$GroupIds,
        [Parameter(Mandatory = $true)]
        $Database
    )
    $groupResult = @()
    if($GroupIds -eq 'All'){return 'All'}
    foreach ($id in $GroupIds) {
        if ($null -eq $id -or $id -eq '') { continue }
        $group = Invoke-DatabaseQuery -Database $Database -Sql "SELECT displayName FROM Group WHERE id = '$id'" | Select-Object -First 1
        if ($group -and $group.displayName) {
            $groupResult += $group.displayName
        } else {
            $groupResult += $id
        }
    }
    return $groupResult
}
#endRegion Helper Functions


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
    $caePolicies = Invoke-ZtGraphRequest -RelativeUri "identity/conditionalAccess/policies?`$filter=state eq 'enabled'" -ApiVersion beta

    # Initialize test variables
    $testResultMarkdown = ''
    $passed = $false
    $CAPolicyDetails = @()
    #endregion Data Collection

    #region Assessment Logic
    # Prerequisite Check: If Q1 shows signalingStatus is not enabled, the check is Not Applicable
    if (-not $gsaSettings -or $gsaSettings.signalingStatus -ne 'enabled') {
        $passed = $false
        $testResultMarkdown = "ℹ️ Global Secure Access with Conditional Access signaling is not configured in this tenant. Universal CAE is not applicable.`n`n%TestResult%"
    }
    else {

        # Start with test state as Passed
        $passed = $false

        # Check for policies that disable CAE
        if ($caePolicies -and $caePolicies.Count -gt 0) {
            foreach ($policy in $caePolicies) {
                $appCondition = $policy.conditions.applications
                # Primary check: Check if policy targets All applications
                $targetsAllApps = $appCondition.includeApplications -contains "All"

                # Extract target users and groups
                $targetUsers = @($policy.conditions.users.includeUsers)
                if($targetUsers){$targetUsersDisplayNames = Get-UserDisplayNameById -UserIds $targetUsers -Database $Database}
                $targetGroups = @($policy.conditions.users.includeGroups)

                #below function to be used in future, once we have group data in database
                #if($targetGroups){$groupDisplayNames = Get-GroupDisplayNameById -GroupIds $targetGroups -Database $Database}

                $CAPolicyDetails += [PSCustomObject]@{
                    Id              = $policy.id
                    DisplayName     = $policy.displayName
                    State           = $policy.state
                    TargetsAllApps  = $targetsAllApps
                    ContinuousAccessEvaluation = $policy.sessionControls.continuousAccessEvaluation.mode
                    TargetUsers     = $targetUsersDisplayNames -join ', '
                    TargetGroups    = $targetGroups -join ', '
                }
            }
        }
        $ContinuousAccessEvaluationEnabledPolicies = $CAPolicyDetails | Where-Object {
            (($_.ContinuousAccessEvaluation -ne 'disabled') -and ($null -ne $_.ContinuousAccessEvaluation )) -and $_.TargetsAllApps
        }

        if($ContinuousAccessEvaluationEnabledPolicies.Count -gt 0) {
            $passed = $true
        }

        # Set result message based on findings
        if (-not $passed) {
            $testResultMarkdown = "❌ One or more Conditional Access policies explicitly disable CAE for all applications or GSA traffic.`n`n%TestResult%"
        }
        else {
            $testResultMarkdown = "✅ Universal Continuous Access Evaluation (CAE) is enabled and no policies disable it for all applications.`n`n%TestResult%"
        }
    }

    #endregion Assessment Logic

    #region Report Generation
    $mdInfo = ''

    if ($gsaSettings) {
        $mdInfo += "`n## Universal CAE Configuration`n`n"
        $mdInfo += "**Signaling Status**: $(if ($gsaSettings.signalingStatus -eq 'enabled') { '✅ Enabled' } else { '❌ ' + $gsaSettings.signalingStatus })`n"
    }
    else {
        $mdInfo += "`n## Universal CAE Configuration`n`n"
        $mdInfo += "**Status**: ℹ️ Not configured`n`n"
    }

    # Informational: Record enabled traffic forwarding profiles
    if ($forwardingProfiles.Count -gt 0) {
        $mdInfo += "`n## Traffic Forwarding Profiles `n`n"
        $mdInfo += "| Name | State | Traffic Type |`n"
        $mdInfo += "| :--- | :--- | :--- |`n"
        foreach ($profile in ($forwardingProfiles | Sort-Object -Property name)) {
            $mdInfo += "| $(Get-SafeMarkdown $profile.name) | $(Get-FormattedPolicyState $profile.state) | $($profile.trafficForwardingType) |`n"
        }
    }
    else{
        $mdInfo += "`n## Traffic Forwarding Profiles`n`n"
        $mdInfo += "No traffic forwarding profiles found.`n`n"
    }

    # Report CAE-disabling policies
    if ($CAPolicyDetails.Count -gt 0) {
        $mdInfo += "`n##  CAE Policies `n`n"
        $mdInfo += "| Display Name | Policy ID | Targets All Apps | Target Users | Target Groups | Continuous Access Evaluation |`n"
        $mdInfo += "| :--- | :--- | :--- | :--- | :--- | :--- |`n"
        foreach ($policy in ($CAPolicyDetails| Sort-Object -Property DisplayName)) {
            $allAppsIcon = if ($policy.TargetsAllApps) { '✅' } else { '❌' }
            $ContinuousAccessEvalIcon = if ($policy.ContinuousAccessEvaluation -ne 'disabled' -and $policy.ContinuousAccessEvaluation -ne $null) { '✅ ' + $policy.ContinuousAccessEvaluation } else { '❌ Disabled' }
            $policyLink = "https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/$($policy.Id)"
            $mdInfo += "| [$($policy.DisplayName)]($policyLink) | $($policy.Id) | $allAppsIcon | $($policy.TargetUsers) | $($policy.TargetGroups) | $ContinuousAccessEvalIcon |`n"
        }
        $mdInfo += "`n"
    }
    else{
        $mdInfo += "`n## CAE Policies`n`n"
        $mdInfo += "No CAE Policies found.`n`n"
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
