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
        CompatibleLicense = ('AAD_PREMIUM&AGENT_365'),
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
    $passed             = $false
    $customStatus       = $null
    $testResultMarkdown = ''
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

        # Collect near-miss policies: report-only policies, and enabled policies that target
        # agent principals but do not use the 'block' grant control.
        $nearMissCandidates = @($reportOnlyPolicies) + @($enabledPolicies | Where-Object {
            $_.id -notin ($setA + $setB | ForEach-Object { $_.id })
        })
        foreach ($policy in $nearMissCandidates) {
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
            $testResultMarkdown = "❌ No enabled Conditional Access policy targets agent identities with the ``block`` control, OR no enabled Conditional Access policy targets agent users with the ``block`` control. Agent traffic for the uncovered principal type bypasses Conditional Access enforcement.`n`n%TestResult%"
        }
    }
    #endregion Assessment Logic

    #region Report Generation
    $mdInfo = ''

    if (-not $queryFailed) {
        $maxPolicyLinks   = 5   # max linked policies shown in the Details column
        $maxNearMissRows  = 10  # max rows shown in near-miss tables
        $caPoliciesLink = 'https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/ConditionalAccessBlade/~/Policies'

        # Sub-condition A — details
        $subCondAResult  = if ($setA.Count -ge 1) { '✅ Pass' } else { '❌ Fail' }
        $subCondADetails = if ($setA.Count -ge 1) {
            $allLinks = @($setA | ForEach-Object {
                $n = Get-SafeMarkdown -Text $_.displayName
                $l = "https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/$($_.id)"
                "[$n]($l)"
            })
            if ($allLinks.Count -le $maxPolicyLinks) {
                $allLinks -join ', '
            } else {
                ($allLinks[0..($maxPolicyLinks - 1)] -join ', ') + ' ...'
            }
        } else { '(none)' }

        # Sub-condition B — details
        $subCondBResult  = if ($setB.Count -ge 1) { '✅ Pass' } else { '❌ Fail' }
        $subCondBDetails = if ($setB.Count -ge 1) {
            $allLinks = @($setB | ForEach-Object {
                $n = Get-SafeMarkdown -Text $_.displayName
                $l = "https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/$($_.id)"
                "[$n]($l)"
            })
            if ($allLinks.Count -le $maxPolicyLinks) {
                $allLinks -join ', '
            } else {
                ($allLinks[0..($maxPolicyLinks - 1)] -join ', ') + ' ...'
            }
        } else { '(none)' }

        $subCondTableRows  = "| A — Agent identities covered by an enabled ``block`` policy | $subCondAResult | $subCondADetails |`n"
        $subCondTableRows += "| B — Agent users covered by an enabled ``block`` policy | $subCondBResult | $subCondBDetails |`n"

        $mdInfo = @"

### [Conditional Access policies covering agent principals]($caPoliciesLink)

| Sub-condition | Result | Details |
| :------------ | :----- | :------- |
$subCondTableRows
"@

        # Near-miss section for sub-condition A (only shown when A fails)
        if ($setA.Count -eq 0) {
            $nmA = @($nearMissList | Where-Object {
                $ca = $_.conditions.clientApplications
                $null -ne $ca -and (
                    ($null -ne $ca.includeAgentIdServicePrincipals -and $ca.includeAgentIdServicePrincipals.Count -gt 0) -or
                    ($null -ne $ca.agentIdServicePrincipalFilter -and -not [string]::IsNullOrEmpty($ca.agentIdServicePrincipalFilter.rule))
                )
            } | Sort-Object displayName)
            if ($nmA.Count -gt 0) {
                $nmADisplayCount = [math]::Min($nmA.Count, $maxNearMissRows)
                $nmATruncationMessage = if ($nmA.Count -gt $maxNearMissRows) {
                    "`n`n_**Note**: This table is truncated and showing the first $nmADisplayCount of $($nmA.Count) policies._"
                } else { '' }
                $nmARows = ''
                foreach ($p in ($nmA | Select-Object -First $maxNearMissRows)) {
                    $n      = Get-SafeMarkdown -Text $p.displayName
                    $l      = "https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/$($p.id)"
                    $ca     = $p.conditions.clientApplications
                    $scope  = if ($null -ne $ca -and
                                  $ca.includeAgentIdServicePrincipals -contains 'All' -and
                                  ($null -eq $ca.excludeAgentIdServicePrincipals -or $ca.excludeAgentIdServicePrincipals.Count -eq 0)) {
                                  'All Agent Identities'
                              } else { 'Some Agent Identity' }
                    $grants = if ($p.grantControls -and $p.grantControls.builtInControls) { $p.grantControls.builtInControls -join ', ' } else { '(none)' }
                    $nmARows += "| [$n]($l) | $(Get-FormattedPolicyState $p.state) | $scope | $grants |`n"
                }
                $mdInfo += @"

#### Near-miss policies — Agent identities

| Policy | State | Scope | Grant controls |
| :----- | :---- | :---- | :------------- |
$nmARows$nmATruncationMessage
"@
            }
        }

        # Near-miss section for sub-condition B (only shown when B fails)
        if ($setB.Count -eq 0) {
            $nmB = @($nearMissList | Where-Object {
                $null -ne $_.conditions.users -and
                $null -ne $_.conditions.users.includeUsers -and
                $_.conditions.users.includeUsers -contains 'AllAgentIdUsers'
            } | Sort-Object displayName)
            if ($nmB.Count -gt 0) {
                $nmBDisplayCount = [math]::Min($nmB.Count, $maxNearMissRows)
                $nmBTruncationMessage = if ($nmB.Count -gt $maxNearMissRows) {
                    "`n`n_**Note**: This table is truncated and showing the first $nmBDisplayCount of $($nmB.Count) policies._"
                } else { '' }
                $nmBRows = ''
                foreach ($p in ($nmB | Select-Object -First $maxNearMissRows)) {
                    $n      = Get-SafeMarkdown -Text $p.displayName
                    $l      = "https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/$($p.id)"
                    $grants = if ($p.grantControls -and $p.grantControls.builtInControls) { $p.grantControls.builtInControls -join ', ' } else { '(none)' }
                    $nmBRows += "| [$n]($l) | $(Get-FormattedPolicyState $p.state) | $grants |`n"
                }
                $mdInfo += @"

#### Near-miss policies — Agent users

| Policy | State | Grant controls |
| :----- | :---- | :------------- |
$nmBRows$nmBTruncationMessage
"@
            }
        }
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
