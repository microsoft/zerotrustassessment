<#
.SYNOPSIS
    Validates that risk-based Conditional Access policies block high-risk agent identities.

.DESCRIPTION
    This test checks that the tenant has at least one enabled Conditional Access policy that blocks
    high-risk agent identities (set A). As of May 2026, only agent identities support risk
    evaluation in Conditional Access — agent users are not covered by risk-based conditional policies.

    Set A: enabled policies that target agent identities or blueprints via conditions.clientApplications,
    have conditions.agentIdRiskLevels containing 'high', and apply a 'block' grant control.

    Note: Conditional Access for Agent ID and ID Protection for agents are both in Preview.
    The agentIdRiskLevels and includeAgentIdServicePrincipals fields are documented in the beta
    endpoint and may change shape at GA.

.NOTES
    Test ID: 61012
    Category: AI Authentication & Access
    Required permissions: Policy.Read.All (or Policy.Read.ConditionalAccess) on Microsoft Graph
    API: GET https://graph.microsoft.com/beta/identity/conditionalAccess/policies
#>

function Test-Assessment-61012 {

    [ZtTest(
        Category = 'AI Authentication & Access',
        ImplementationCost = 'Low',
        Service = ('Graph'),
        MinimumLicense = ('AAD_PREMIUM_P2', 'AGENT_365'),
        CompatibleLicense = ('AAD_PREMIUM_P2&AGENT_365'),
        Pillar = 'AI',
        RiskLevel = 'High',
        SfiPillar = 'Protect identities and secrets',
        TenantType = ('Workforce'),
        TestId = 61012,
        Title = 'Risk-based Conditional Access blocks risky agent identities',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose
    $activity = 'Evaluating risk-based Conditional Access policies for agent identities'

    # Q1: Enumerate all Conditional Access policies
    Write-ZtProgress -Activity $activity -Status 'Querying Conditional Access policies'
    $allCAPolicies = @(Get-ZtConditionalAccessPolicy)

    # Classify policies (any state) that target agent identities or blueprints.
    # Two targeting patterns:
    #   1. includeAgentIdServicePrincipals is non-empty (specific agents, blueprints, or 'All' with exclusions)
    #   2. agentIdServicePrincipalFilter.rule is non-empty (attribute-based filter)
    $agentIdentityPolicies = @($allCAPolicies | Where-Object {
        $clientApps = $_.conditions.clientApplications
        ($clientApps.includeAgentIdServicePrincipals | Measure-Object).Count -gt 0 -or
        -not [string]::IsNullOrWhiteSpace($clientApps.agentIdServicePrincipalFilter.rule)
    })
    #endregion Data Collection

    #region Assessment Logic
    # Agent identity policies that are enabled, target high risk, and apply block.
    $blockingPolicies = @($agentIdentityPolicies | Where-Object {
        $_.state -eq 'enabled' -and
        $_.conditions.agentIdRiskLevels -eq 'high' -and
        (@($_.grantControls.builtInControls) -contains 'block')
    })

    $passed = ($blockingPolicies.Count -ge 1)

    if ($passed) {
        $testResultMarkdown = "✅ The tenant has at least one enabled risk-based Conditional Access policy that blocks high-risk agent identities.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "❌ The tenant does not have an enabled risk-based Conditional Access policy that blocks high-risk agent identities. Microsoft Entra ID Protection signals may be produced for risky agents, but access is not blocked by a qualifying Conditional Access policy.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    $reportTitle          = 'Risk-based Conditional Access policies for agent principals'
    $portalLink           = 'https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/ConditionalAccessBlade/~/Policies'
    $portalPolicyTemplate = 'https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/{0}'

    $formatTemplate = @'


## [{0}]({1})

| Policy | State | Agent risk level | Grant controls | Status |
| :----- | :---- | :--------------- | :------------- | :----- |
{2}

'@

    $tableRows = ''
    if ($agentIdentityPolicies.Count -gt 0) {
        foreach ($policy in $agentIdentityPolicies | Sort-Object -Property @{ Expression = { $_.id -in $blockingPolicies.id } }, displayName) {
            $policyLink = "[$(Get-SafeMarkdown $policy.displayName)]($($portalPolicyTemplate -f $policy.id))"
            $stateLabel = Get-ZtCaPolicyState -State $policy.state

            $riskLevel = if ($policy.conditions.agentIdRiskLevels) { $policy.conditions.agentIdRiskLevels } else { 'Not configured' }
            $riskLevelLabel = if ($policy.conditions.agentIdRiskLevels -eq 'high') { "✅ $riskLevel" } else { "❌ $riskLevel" }

            $grantControls = (@($policy.grantControls.builtInControls) | Where-Object { $_ }) -join ', '
            if (-not $grantControls) { $grantControls = 'None' }
            $grantControlsLabel = if (@($policy.grantControls.builtInControls) -contains 'block') { "✅ $grantControls" } else { "❌ $grantControls" }

            $statusLabel = if ($policy.id -in $blockingPolicies.id) { '✅ Pass' } else { '❌ Fail' }

            $tableRows += "| $policyLink | $stateLabel | $riskLevelLabel | $grantControlsLabel | $statusLabel |`n"
        }

        $mdInfo = $formatTemplate -f $reportTitle, $portalLink, $tableRows
    }
    else {
        $mdInfo = "No Conditional Access policies targeting agent identities were found.`n"
    }

    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '61012'
        Title  = 'Risk-based Conditional Access blocks risky agent identities'
        Status = $passed
        Result = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
