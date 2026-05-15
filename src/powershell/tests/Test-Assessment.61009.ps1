<#
.SYNOPSIS
    Conditional Access policies cover both agent identities and agent users.

.DESCRIPTION
    This test checks whether at least one enabled Conditional Access policy targets agent identities
    (set A) and at least one enabled Conditional Access policy targets agent users (set B), both with
    the 'block' grant control. Both sub-conditions must hold for the check to pass.

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
        Pillar = 'AI',
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

    $allCAPolicies = $null
    $queryFailed   = $false

    try {
        $allCAPolicies = Get-ZtConditionalAccessPolicy -ErrorAction Stop
    }
    catch {
        $queryFailed = $true
        Write-PSFMessage "Failed to retrieve Conditional Access policies: $_" -Tag Test -Level Warning
    }
    #endregion Data Collection

    #region Assessment Logic
    $passed       = $false
    $customStatus = $null
    $setA         = @()  # enabled policies blocking agent identities
    $setB         = @()  # enabled policies blocking agent users
    $nearMissList = @()  # report-only policies with agent scope (near-misses)

    if ($queryFailed) {
        $passed       = $false
        $customStatus = 'Investigate'
        $testResultMarkdown = "⚠️ Unable to determine Conditional Access policy configuration for agent principals due to a query failure or insufficient permissions.`n`n%TestResult%"
    }
    else {
        $enabledPolicies    = @($allCAPolicies | Where-Object { $_.state -eq 'enabled' })
        $reportOnlyPolicies = @($allCAPolicies | Where-Object { $_.state -eq 'enabledForReportingButNotEnforced' })

        foreach ($policy in $enabledPolicies) {
            $hasBlockGrant = $policy.grantControls.builtInControls -contains 'block'

            # Sub-condition A: policy targets agent identities as the signing-in principal.
            # Official Graph API token: conditions.clientApplications.includeAgentIdServicePrincipals = ["All"]
            # or a non-empty agentIdServicePrincipalFilter.rule for scoped agent targeting.
            # Ref: https://learn.microsoft.com/entra/agent-id/disable-agent-identities
            $clientApps = $policy.conditions.clientApplications
            $targetsAgentIdentity = (
                $null -ne $clientApps -and (
                    (
                        $null -ne $clientApps.includeAgentIdServicePrincipals -and
                        $clientApps.includeAgentIdServicePrincipals.Count -gt 0
                    ) -or
                    (
                        $null -ne $clientApps.agentIdServicePrincipalFilter -and
                        -not [string]::IsNullOrEmpty($clientApps.agentIdServicePrincipalFilter.rule)
                    )
                )
            )

            if ($targetsAgentIdentity -and $hasBlockGrant) {
                $setA += $policy
            }

            # Sub-condition B: policy targets agent users (agents' user accounts).
            # Official Graph API token: conditions.users.includeUsers = ["AllAgentIdUsers"]
            # This is a reserved token distinct from "All" (all humans) and is the only
            # supported way to scope a CA policy to agent user accounts.
            # Ref: https://learn.microsoft.com/entra/agent-id/disable-agent-identities
            $usersCondition   = $policy.conditions.users
            $targetsAgentUser = (
                $null -ne $usersCondition -and
                $null -ne $usersCondition.includeUsers -and
                $usersCondition.includeUsers -contains 'AllAgentIdUsers'
            )

            if ($targetsAgentUser -and $hasBlockGrant) {
                $setB += $policy
            }
        }

        # Collect report-only policies that reference agent principals as near-misses.
        foreach ($policy in $reportOnlyPolicies) {
            $clientApps     = $policy.conditions.clientApplications
            $usersCondition = $policy.conditions.users

            $targetsAgentIdentity = (
                $null -ne $clientApps -and (
                    (
                        $null -ne $clientApps.includeAgentIdServicePrincipals -and
                        $clientApps.includeAgentIdServicePrincipals.Count -gt 0
                    ) -or
                    (
                        $null -ne $clientApps.agentIdServicePrincipalFilter -and
                        -not [string]::IsNullOrEmpty($clientApps.agentIdServicePrincipalFilter.rule)
                    )
                )
            )
            $targetsAgentUser = (
                $null -ne $usersCondition -and
                $null -ne $usersCondition.includeUsers -and
                $usersCondition.includeUsers -contains 'AllAgentIdUsers'
            )

            if ($targetsAgentIdentity -or $targetsAgentUser) {
                $nearMissList += $policy
            }
        }

        $passed = ($setA.Count -ge 1) -and ($setB.Count -ge 1)

        if ($passed) {
            $testResultMarkdown = "✅ At least one enabled Conditional Access policy blocks agent identities, and at least one enabled Conditional Access policy blocks agent users.`n`n%TestResult%"
        }
        else {
            $testResultMarkdown = "❌ No enabled Conditional Access policy covers agent identities with ``block``, or no enabled policy covers agent users with ``block``. Agent traffic for the uncovered principal type bypasses Conditional Access enforcement.`n`n%TestResult%"
        }
    }
    #endregion Assessment Logic

    #region Report Generation
    $mdInfo = ''

    if (-not $queryFailed) {
        $caPoliciesLink = 'https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/ConditionalAccessBlade/~/Policies'

        $subCondAResult = if ($setA.Count -ge 1) { '✅ Pass' } else { '❌ Fail' }
        $subCondBResult = if ($setB.Count -ge 1) { '✅ Pass' } else { '❌ Fail' }
        $subCondANames  = if ($setA.Count -ge 1) {
            ($setA | ForEach-Object { Get-SafeMarkdown -Text $_.displayName }) -join ', '
        } else { '(none)' }
        $subCondBNames  = if ($setB.Count -ge 1) {
            ($setB | ForEach-Object { Get-SafeMarkdown -Text $_.displayName }) -join ', '
        } else { '(none)' }

        # Build sub-condition table rows
        $subCondTableRows  = "| A — Agent identities or blueprints covered by an enabled ``block`` policy | $subCondAResult | $subCondANames |`n"
        $subCondTableRows += "| B — Agent users covered by an enabled ``block`` policy | $subCondBResult | $subCondBNames |`n"

        $subCondSection = @"

### [Conditional Access policies covering agent principals]($caPoliciesLink)

| Sub-condition | Result | Policies evaluated |
| :------------ | :----- | :----------------- |
$subCondTableRows
"@

        # Build near-miss section
        $nearMissSection = ''
        if (-not $passed -and $nearMissList.Count -gt 0) {
            $nearMissTableRows = ''
            foreach ($policy in ($nearMissList | Sort-Object displayName)) {
                $name       = Get-SafeMarkdown -Text $policy.displayName
                $portalLink = "https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/$($policy.id)"
                $nameLink   = "[$name]($portalLink)"
                $grants     = if ($policy.grantControls -and $policy.grantControls.builtInControls) {
                    $policy.grantControls.builtInControls -join ', '
                } else { '(none)' }
                $nearMissTableRows += "| $nameLink | $($policy.state) | $grants |`n"
            }

            $nearMissSection = @"

### Near-miss policies (report-only mode)

| Display name | State | Grant controls |
| :----------- | :---- | :------------- |
$nearMissTableRows
"@
        }

        $formatTemplate = @'
{0}{1}
'@

        $mdInfo = $formatTemplate -f $subCondSection, $nearMissSection, $setA.Count, $setB.Count
    }

    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    # Deduplicate policies that appear in both set A and set B
    $matchedPolicies = @()
    foreach ($p in @($setA + $setB)) {
        if ($p.id -notin ($matchedPolicies | ForEach-Object { $_.id })) {
            $matchedPolicies += $p
        }
    }

    $params = @{
        TestId          = '61009'
        Title           = 'Conditional Access policies cover both agent identities and agent users'
        Status          = $passed
        Result          = $testResultMarkdown
        GraphObjectType = 'ConditionalAccess'
        GraphObjects    = $matchedPolicies
    }
    if ($null -ne $customStatus) {
        $params.CustomStatus = $customStatus
    }
    Add-ZtTestResultDetail @params
}
