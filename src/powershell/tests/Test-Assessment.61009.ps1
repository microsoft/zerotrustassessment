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
    $passed                = $false
    $testResultMarkdown    = ''
    $setA                  = @()
    $setB                  = @()
    $agentIdentityPolicies = @()
    $agentUserPolicies     = @()

    if ($queryError) {
        $testResultMarkdown = "❌ Unable to determine Conditional Access policy configuration for agent principals due to a query failure or insufficient permissions.`n`n**Error:** ``$queryError```n`n%TestResult%"
    }
    else {
        # Policies (enabled or report-only) targeting agent identities via clientApplications (includeAgentIdServicePrincipals or agentIdServicePrincipalFilter.rule).
        $agentIdentityPolicies = @($allCAPolicies | Where-Object {
            $_.state -ne 'disabled' -and
            $null -ne $_.conditions.clientApplications -and (
                ($null -ne $_.conditions.clientApplications.includeAgentIdServicePrincipals -and
                 $_.conditions.clientApplications.includeAgentIdServicePrincipals.Count -gt 0) -or
                (-not [string]::IsNullOrEmpty($_.conditions.clientApplications.agentIdServicePrincipalFilter.rule))
            )
        })

        # Policies (enabled or report-only) targeting agent users via the reserved token conditions.users.includeUsers = ["AllAgentIdUsers"].
        $agentUserPolicies = @($allCAPolicies | Where-Object {
            $_.state -ne 'disabled' -and
            $null -ne $_.conditions.users.includeUsers -and
            $_.conditions.users.includeUsers -contains 'AllAgentIdUsers'
        })

        # Set A: enabled agent-identity policies that apply the 'block' grant control
        $setA = @($agentIdentityPolicies | Where-Object {
            $_.state -eq 'enabled' -and $_.grantControls.builtInControls -contains 'block'
        })

        # Set B: enabled agent-user policies that apply the 'block' grant control
        $setB = @($agentUserPolicies | Where-Object {
            $_.state -eq 'enabled' -and $_.grantControls.builtInControls -contains 'block'
        })

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

    if (-not $queryError) {
        $maxPolicyLinks      = 5   # max linked policies shown in the Details column
        $maxNearMissRows     = 10  # max rows shown in near-miss tables
        $caPoliciesLink      = 'https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/ConditionalAccessBlade/~/Policies'
        $policyPortalBaseUrl = 'https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/'

        # Sub-condition A — details
        $subCondAResult  = if ($setA.Count -ge 1) { '✅ Pass' } else { '❌ Fail' }
        $subCondADetails = if ($setA.Count -ge 1) {
            $allLinks = @($setA | ForEach-Object {
                $policyName = Get-SafeMarkdown -Text $_.displayName
                "[$policyName]($policyPortalBaseUrl$($_.id))"
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
                $policyName = Get-SafeMarkdown -Text $_.displayName
                "[$policyName]($policyPortalBaseUrl$($_.id))"
            })
            if ($allLinks.Count -le $maxPolicyLinks) {
                $allLinks -join ', '
            } else {
                ($allLinks[0..($maxPolicyLinks - 1)] -join ', ') + ' ...'
            }
        } else { '(none)' }

        $subCondTableRows  = "| A — Agent identities or blueprints covered by an enabled ``block`` policy | $subCondAResult | $subCondADetails |`n"
        $subCondTableRows += "| B — Agent users covered by an enabled ``block`` policy | $subCondBResult | $subCondBDetails |`n"

        $mdInfo = @"

### [Conditional Access policies covering agent principals]($caPoliciesLink)

| Sub-condition | Result | Details |
| :------------ | :----- | :------- |
$subCondTableRows
"@

        # Near-miss section for sub-condition A (only shown when A fails)
        $mdNearMissA = ''
        if ($setA.Count -eq 0) {
            $nearMissIdentityPolicies = @($agentIdentityPolicies | Sort-Object displayName)
            if ($nearMissIdentityPolicies.Count -gt 0) {
                $truncationMessage = if ($nearMissIdentityPolicies.Count -gt $maxNearMissRows) {
                    "`n`n_**Note**: This table is truncated and showing the first $maxNearMissRows of $($nearMissIdentityPolicies.Count) policies._"
                } else { '' }
                $nearMissRows = ''
                foreach ($nearMissPolicy in ($nearMissIdentityPolicies | Select-Object -First $maxNearMissRows)) {
                    $policyName = Get-SafeMarkdown -Text $nearMissPolicy.displayName
                    $clientApps = $nearMissPolicy.conditions.clientApplications
                    $scope      = if ($null -ne $clientApps -and
                                      $clientApps.includeAgentIdServicePrincipals -contains 'All' -and
                                      ($null -eq $clientApps.excludeAgentIdServicePrincipals -or $clientApps.excludeAgentIdServicePrincipals.Count -eq 0)) {
                                      'All Agent Identities'
                                  } else { 'Some Agent Identity' }
                    $grants     = if ($nearMissPolicy.grantControls -and $nearMissPolicy.grantControls.builtInControls) { $nearMissPolicy.grantControls.builtInControls -join ', ' } else { '(none)' }
                    $nearMissRows += "| [$policyName]($policyPortalBaseUrl$($nearMissPolicy.id)) | $(Get-ZtCaPolicyState -State $nearMissPolicy.state) | $scope | $grants |`n"
                }
                $mdNearMissA = @"

#### Near-miss policies — Agent identities

| Policy | State | Scope | Grant controls |
| :----- | :---- | :---- | :------------- |
$nearMissRows$truncationMessage
"@
            }
        }

        # Near-miss section for sub-condition B (only shown when B fails)
        $mdNearMissB = ''
        if ($setB.Count -eq 0) {
            $nearMissUserPolicies = @($agentUserPolicies | Sort-Object displayName)
            if ($nearMissUserPolicies.Count -gt 0) {
                $truncationMessage = if ($nearMissUserPolicies.Count -gt $maxNearMissRows) {
                    "`n`n_**Note**: This table is truncated and showing the first $maxNearMissRows of $($nearMissUserPolicies.Count) policies._"
                } else { '' }
                $nearMissRows = ''
                foreach ($nearMissPolicy in ($nearMissUserPolicies | Select-Object -First $maxNearMissRows)) {
                    $policyName = Get-SafeMarkdown -Text $nearMissPolicy.displayName
                    $grants     = if ($nearMissPolicy.grantControls -and $nearMissPolicy.grantControls.builtInControls) { $nearMissPolicy.grantControls.builtInControls -join ', ' } else { '(none)' }
                    $nearMissRows += "| [$policyName]($policyPortalBaseUrl$($nearMissPolicy.id)) | $(Get-ZtCaPolicyState -State $nearMissPolicy.state) | $grants |`n"
                }
                $mdNearMissB = @"

#### Near-miss policies — Agent users

| Policy | State | Grant controls |
| :----- | :---- | :------------- |
$nearMissRows$truncationMessage
"@
            }
        }

        $formatTemplate = '{0}{1}{2}'
        $mdInfo = $formatTemplate -f $mdInfo, $mdNearMissA, $mdNearMissB
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
