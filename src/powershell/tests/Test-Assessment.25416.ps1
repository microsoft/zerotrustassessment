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
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose
    $activity = 'Checking Office Internet Traffic Protection via Cloud Firewall Policies'
    Write-ZtProgress -Activity $activity -Status 'Querying remote networks'

    # Q1: Get all configured remote networks (branch sites)
    $remoteNetworks = Invoke-ZtGraphRequest -RelativeUri 'networkaccess/connectivity/branches' -ApiVersion beta

    # Q2: Get filtering profiles with cloud firewall policy links
    Write-ZtProgress -Activity $activity -Status 'Querying baseline security profile'
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
                        $enabledCloudFirewallPolicies += [PSCustomObject]@{
                            PolicyLinkId    = $policyLink.id
                            PolicyLinkState = $policyLink.state
                            PolicyId        = if ($policyLink.policy) { $policyLink.policy.id } else { $null }
                            PolicyName      = if ($policyLink.policy) { $policyLink.policy.name } else { 'Unknown' }
                            PolicyRules     = if ($policyLink.policy ) { $policyLink.policy.settings.defaultAction } else { @()
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
    # 2. Check if baseline profile has enabled cloud firewall policies
    elseif ($null -ne $baselineProfileWithCloudFirewall) {
        # Baseline profile found with enabled policies - pass
        $passed = $true
    }
    else {
        # Remote networks exist but no enabled cloud firewall policies - fail
        $passed = $false
    }
    #endregion Assessment Logic

    #region Report Generation
    $testResultMarkdown = ""
    $mdInfo = ""
    $customStatus = $null

    # Determine if test should be skipped
    if ($remoteNetworkCount -eq 0) {
        $testResultMarkdown = "⏭️ No remote networks configured. Cloud firewall policies are only applicable when remote networks (branch sites) are configured.`n`n"
        $customStatus = 'Skipped'
    }
    else {
        if ($passed) {
            $testResultMarkdown = "✅ Office internet traffic is protected by cloud firewall policies through Global Secure Access.`n`n"
        }
        else {
            $testResultMarkdown = "❌ Office internet traffic is not adequately protected by cloud firewall policies.`n`n"
        }

        # Build detailed information section
        $mdInfo = "## Cloud Firewall Policy Configuration`n`n"

        # Display baseline profile with cloud firewall policies
        if ($null -ne $baselineProfileWithCloudFirewall) {
            $mdInfo += "## Baseline Profile Cloud Firewall Policies`n`n"
            $mdInfo += "| Profile Name | Profile Priority | Profile State | Cloud Firewall Policies |`n"
            $mdInfo += "| :--- | :--- | :--- | :--- |`n"

            $baselineProfilePortalLink = "https://entra.microsoft.com/#view/Microsoft_Azure_Network_Access/EditProfileMenuBlade.MenuView/~/basics/profileId/$($baselineProfileWithCloudFirewall.ProfileId)"
            $profileName = Get-SafeMarkdown -Text $baselineProfileWithCloudFirewall.ProfileName
            $profilePriority = $baselineProfileWithCloudFirewall.ProfilePriority
            $profileState = $baselineProfileWithCloudFirewall.ProfileState
            $policyCount = $baselineProfileWithCloudFirewall.PolicyCount

            $mdInfo += "| [$profileName]($baselineProfilePortalLink) | $profilePriority | $profileState | $policyCount enabled |`n"
            $mdInfo += "`n"

            # List cloud firewall policies with their state
            if ($baselineProfileWithCloudFirewall.CloudFirewallPolicies.Count -gt 0) {
                $mdInfo += "| Policy Name | Link State |`n"
                $mdInfo += "| :--- | :--- |`n"

                foreach ($policyLink in @($baselineProfileWithCloudFirewall.CloudFirewallPolicies)) {
                    $policyName = Get-SafeMarkdown -Text $policyLink.PolicyName
                    $linkState = $policyLink.PolicyLinkState
                    $mdInfo += "| $policyName | $linkState |`n"
                }
                $mdInfo += "`n"
            }
        }
        else {
            $mdInfo += "**Baseline Security Profile Status: Not Configured or No Enabled Policies**`n`n"
            if ($remoteNetworkCount -gt 0) {
                $mdInfo += "The baseline profile with priority 65000 is required with enabled cloud firewall policies and rules to protect office internet traffic from remote networks.`n`n"
            }
        }

        # Display remote networks information
        $mdInfo += "## Remote Networks Configuration`n`n"
        $mdInfo += "**Remote Networks Configured: $remoteNetworkCount**`n`n"

        if ($remoteNetworkCount -gt 0) {
            $mdInfo += "| Remote Network Name | Connectivity State |`n"
            $mdInfo += "| :--- | :--- |`n"

            foreach ($network in @($remoteNetworks) | Sort-Object -Property name) {
                $networkName = Get-SafeMarkdown -Text $network.name
                $connectivityState = if ($network.connectivityState) { $network.connectivityState } else { 'Unknown' }
                $mdInfo += "| $networkName | $connectivityState |`n"
            }

            $mdInfo += "`n"
        }

        $mdInfo += "`n**Note:** Cloud firewall policies must be linked to the baseline security profile (priority 65000) and enabled to protect office internet traffic from remote networks. Ensure policies include appropriate 5-tuple rules to filter malicious outbound connections and prevent data exfiltration.`n"

        # Add mdInfo to the main markdown if there's content
        if ($mdInfo) {
            $testResultMarkdown += "%TestResult%"
        }
    }
    #endregion Report Generation

    # Replace placeholder with actual detailed info
    if ($mdInfo) {
        $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo
    }

    $params = @{
        TestId = '25416'
        Status = $passed
        Result = $testResultMarkdown
    }
    if ($customStatus) {
        $params.CustomStatus = $customStatus
    }
    Add-ZtTestResultDetail @params
}}
