<#
.SYNOPSIS
    Checks if internet traffic is protected against threats using Global Secure Access threat intelligence filtering.

.DESCRIPTION
    This test validates that threat intelligence filtering is enabled and associated with either the baseline profile
    or a security profile linked to a Conditional Access policy. Threat intelligence policies block traffic to malicious
    destinations identified by Microsoft and third-party threat intelligence feeds.

.NOTES
    Test ID: 25412
    Category: Global Secure Access
    Pillar: Networking
    Required API: networkAccess/threatIntelligencePolicies, networkAccess/filteringProfiles, identity/conditionalAccess/policies
#>

function Test-Assessment-25412 {
    [ZtTest(
        Category = 'Global Secure Access',
        ImplementationCost = 'Medium',
        Service = ('Graph'),
        CompatibleLicense = ('Entra_Premium_Internet_Access'),
        Pillar = 'Network',
        RiskLevel = 'High',
        SfiPillar = 'Protect networks',
        TenantType = ('Workforce'),
        TestId = 25412,
        Title = 'Internet traffic is protected against threats using Global Secure Access threat intelligence filtering',
        UserImpact = 'Medium'
    )]
    [CmdletBinding()]
    param()

    # Define constants
    [int]$BASELINE_PROFILE_PRIORITY = 65000
    [string]$THREAT_INTELLIGENCE_POLICY_LINK_TYPE = '#microsoft.graph.networkaccess.threatIntelligencePolicyLink'

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking threat intelligence filtering configuration'

    $threatIntelPolicies = $null
    $filteringProfiles = $null
    $caPolicies = $null
    $q3Evaluated = $false
    $q1Error = $null
    $q2Error = $null
    $q3Error = $null

    # Q1: Get threat intelligence policies
    Write-ZtProgress -Activity $activity -Status 'Getting threat intelligence policies'
    try {
        $threatIntelPolicies = Invoke-ZtGraphRequest -RelativeUri 'networkAccess/threatIntelligencePolicies' -ApiVersion beta -ErrorAction Stop
        Write-PSFMessage "Found $($threatIntelPolicies.Count) threat intelligence policies" -Level Verbose
    }
    catch {
        $q1Error = $_
        Write-PSFMessage "Failed to get threat intelligence policies: $_" -Tag Test -Level Warning
    }

    # Q2 depends on Q1: only query filtering profiles when TI policies exist.
    if (-not $q1Error -and $threatIntelPolicies -and $threatIntelPolicies.Count -gt 0) {
        Write-ZtProgress -Activity $activity -Status 'Getting filtering profiles'
        try {
            $filteringProfiles = Invoke-ZtGraphRequest -RelativeUri 'networkAccess/filteringProfiles' -QueryParameters @{ '$select' = 'id,name,description,state,version,priority'; '$expand' = 'policies($expand=policy)' } -ApiVersion beta -ErrorAction Stop
            Write-PSFMessage "Found $($filteringProfiles.Count) filtering profiles" -Level Verbose
        }
        catch {
            $q2Error = $_
            Write-PSFMessage "Failed to get filtering profiles: $_" -Tag Test -Level Warning
        }
    }
    #endregion Data Collection

    #region Assessment Logic
    $passed = $false
    $customStatus = $null
    $testResultMarkdown = ''
    $investigateMessage = "⚠️ Unable to determine threat intelligence filtering status due to an API or access error. Re-run the assessment after verifying Microsoft Graph access and retrying the check.`n`n%TestResult%"
    $failMessage = "❌ No enabled threat intelligence policy link is enforced through the baseline profile or a security profile assigned by a Conditional Access policy.`n`n%TestResult%"
    $baselineProfileEvidence = $null
    $caPolicyEvidence = @()

    # Step 1: Verify at least one threat intelligence policy exists.
    $hasRequiredQueryError = ($null -ne $q1Error) -or ($null -ne $q2Error)
    $threatIntelPolicyIds = [System.Collections.Generic.HashSet[string]]::new()
    if ($threatIntelPolicies) {
        foreach ($threatIntelPolicy in $threatIntelPolicies) {
            if ($threatIntelPolicy.id) {
                [void]$threatIntelPolicyIds.Add($threatIntelPolicy.id)
            }
        }
    }
    $hasThreatIntelPolicies = $threatIntelPolicyIds.Count -gt 0

    # Q1/Q2 failures are always investigate because they block prerequisite evaluation.
    if ($hasRequiredQueryError) {
        $passed = $false
        $customStatus = 'Investigate'
        $testResultMarkdown = $investigateMessage
    }
    # If no threat intelligence policies exist, test fails regardless of profile linkage.
    elseif (-not $hasThreatIntelPolicies) {
        $passed = $false
        $testResultMarkdown = $failMessage
    }
    else {
        # Step 2: Check baseline profile for threat intelligence policy link
        $baselineProfile = $filteringProfiles | Where-Object { $_.priority -eq $BASELINE_PROFILE_PRIORITY }
        $baselineHasTI = $false

        if ($baselineProfile) {
            $baselineTiPolicyLinks = @($baselineProfile.policies | Where-Object {
                $_.'@odata.type' -eq $THREAT_INTELLIGENCE_POLICY_LINK_TYPE -and
                $_.policy.id -and $threatIntelPolicyIds.Contains($_.policy.id)
            })
            $baselineEnabledTiLinks = @($baselineTiPolicyLinks | Where-Object { $_.state -eq 'enabled' })
            $baselinePolicyLinkState = if ($baselineEnabledTiLinks.Count -gt 0) {
                'enabled'
            }
            elseif ($baselineTiPolicyLinks.Count -gt 0) {
                if ($baselineTiPolicyLinks[0].state) { $baselineTiPolicyLinks[0].state } else { 'N/A' }
            }
            else {
                'N/A'
            }

            $baselineProfileEvidence = [PSCustomObject]@{
                Profile        = $baselineProfile
                TiPolicyLinks  = $baselineTiPolicyLinks
                EnabledTiLinks = $baselineEnabledTiLinks
                HasTI          = $baselineTiPolicyLinks.Count -gt 0
                PolicyLinkState= $baselinePolicyLinkState
            }
            $baselineHasTI = $baselineProfileEvidence.EnabledTiLinks.Count -gt 0 -and $baselineProfile.state -eq 'enabled'
        }

        # Step 3: Decide whether Conditional Access fallback evaluation is required.
        $requiresConditionalAccessEvaluation = -not $baselineHasTI

        if (-not $requiresConditionalAccessEvaluation) {
            # Baseline has enabled TI policy link - Pass
            $passed = $true
        }
        else {
            # Step 4: Baseline is not effective, so evaluate Conditional Access fallback.
            $q3Evaluated = $true
            Write-ZtProgress -Activity $activity -Status 'Getting Conditional Access policies'
            try {
                $caPolicies = Get-ZtConditionalAccessPolicy -ErrorAction Stop
                Write-PSFMessage "Found $($caPolicies.Count) Conditional Access policies" -Level Verbose
            }
            catch {
                $q3Error = $_
                Write-PSFMessage "Failed to get Conditional Access policies: $_" -Tag Test -Level Warning
            }

            if ($q3Error) {
                $passed = $false
                $customStatus = 'Investigate'
                $testResultMarkdown = $investigateMessage
            }

            $enabledCAPoliciesWithGSA = @()
            if (-not $q3Error -and $caPolicies) {
                $enabledCAPoliciesWithGSA = @($caPolicies | Where-Object {
                    $_.state -eq 'enabled' -and
                    $_.sessionControls.globalSecureAccessFilteringProfile.isEnabled -eq $true
                })
            }

            # Step 5: Cross-reference profileIds with filtering profiles; collect full evidence for reporting.
            $foundValidProfile = $false
            if (-not $q3Error) {
                foreach ($caPolicy in $enabledCAPoliciesWithGSA) {
                    $profileId = $caPolicy.sessionControls.globalSecureAccessFilteringProfile.profileId
                    $linkedProfile = $filteringProfiles | Where-Object { $_.id -eq $profileId }
                    $profileTiLinks = @()
                    $enabledProfileTiLinks = @()
                    $profilePolicyLinkState = 'N/A'
                    $profileHasTI = $false
                    $profileIsEffective = $false

                    if ($linkedProfile) {
                        $profileTiLinks = @($linkedProfile.policies | Where-Object {
                            $_.'@odata.type' -eq $THREAT_INTELLIGENCE_POLICY_LINK_TYPE -and
                            $_.policy.id -and $threatIntelPolicyIds.Contains($_.policy.id)
                        })
                        $enabledProfileTiLinks = @($profileTiLinks | Where-Object { $_.state -eq 'enabled' })
                        $profileHasTI = $profileTiLinks.Count -gt 0
                        $profilePolicyLinkState = if ($enabledProfileTiLinks.Count -gt 0) {
                            'enabled'
                        }
                        elseif ($profileTiLinks.Count -gt 0) {
                            if ($profileTiLinks[0].state) { $profileTiLinks[0].state } else { 'N/A' }
                        }
                        else {
                            'N/A'
                        }
                        $profileIsEffective = $linkedProfile.state -eq 'enabled' -and $enabledProfileTiLinks.Count -gt 0

                        if ($profileIsEffective -and -not $foundValidProfile) {
                            $foundValidProfile = $true
                        }
                    }

                    $caPolicyEvidence += [PSCustomObject]@{
                        CAPolicy             = $caPolicy
                        ProfileId            = $profileId
                        LinkedProfile        = $linkedProfile
                        ProfileTiLinks       = $profileTiLinks
                        EnabledProfileTiLinks= $enabledProfileTiLinks
                        ProfileHasTI         = $profileHasTI
                        PolicyLinkState      = $profilePolicyLinkState
                        IsEffective          = $profileIsEffective
                    }
                }
            }

            if (-not $q3Error) {
                $passed = $foundValidProfile
            }
        }

        if ($passed) {
            $testResultMarkdown = "✅ Threat intelligence filtering is enabled and enforced through an enabled baseline profile or an enabled security profile assigned by a Conditional Access policy.`n`n%TestResult%"
        }
        elseif (-not $customStatus) {
            $testResultMarkdown = $failMessage
        }
    }
    #endregion Assessment Logic

    #region Report Generation
    $mdInfo = ''

    # Table 2: Baseline Profile Threat Intelligence Status
    $table2Title = 'Baseline Profile Threat Intelligence Status'
    $table2Link = 'https://entra.microsoft.com/#view/Microsoft_Azure_Network_Access/FilteringPolicyProfiles.ReactView'
    $threatPolicyLink = 'https://entra.microsoft.com/#view/Microsoft_Azure_Network_Access/ThreatIntelligencePolicy.ReactView'

    if ($hasThreatIntelPolicies -and -not $q1Error -and -not $q2Error) {
        if ($baselineProfileEvidence) {
            $baselineProfile = $baselineProfileEvidence.Profile
            $baselineName = Get-SafeMarkdown $baselineProfile.name
            $baselineId = $baselineProfile.id
            $baselineStateDisplay = if ($baselineProfile.state -in @('enabled', 'disabled')) {
                '{0} {1}' -f (Get-ZtPassFail -Condition ($baselineProfile.state -eq 'enabled')), (Get-FormattedPolicyState -PolicyState $baselineProfile.state)
            }
            else {
                'N/A'
            }
            $baselineTitle = [System.Uri]::EscapeDataString("Edit $($baselineProfile.name)")
            $baselineProfileLink = "https://entra.microsoft.com/#view/Microsoft_Azure_Network_Access/EditProfileMenuBlade.MenuView/~/basics/profileId/$baselineId/title/$baselineTitle/defaultMenuItemId/Basics"
            $baselineNameWithLink = "[$baselineName]($baselineProfileLink)"

            $hasTI = $baselineProfileEvidence.HasTI
            $policyLinkState = $baselineProfileEvidence.PolicyLinkState
            $policyLinkStateDisplay = if ($policyLinkState -in @('enabled', 'disabled')) {
                '{0} {1}' -f (Get-ZtPassFail -Condition ($policyLinkState -eq 'enabled')), (Get-FormattedPolicyState -PolicyState $policyLinkState)
            }
            else {
                'N/A'
            }

            $hasTIDisplay = if ($hasTI) { '✅ Yes' } else { '❌ No' }

            $table2Template = @'

### [{0}]({1})

| Profile Name | [Has Threat Intelligence Policy]({6}) | Policy Link State | Profile State |
| :----------- | :----------------------------- | :---------------- | :------------ |
| {2} | {3} | {4} | {5} |
'@

            $table2 = $table2Template -f $table2Title, $table2Link, $baselineNameWithLink, $hasTIDisplay, $policyLinkStateDisplay, $baselineStateDisplay, $threatPolicyLink
        }
        else {
            $table2 = @"

### [$table2Title]($table2Link)

No baseline profile found.
"@
        }

        $mdInfo += $table2

        # Table 3 is only shown when Q3 was needed and evaluated.
        if ($q3Evaluated) {
            $table3Title = 'Conditional Access Policies with Global Secure Access Session Control'
            $table3Link = 'https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/ConditionalAccessBlade/~/Policies'

            if ($q3Error) {
                $table3 = @"

### [$table3Title]($table3Link)

Unable to retrieve Conditional Access policies from Microsoft Graph, so Conditional Access enforcement could not be evaluated.
"@
            }
            elseif ($caPolicyEvidence.Count -gt 0) {
                $table3Rows = foreach ($evidence in $caPolicyEvidence) {
                    $caPolicy = $evidence.CAPolicy
                    $caPolicyName = Get-SafeMarkdown $caPolicy.displayName
                    $caPolicyId = $caPolicy.id
                    $caPolicyStateDisplay = '✅ Enabled'
                    $profileId = $evidence.ProfileId
                    $linkedProfile = $evidence.LinkedProfile
                    $profileName = if ($linkedProfile) { Get-SafeMarkdown $linkedProfile.name } else { 'N/A' }
                    $profileStateDisplay = if ($linkedProfile -and $linkedProfile.state -in @('enabled', 'disabled')) {
                        '{0} {1}' -f (Get-ZtPassFail -Condition ($linkedProfile.state -eq 'enabled')), (Get-FormattedPolicyState -PolicyState $linkedProfile.state)
                    }
                    else {
                        'N/A'
                    }
                    $profileNameWithLink = if ($linkedProfile) {
                        $profileTitle = [System.Uri]::EscapeDataString("Edit $($linkedProfile.name)")
                        $profileLink = "https://entra.microsoft.com/#view/Microsoft_Azure_Network_Access/EditProfileMenuBlade.MenuView/~/basics/profileId/$profileId/title/$profileTitle/defaultMenuItemId/Basics"
                        "[$profileName]($profileLink)"
                    }
                    else {
                        'N/A'
                    }

                    $policyLinkState = $evidence.PolicyLinkState
                    $policyLinkStateDisplay = if ($policyLinkState -in @('enabled', 'disabled')) {
                        '{0} {1}' -f (Get-ZtPassFail -Condition ($policyLinkState -eq 'enabled')), (Get-FormattedPolicyState -PolicyState $policyLinkState)
                    }
                    else {
                        'N/A'
                    }
                    $profileHasTIDisplay = if ($evidence.ProfileHasTI) { '✅ Yes' } else { '❌ No' }

                    $caPolicyLink = "https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/$caPolicyId"

                    "| [$caPolicyName]($caPolicyLink) | $caPolicyStateDisplay | $profileNameWithLink | $profileStateDisplay | $profileHasTIDisplay | $policyLinkStateDisplay |"
                }

                $table3Template = @'

### [{0}]({1})

| CA Policy Name | CA Policy State | Profile Name | Profile State | [Profile Has TI Policy]({3}) | Policy Link State |
| :------------- | :-------------- | :----------- | :------------ | :-------------------- | :---------------- |
{2}
'@

                $table3 = $table3Template -f $table3Title, $table3Link, ($table3Rows -join "`n"), $threatPolicyLink
            }
            else {
                $table3 = @"

### [$table3Title]($table3Link)

No Conditional Access policies with Global Secure Access session control found.
"@
            }

            $mdInfo += $table3
        }
    }

    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '25412'
        Status = $passed
        Result = $testResultMarkdown
    }
    if ($customStatus) {
        $params.CustomStatus = $customStatus
    }
    Add-ZtTestResultDetail @params
}
