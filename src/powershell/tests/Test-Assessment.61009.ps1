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
    $testResultMarkdown         = ''
    $agentIdentityPolicies      = @()
    $agentUserPolicies          = @()
    $agentIdentityBlockPolicies = @()
    $agentUserBlockPolicies     = @()

    if ($queryError) {
        $testResultMarkdown = "❌ Unable to determine Conditional Access policy configuration for agent principals due to a query failure or insufficient permissions.`n`n**Error:** ``$queryError```n`n%TestResult%"
    }
    else {
        # Policies targeting agent identities via clientApplications (includeAgentIdServicePrincipals or agentIdServicePrincipalFilter.rule).
        $agentIdentityPolicies = @($allCAPolicies | Where-Object {
            $null -ne $_.conditions.clientApplications -and (
                ($null -ne $_.conditions.clientApplications.includeAgentIdServicePrincipals -and
                 $_.conditions.clientApplications.includeAgentIdServicePrincipals.Count -gt 0) -or
                (-not [string]::IsNullOrEmpty($_.conditions.clientApplications.agentIdServicePrincipalFilter.rule))
            )
        })

        # Policies targeting agent users via the reserved token conditions.users.includeUsers = ["AllAgentIdUsers"].
        $agentUserPolicies = @($allCAPolicies | Where-Object {
            $null -ne $_.conditions.users.includeUsers -and
            $_.conditions.users.includeUsers -contains 'AllAgentIdUsers'
        })

        # Enabled agent-identity policies that apply the 'block' grant control
        $agentIdentityBlockPolicies = @($agentIdentityPolicies | Where-Object {
            $_.state -eq 'enabled' -and $_.grantControls.builtInControls -contains 'block'
        })

        # Enabled agent-user policies that apply the 'block' grant control
        $agentUserBlockPolicies = @($agentUserPolicies | Where-Object {
            $_.state -eq 'enabled' -and $_.grantControls.builtInControls -contains 'block'
        })

        $passed = ($agentIdentityBlockPolicies.Count -ge 1) -and ($agentUserBlockPolicies.Count -ge 1)

        if ($passed) {
            $testResultMarkdown = "✅ At least one enabled Conditional Access policy blocks agent identities, and at least one enabled Conditional Access policy blocks agent users.`n`n%TestResult%"
        }
        else {
            $testResultMarkdown = "❌ No enabled Conditional Access policy targets agent identities with the ``block`` control, OR no enabled Conditional Access policy targets agent users with the ``block`` control. Agent traffic for the uncovered principal type bypasses Conditional Access enforcement.`n`n%TestResult%"
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
            $agentPolicies += [PSCustomObject]@{
                Policy       = $policy
                TargetedType = 'All Agent Users'
                IsBlocking   = ($agentUserBlockPolicies | Where-Object { $_.id -eq $policy.id }).Count -gt 0
            }
        }
    }

    $tableRows = ''
    if ($agentPolicies.Count -gt 0) {
        foreach ($entry in $agentPolicies) {
            $pol        = $entry.Policy
            $policyName = Get-SafeMarkdown -Text $pol.displayName
            $grants     = if ($pol.grantControls -and $pol.grantControls.builtInControls) { $pol.grantControls.builtInControls -join ', ' } else { '(none)' }
            $status     = if ($entry.IsBlocking) { '✅ Pass' } else { '❌ Fail' }
            $tableRows += "| [$policyName]($portalPolicyBaseUrl$($pol.id)) | $($entry.TargetedType) | $(Get-ZtCaPolicyState -State $pol.state) | $grants | $status |`n"
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
    Add-ZtTestResultDetail @params
}
