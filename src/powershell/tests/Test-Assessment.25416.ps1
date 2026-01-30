<#
.SYNOPSIS
    Office Internet Traffic Protected by Cloud Firewall Policies through Global Secure Access

.DESCRIPTION
    Evaluates whether branch office internet traffic is protected by cloud firewall policies through Global Secure Access.
    Without cloud firewall policies enforced on remote network traffic, branch office internet traffic flows through
    Global Secure Access without egress filtering, exposing the organization to data exfiltration, command-and-control
    communications, and malicious outbound connections from compromised branch assets.

.NOTES
    Test ID: 25416
    Pillar: Networking
    Risk Level: High
    SFI Pillar: Protect networks
#>

function Test-Assessment-25416 {
    [ZtTest(
        Category = 'Global Secure Access',
        ImplementationCost = 'Medium',
        MinimumLicense = ('Entra_Premium_Internet_Access'),
        Pillar = 'Networking',
        RiskLevel = 'High',
        SfiPillar = 'Protect networks',
        TenantType = ('Workforce','External'),
        TestId = '25416',
        Title = 'Branch office internet traffic is protected by Cloud Firewall policies through Global Secure Access',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    # Define constants
    [int]$BASELINE_PROFILE_PRIORITY = 65000

    #region Data Collection
    #Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose
    $activity = 'Checking Office Internet Traffic Protection via Cloud Firewall Policies'
    #Write-ZtProgress -Activity $activity -Status 'Querying remote networks'

    # Q1: Get all configured remote networks (branch sites)
    $remoteNetworks = Invoke-ZtGraphRequest -RelativeUri 'networkaccess/connectivity/branches' -ApiVersion beta

    # Q2: Get filtering profiles with cloud firewall policy links
    #Write-ZtProgress -Activity $activity -Status 'Querying baseline security profile'
    $filteringProfiles = Invoke-ZtGraphRequest -RelativeUri 'networkaccess/filteringProfiles' -QueryParameters @{
        '$select' = 'id,name,description,state,version,priority'
        '$expand' = 'policies($select=id,state;$expand=policy)'
    } -ApiVersion beta
    #endregion Data Collection

    #region Data Processing
    # Identify baseline profile with enabled cloud firewall policies
    $baselineProfileWithCloudFirewall = $null
    $remoteNetworkCount = if ($remoteNetworks) { @($remoteNetworks).Count } else { 0 }

    if ($filteringProfiles -and $remoteNetworkCount -gt 0) {
        $baselineProfile = @($filteringProfiles | Where-Object { $_.priority -eq $BASELINE_PROFILE_PRIORITY })

        if ($null -ne $baselineProfile) {

            # Check if baseline profile has enabled cloud firewall policy links
            if ($baselineProfile.policies) {
                $enabledCloudFirewallPolicies = @()

                foreach ($policyLink in @($baselineProfile.policies)) {
                    # Check if this is a cloud firewall policy link and it's enabled
                    if ($policyLink.'@odata.type' -eq '#microsoft.graph.networkaccess.cloudFirewallPolicyLink' -and $policyLink.state -eq 'enabled') {
                        # Q3: Retrieve the actual cloud firewall policy rules using policy.id
                        $policyId = if ($policyLink.policy) { $policyLink.policy.id } else { $null }
                        $policyRulesData = @()
                        $enabledRulesCount = 0

                        if ($policyId) {
                            $policyDisplayName = if ($policyLink.policy.name) { $policyLink.policy.name } else { 'Unknown' }
                            #Write-ZtProgress -Activity $activity -Status "Retrieving policy rules for $policyDisplayName"
                            try {
                                # Q3: GET https://graph.microsoft.com/beta/networkaccess/cloudfirewallpolicies/{policyId}?$expand=policyRules
                                $policyWithRules = Invoke-ZtGraphRequest -RelativeUri "networkaccess/cloudfirewallpolicies/$policyId" -QueryParameters @{
                                    '$expand' = 'policyRules'
                                } -ApiVersion beta -disablecache

                                if ($policyWithRules -and $policyWithRules.policyRules) {
                                    $policyRulesData = @($policyWithRules.policyRules)
                                    # Count enabled rules where settings.status = 'enabled'
                                    $enabledRulesCount = @($policyRulesData | Where-Object { $_.settings.status -eq 'enabled' }).Count
                                }
                            }
                            catch {
                                #Write-PSFMessage "Error retrieving policy rules for policy $policyId`: $_" -Tag Test -Level Warning
                            }
                        }

                        $enabledCloudFirewallPolicies += [PSCustomObject]@{
                            PolicyLinkId      = $policyLink.id
                            PolicyLinkState   = $policyLink.state
                            PolicyId          = $policyId
                            PolicyName        = if ($policyLink.policy) { $policyLink.policy.name } else { 'Unknown' }
                            PolicyRules       = $policyRulesData
                            TotalRulesCount   = $policyRulesData.Count
                            EnabledRulesCount = $enabledRulesCount
                        }
                    }
                }

                if ($enabledCloudFirewallPolicies.Count -gt 0) {
                    $baselineProfileWithCloudFirewall = [PSCustomObject]@{
                        ProfileId              = $baselineProfile.id
                        ProfileName            = $baselineProfile.name
                        ProfileState           = $baselineProfile.state
                        ProfilePriority        = $baselineProfile.priority
                        CloudFirewallPolicies  = $enabledCloudFirewallPolicies
                        PolicyCount            = $enabledCloudFirewallPolicies.Count
                    }
                }
            }
        }
    }
    #endregion Data Processing
    #region Assessment Logic
    $passed = $false

    # Evaluation logic per specification:
    # 1. Check if remote networks are configured (Q1 returns results)
    if ($remoteNetworkCount -eq 0) {
        # No remote networks configured - test is skipped
        $passed = $false
    }
    # 2. Check if baseline profile has enabled cloud firewall policies with at least one enabled rule
    elseif ($null -ne $baselineProfileWithCloudFirewall) {
        # Q3: Check if any policy has enabled rules
        $hasEnabledRules = @($baselineProfileWithCloudFirewall.CloudFirewallPolicies | Where-Object { $_.EnabledRulesCount -gt 0 }).Count -gt 0
        if ($hasEnabledRules) {
            $passed = $true
        }else {
            $passed = $false
        }
    }
    else {
        # Remote networks exist but no enabled cloud firewall policies - fail
        $passed = $false
    }
    #endregion Assessment Logic

    #region Report Generation
    $testResultMarkdown = ""

    # Determine if test should be skipped
    if ($remoteNetworkCount -eq 0) {
        $testResultMarkdown = "⏭️ No remote networks configured. Cloud firewall policies are only applicable when remote networks (branch sites) are configured."
    }
    else {
        # Build initial status message with placeholder
        if ($passed) {
            $testResultMarkdown = "✅ Office internet traffic is protected by cloud firewall policies through Global Secure Access.`n`n%TestResult%"
        }
        else {
            $testResultMarkdown = "❌ Office internet traffic is not adequately protected by cloud firewall policies.`n`n%TestResult%"
        }

        # Build test output data section
        $mdInfo = "## Test output data`n`n"

        # Remote Networks Configuration Table Template
        $remoteNetworkTableTemplate = @'
#### [Cloud Firewall Configuration for Remote Networks](https://entra.microsoft.com/#view/Microsoft_Azure_Network_Access/CloudFirewallPolicy.ReactView)

| Remote Network Name | Remote Network ID | Baseline Profile Policy Linked | Policy State | Rules Configured |
|---------------------|-------------------|-------------------------------|--------------|------------------|
{0}

'@

        # Build remote network table rows
        $remoteNetworkTableRows = ""
        if ($remoteNetworks -and @($remoteNetworks).Count -gt 0) {
            foreach ($network in @($remoteNetworks) | Sort-Object -Property name) {
                $networkName = Get-SafeMarkdown -Text $network.name
                $networkId = Get-SafeMarkdown -Text $network.id
                $policyLinked = if ($null -ne $baselineProfileWithCloudFirewall) { "Yes" } else { "No" }
                $policyState = if ($null -ne $baselineProfileWithCloudFirewall) { "Enabled" } else { "N/A" }
                $rulesCount = if ($null -ne $baselineProfileWithCloudFirewall) { ($baselineProfileWithCloudFirewall.CloudFirewallPolicies | Measure-Object -Property EnabledRulesCount -Sum).Sum } else { 0 }

                $remoteNetworkTableRows += "| $networkName | $networkId | $policyLinked | $policyState | $rulesCount |`n"
            }
            $mdInfo += $remoteNetworkTableTemplate -f $remoteNetworkTableRows
        }

        # Baseline Profile Details Table Template
        $baselineProfileTableTemplate = @'
#### Baseline Profile Details

| Profile Name | Priority | Linked Policy Name | Policy State | Enabled Rules Count |
|--------------|----------|-------------------|--------------|---------------------|
{0}

'@

        # Build baseline profile table rows
        $baselineProfileTableRows = ""
        if ($null -ne $baselineProfileWithCloudFirewall) {
            $profileName = Get-SafeMarkdown -Text $baselineProfileWithCloudFirewall.ProfileName
            $profilePriority = $baselineProfileWithCloudFirewall.ProfilePriority

            foreach ($policyLink in @($baselineProfileWithCloudFirewall.CloudFirewallPolicies)) {
                $policyName = Get-SafeMarkdown -Text $policyLink.PolicyName
                $policyState = $policyLink.PolicyLinkState
                $enabledRulesCount = $policyLink.EnabledRulesCount

                $baselineProfileTableRows += "| $profileName | $profilePriority | $policyName | $policyState | $enabledRulesCount |`n"
            }
        }
        else {
            $baselineProfileTableRows = "| N/A | 65000 | None | N/A | 0 |`n"
        }

        $mdInfo += $baselineProfileTableTemplate -f $baselineProfileTableRows

        # Replace the placeholder with the actual test result data
        $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo
    }
    #endregion Report Generation

    $params = @{
        TestId = '25416'
        Title = 'Branch office internet traffic is protected by Cloud Firewall policies through Global Secure Access'
        Status = $passed
        Result = $testResultMarkdown
    }

    try {
        Add-ZtTestResultDetail @params
    }
    catch {
        Write-PSFMessage "Error adding test result detail: $_" -Tag Test -Level Error
        throw
    }
}
