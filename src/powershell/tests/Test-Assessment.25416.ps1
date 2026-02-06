<#
.SYNOPSIS
    Branch office internet traffic is protected by Cloud Firewall policies through Global Secure Access

.DESCRIPTION
    Evaluates whether branch office internet traffic is protected by cloud firewall policies through Global Secure Access.
    Without cloud firewall policies enforced on remote network traffic, branch office internet traffic flows through
    Global Secure Access without egress filtering, exposing the organization to data exfiltration, command-and-control
    communications, and malicious outbound connections from compromised branch assets.

.NOTES
    Test ID: 25416
    Pillar: Network
    Risk Level: High
    SFI Pillar: Protect networks
#>

function Test-Assessment-25416 {
    [ZtTest(
        Category = 'Global Secure Access',
        ImplementationCost = 'Medium',
        MinimumLicense = ('Entra_Premium_Internet_Access'),
        Pillar = 'Network',
        RiskLevel = 'High',
        SfiPillar = 'Protect networks',
        TenantType = ('Workforce', 'External'),
        TestId = '25416',
        Title = 'Branch office internet traffic is protected by Cloud Firewall policies through Global Secure Access',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    # Define constants
    [int]$BASELINE_PROFILE_PRIORITY = 65000

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose
    $activity = 'Checking Branch office internet traffic is protected by Cloud Firewall policies through Global Secure Access'
    Write-ZtProgress -Activity $activity -Status 'Querying remote networks'

    # Q1: Get all configured remote networks (branch sites)
    $remoteNetworks = Invoke-ZtGraphRequest -RelativeUri 'networkAccess/connectivity/branches' -ApiVersion beta

    # Q2: Get filtering profiles with cloud firewall policy links
    Write-ZtProgress -Activity $activity -Status 'Querying baseline security profile'
    $filteringProfiles = Invoke-ZtGraphRequest -RelativeUri 'networkAccess/filteringProfiles' -QueryParameters @{
        '$select' = 'id,name,description,state,version,priority'
        '$expand' = 'policies($select=id,state;$expand=policy)'
    } -ApiVersion beta
    #endregion Data Collection

    #region Data Processing
    # Identify baseline profile with enabled cloud firewall policies
    $baselineProfileWithCloudFirewall = @()
    $remoteNetworkCount = if ($remoteNetworks) { $remoteNetworks.Count } else { 0 }

    if ($filteringProfiles -and $remoteNetworkCount -gt 0) {
        $baselineProfile = $filteringProfiles | Where-Object { $_.priority -eq $BASELINE_PROFILE_PRIORITY }

        if ($null -ne $baselineProfile -and $null -ne $baselineProfile.policies) {

            # Check if baseline profile has enabled cloud firewall policy links
            $enabledCloudFirewallPolicies = @()
            $policyLinks = $baselineProfile.policies | Where-Object { $_.'@odata.type' -eq '#microsoft.graph.networkAccess.cloudFirewallPolicyLink' }

            # Iterate over each cloud firewall policy link
            foreach ($policyLink in $policyLinks) {
                # Q3: Retrieve the actual cloud firewall policy rules using policy.id
                $policyId = if ($policyLink.policy) {
                    $policyLink.policy.id
                }
                else {
                    $null
                }
                $policyRulesData = @()
                $enabledRulesCount = 0

                if ($policyId) {
                    $policyDisplayName = if ($policyLink.policy.name) {
                        $policyLink.policy.name
                    }
                    else {
                        'Unknown'
                    }
                    Write-ZtProgress -Activity $activity -Status "Retrieving policy rules for $policyDisplayName"
                    try {
                        # Q3: GET https://graph.microsoft.com/beta/networkAccess/cloudfirewallpolicies/{policyId}?$expand=policyRules
                        $policyWithRules = Invoke-ZtGraphRequest -RelativeUri "networkAccess/cloudfirewallpolicies/$policyId" -QueryParameters @{
                            '$expand' = 'policyRules'
                        } -ApiVersion beta

                        if ($policyWithRules -and $policyWithRules.policyRules) {
                            $policyRulesData = $policyWithRules.policyRules
                            # Count enabled rules where settings.status = 'enabled'
                            $enabledRulesCount = ($policyRulesData | Where-Object { $_.settings.status -eq 'enabled' }).Count
                        }
                    }
                    catch {
                        Write-PSFMessage "Error retrieving policy rules for policy $policyId`: $_" -Tag Test -Level Warning
                    }
                }

                $enabledCloudFirewallPolicies += [PSCustomObject]@{
                    PolicyLinkId      = $policyLink.id
                    PolicyLinkState   = $policyLink.state
                    PolicyId          = $policyId
                    PolicyName        = if ($policyLink.policy) {
                        $policyLink.policy.name
                    }
                    else {
                        'Unknown'
                    }
                    PolicyRules       = $policyRulesData
                    TotalRulesCount   = $policyRulesData.Count
                    EnabledRulesCount = $enabledRulesCount
                }
            }


            if ($enabledCloudFirewallPolicies.Count -gt 0) {
                # Create an array with one object per cloud firewall policy
                foreach ($cloudFirewallPolicy in $enabledCloudFirewallPolicies) {
                    $baselineProfileWithCloudFirewall += [PSCustomObject]@{
                        ProfileId         = $baselineProfile.id
                        ProfileName       = $baselineProfile.name
                        ProfileState      = $baselineProfile.state
                        ProfilePriority   = $baselineProfile.priority
                        PolicyLinkId      = $cloudFirewallPolicy.PolicyLinkId
                        PolicyLinkState   = $cloudFirewallPolicy.PolicyLinkState
                        PolicyId          = $cloudFirewallPolicy.PolicyId
                        PolicyName        = $cloudFirewallPolicy.PolicyName
                        PolicyRules       = $cloudFirewallPolicy.PolicyRules
                        TotalRulesCount   = $cloudFirewallPolicy.TotalRulesCount
                        EnabledRulesCount = $cloudFirewallPolicy.EnabledRulesCount
                    }
                }
            }

        }
    }
    #endregion Data Processing
    #region Assessment Logic

    # If Q1 returns no remote networks → Skipped
    if ($remoteNetworkCount -eq 0) {
        Write-PSFMessage 'No remote networks are configured. Cloud Firewall policies for remote networks are not applicable.' -Tag Test -Level Verbose
        Add-ZtTestResultDetail -SkippedBecause NotApplicable
        return
    }

    $passed = $false

    # If Q2 baseline profile has no linked cloud firewall policies OR all linked cloud firewall policies have state="disabled" → Fail
    if ($baselineProfileWithCloudFirewall.Count -eq 0) {
        $passed = $false
    }
    else {
        # Check if at least one policy has state="enabled"
        $enabledPolicies = $baselineProfileWithCloudFirewall | Where-Object { $_.PolicyLinkState -eq 'enabled' }

        if ($enabledPolicies.Count -eq 0) {
            # All linked cloud firewall policies have state="disabled" → Fail
            $passed = $false
        }
        else {
            # Check Q3: If no rules OR all rules have settings.status="disabled" → Fail
            # If at least one enabled policy has at least one enabled rule → Pass
            $hasEnabledRules = ($enabledPolicies | Where-Object { $_.EnabledRulesCount -gt 0 }).Count -gt 0
            $passed = $hasEnabledRules
        }
    }
    #endregion Assessment Logic

    #region Report Generation
    $mdInfo = ''

    if ($passed) {
        $testResultMarkdown = "Cloud Firewall is enabled and configured for remote networks. Branch office internet traffic is protected by firewall policies through the baseline security profile. .`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "Cloud Firewall is not properly configured for remote networks. Remote network internet traffic is not protected by cloud firewall policies.`n`n%TestResult%"
    }

    # Build remote network table rows
    $remoteNetworkTableRows = ''
    $totalEnabledRulesCount = 0
    $enabledPoliciesCount = 0

    if ($baselineProfileWithCloudFirewall.Count -gt 0) {
        $totalEnabledRulesCount = ($baselineProfileWithCloudFirewall | Measure-Object -Property EnabledRulesCount -Sum).Sum
        $enabledPoliciesCount = ($baselineProfileWithCloudFirewall | Where-Object { $_.PolicyLinkState -eq 'enabled' }).Count
    }

    foreach ($network in $remoteNetworks | Sort-Object -Property name) {
        $networkName = Get-SafeMarkdown -Text $network.name
        $encodedNetworkName = [System.Uri]::EscapeDataString($network.name)
        $networkPortalLink = "https://entra.microsoft.com/#view/Microsoft_Azure_Network_Access/EditBranchMenuBlade.MenuView/~/basics/branchId/$($network.id)/title/$encodedNetworkName/defaultMenuItemId/Basics"
        $policyLinked = if ($baselineProfileWithCloudFirewall.Count -gt 0) {
            'Yes'
        }
        else {
            'No'
        }
        $policyState = if ($enabledPoliciesCount -gt 0) {
            '✅ Enabled'
        }
        elseif ($baselineProfileWithCloudFirewall.Count -gt 0) {
            '❌ Disabled'
        }
        else {
            'N/A'
        }
        $rulesCount = if ($baselineProfileWithCloudFirewall.Count -gt 0) {
            $totalEnabledRulesCount
        }
        else {
            0
        }

        $remoteNetworkTableRows += "| [$networkName]($networkPortalLink) | $policyLinked | $policyState | $rulesCount |`n"
    }

    $remoteNetworkTemplate = @"

## Cloud Firewall Configuration for Remote Networks

| Remote Network Name | Baseline Profile Policy Linked | Policy State | Rules Configured |
| :--- | :--- | :--- | :--- |
{0}
"@
    $mdInfo += $remoteNetworkTemplate -f $remoteNetworkTableRows

    # Build baseline profile table
    if ($baselineProfileWithCloudFirewall.Count -gt 0) {
        $baselineProfileTableRows = ''

        foreach ($policyEntry in $baselineProfileWithCloudFirewall) {
            $profileName = Get-SafeMarkdown -Text $policyEntry.ProfileName
            $profilePriority = $policyEntry.ProfilePriority
            $policyName = Get-SafeMarkdown -Text $policyEntry.PolicyName
            $policyState = if ($policyEntry.PolicyLinkState -eq 'enabled') {
                '✅ Enabled'
            }
            else {
                '❌ Disabled'
            }
            $enabledRulesCount = $policyEntry.EnabledRulesCount

            $baselineProfileTableRows += "| $profileName | $profilePriority | $policyName | $policyState | $enabledRulesCount |`n"
        }

        $baselineProfileTemplate = @"

## Baseline Profile Details

| Profile Name | Priority | Linked Policy Name | Policy State | Enabled Rules Count |
| :--- | :--- | :--- | :--- | :--- |
{0}
"@
        $mdInfo += $baselineProfileTemplate -f $baselineProfileTableRows
    }
    else {
        $mdInfo += "`n## Baseline Profile Details`n`nNo baseline profile with cloud firewall policies configured.`n"
    }

    $mdInfo += "`n**Total Remote Networks:** $remoteNetworkCount`n"

    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '25416'
        Title  = 'Branch office internet traffic is protected by Cloud Firewall policies through Global Secure Access'
        Status = $passed
        Result = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
