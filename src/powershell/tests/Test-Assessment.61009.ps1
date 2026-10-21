<#
.SYNOPSIS
    Conditional Access policies cover both agent identities and agent users.

.DESCRIPTION
    This test checks whether at least one enabled Conditional Access policy targets agent identities
    and at least one enabled Conditional Access policy targets agent users, both with
    the 'block' grant control. Both conditions must hold for the check to pass.

.NOTES
    Test ID: 61009
    Workshop Task: AI_003
    Pillar: AI
    Category: AI Identity & Access
    Risk Level: High
    Supported Clouds: Global
    Required Permission: Policy.Read.All or Policy.Read.ConditionalAccess
#>

function Test-Assessment-61009 {
    [ZtTest(
        Category = 'AI Identity & Access',
        ImplementationCost = 'Low',
        MinimumLicense = ('AAD_PREMIUM', 'AGENT_365'),
        CompatibleLicense = ('AAD_PREMIUM&AGENT_365', 'AAD_PREMIUM_P2&AGENT_365'),
        Pillar = 'AI',
        Service = ('Graph'),
        RiskLevel = 'High',
        SfiPillar = 'Protect identities and secrets',
        TenantType = ('Workforce'),
        TestId = 61009,
        Title = 'Conditional Access policies cover both agent identities and agent users',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking Conditional Access coverage for agent identities and agent users'
    Write-ZtProgress -Activity $activity -Status 'Querying Conditional Access policies'

    $queryError = $null

    try {
        $allCAPolicies = Get-ZtConditionalAccessPolicy -ErrorAction Stop
    }
    catch {
        $queryError = $_
        Write-PSFMessage "Failed to retrieve Conditional Access policies: $_" -Tag Test -Level Warning
    }
    #endregion Data Collection

    #region Assessment Logic
    $passed                     = $false
    $customStatus               = $null
    $testResultMarkdown         = ''
    $agentIdentityPolicies      = @()
    $agentUserPolicies          = @()
    $agentIdentityBlockPolicies = @()
    $agentUserBlockPolicies     = @()

    if ($queryError) {
        $testResultMarkdown = "❌ Unable to determine Conditional Access policy configuration for agent principals due to a query failure or insufficient permissions.`n`n**Error:** ``$queryError```n`n%TestResult%"
    }
    else {
        # Policies targeting agent identities via the agent-specific inclusion array.
        $agentIdentityPolicies = @($allCAPolicies | Where-Object {
            $null -ne $_.conditions.clientApplications -and (
                ($null -ne $_.conditions.clientApplications.includeAgentIdServicePrincipals -and
                 @($_.conditions.clientApplications.includeAgentIdServicePrincipals).Count -gt 0)
            )
        })

        # Policies targeting agent users via the agent-specific inclusion array.
        $agentUserPolicies = @($allCAPolicies | Where-Object {
            $null -ne $_.conditions.agents -and
            $null -ne $_.conditions.agents.includeAgentUsers -and
            @($_.conditions.agents.includeAgentUsers).Count -gt 0
        })

        # Enabled agent-identity policies that apply the 'block' grant control
        $agentIdentityBlockPolicies = @($agentIdentityPolicies | Where-Object {
            $_.state -eq 'enabled' -and $_.grantControls.builtInControls -contains 'block'
        })

        # Enabled agent-user policies that apply the 'block' grant control
        $agentUserBlockPolicies = @($agentUserPolicies | Where-Object {
            $_.state -eq 'enabled' -and $_.grantControls.builtInControls -contains 'block'
        })

        $agentIdentityAllPolicies = @($agentIdentityBlockPolicies | Where-Object {
            @($_.conditions.applications.includeApplications) -contains 'All'
        })
        $agentUserAllPolicies = @($agentUserBlockPolicies | Where-Object {
            @($_.conditions.applications.includeApplications) -contains 'All'
        })
        $agentIdentityRestrictedPolicies = @($agentIdentityBlockPolicies | Where-Object {
            @($_.conditions.applications.includeApplications) -contains 'AllAgentIdResources' -and
            -not (@($_.conditions.applications.includeApplications) -contains 'All')
        })
        $agentUserRestrictedPolicies = @($agentUserBlockPolicies | Where-Object {
            @($_.conditions.applications.includeApplications) -contains 'AllAgentIdResources' -and
            -not (@($_.conditions.applications.includeApplications) -contains 'All')
        })

        $agentIdentityOutcome = if ($agentIdentityAllPolicies.Count -ge 1) { 'Pass' }
                                elseif ($agentIdentityRestrictedPolicies.Count -ge 1) { 'Investigate' }
                                else { 'Fail' }
        $agentUserOutcome = if ($agentUserAllPolicies.Count -ge 1) { 'Pass' }
                            elseif ($agentUserRestrictedPolicies.Count -ge 1) { 'Investigate' }
                            else { 'Fail' }

        if ($agentIdentityOutcome -eq 'Fail' -or $agentUserOutcome -eq 'Fail') {
            $passed = $false
            $testResultMarkdown = "❌ Conditional Access policy coverage is insufficient for agent identities, agents' user accounts, or both.`n`n%TestResult%"
        }
        elseif ($agentIdentityOutcome -eq 'Investigate' -or $agentUserOutcome -eq 'Investigate') {
            $passed = $false
            $customStatus = 'Investigate'
            $testResultMarkdown = "⚠️ A required Conditional Access policy uses ``AllAgentIdResources`` instead of ``All``. The CA does not cover all resources.`n`n%TestResult%"
        }
        else {
            $passed = $true
            $testResultMarkdown = "✅ At least one enabled Conditional Access policy blocks all resources for agent identities, and at least one blocks all resources for agents' user accounts.`n`n%TestResult%"
        }
    }
    #endregion Assessment Logic

    #region Report Generation
    $mdInfo              = ''
    $reportTitle         = 'Conditional Access policies covering agent principals'
    $portalLink          = 'https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/ConditionalAccessBlade/~/Policies'
    $portalPolicyBaseUrl = 'https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/'

    $formatTemplate = @'


### [{0}]({1})

| Policy | Targeted Agent Identity types | State | Grant controls | Status |
| :----- | :---------------------------- | :---- | :------------- | :----- |
{2}
'@

    $agentPolicies = @()

    if (-not $queryError) {
        foreach ($policy in ($agentIdentityPolicies | Sort-Object displayName)) {
            $clientApps   = $policy.conditions.clientApplications
            $targetedType = if ($null -ne $clientApps -and
                                $clientApps.includeAgentIdServicePrincipals -contains 'All' -and
                                ($null -eq $clientApps.excludeAgentIdServicePrincipals -or $clientApps.excludeAgentIdServicePrincipals.Count -eq 0)) {
                                'All Agent Identities'
                            } else { 'Some Agent Identities or Blueprints' }
            $agentPolicies += [PSCustomObject]@{
                Policy       = $policy
                TargetedType = $targetedType
                IsBlocking   = ($agentIdentityBlockPolicies | Where-Object { $_.id -eq $policy.id }).Count -gt 0
            }
        }

        foreach ($policy in ($agentUserPolicies | Sort-Object displayName)) {
            $agents = $policy.conditions.agents
            $targetedType = if ($null -ne $agents -and
                                $agents.includeAgentUsers -contains 'All' -and
                                (@($agents.excludeAgentUsers).Count -eq 0) -and
                                $null -eq $agents.agentFilter) {
                                'All Agent Users'
                            } else { 'Some Agent Users' }
            $agentPolicies += [PSCustomObject]@{
                Policy       = $policy
                TargetedType = $targetedType
                IsBlocking   = ($agentUserBlockPolicies | Where-Object { $_.id -eq $policy.id }).Count -gt 0
            }
        }
    }

    $tableRows = ''
    if ($agentPolicies.Count -gt 0) {
        $rowPolicies = @($agentPolicies | Select-Object -First 10)
        foreach ($entry in $rowPolicies) {
            $pol        = $entry.Policy
            $policyName = Get-SafeMarkdown -Text $pol.displayName
            $grants     = if ($pol.grantControls -and $pol.grantControls.builtInControls) { $pol.grantControls.builtInControls -join ', ' } else { '(none)' }
            $includedResources = @($pol.conditions.applications.includeApplications)
            $hasExceptions = (
                ($null -ne $pol.conditions.clientApplications.excludeAgentIdServicePrincipals -and @($pol.conditions.clientApplications.excludeAgentIdServicePrincipals).Count -gt 0) -or
                ($null -ne $pol.conditions.clientApplications.excludeServicePrincipals -and @($pol.conditions.clientApplications.excludeServicePrincipals).Count -gt 0) -or
                ($null -ne $pol.conditions.agents.excludeAgentUsers -and @($pol.conditions.agents.excludeAgentUsers).Count -gt 0) -or
                ($null -ne $pol.conditions.applications.excludeApplications -and @($pol.conditions.applications.excludeApplications).Count -gt 0) -or
                ($null -ne $pol.conditions.agents.agentFilter) -or
                ($null -ne $pol.conditions.applications.applicationFilter)
            )
            if ($pol.state -eq 'enabled' -and @($pol.grantControls.builtInControls) -contains 'block' -and $includedResources -contains 'All') {
                $status = if ($hasExceptions) { 'Pass (exceptions configured)' } else { 'Pass' }
            }
            elseif ($pol.state -eq 'enabled' -and @($pol.grantControls.builtInControls) -contains 'block' -and $includedResources -contains 'AllAgentIdResources') {
                $status = 'Investigate (CA does not cover all resources)'
                if ($hasExceptions) { $status += '; exceptions configured' }
            }
            else {
                $status = 'Fail'
            }
            $tableRows += "| [$policyName]($portalPolicyBaseUrl$($pol.id)) | $($entry.TargetedType) | $(Get-ZtCaPolicyState -State $pol.state) | $grants | $status |`n"
        }
        if ($agentPolicies.Count -gt 10) {
            $tableRows += "| ... | | | | |`n"
        }

        $mdInfo = $formatTemplate -f $reportTitle, $portalLink, $tableRows
    }

    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '61009'
        Title  = 'Conditional Access policies cover both agent identities and agent users'
        Status = $passed
        Result = $testResultMarkdown
    }
    if ($customStatus) {
        $params.CustomStatus = $customStatus
    }
    Add-ZtTestResultDetail @params
}
