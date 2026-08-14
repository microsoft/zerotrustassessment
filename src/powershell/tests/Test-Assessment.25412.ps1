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

    # Q2: Get all filtering profiles with expanded policies
    Write-ZtProgress -Activity $activity -Status 'Getting filtering profiles'
    try {
        $filteringProfiles = Invoke-ZtGraphRequest -RelativeUri 'networkAccess/filteringProfiles' -QueryParameters @{ '$select' = 'id,name,description,state,version,priority'; '$expand' = 'policies($expand=policy)' } -ApiVersion beta -ErrorAction Stop
        Write-PSFMessage "Found $($filteringProfiles.Count) filtering profiles" -Level Verbose
    }
    catch {
        $q2Error = $_
        Write-PSFMessage "Failed to get filtering profiles: $_" -Tag Test -Level Warning
    }

    # Q3: Get Conditional Access policies only when filtering profiles were retrieved.
    if ($filteringProfiles -and $filteringProfiles.Count -gt 0) {
        Write-ZtProgress -Activity $activity -Status 'Getting Conditional Access policies'
        try {
            $caPolicies = Get-ZtConditionalAccessPolicy -ErrorAction Stop
            Write-PSFMessage "Found $($caPolicies.Count) Conditional Access policies" -Level Verbose
        }
        catch {
            $q3Error = $_
            Write-PSFMessage "Failed to get Conditional Access policies: $_" -Tag Test -Level Warning
        }
    }
    #endregion Data Collection

    #region Assessment Logic
    $passed = $false
    $customStatus = $null
    $testResultMarkdown = ''
    $investigateMessage = "⚠️ Unable to determine threat intelligence filtering status due to an API or access error. Re-run the assessment after verifying Microsoft Graph access and retrying the check.`n`n%TestResult%"
    $failMessage = "❌ No enabled threat intelligence policy link is enforced through the baseline profile or a security profile assigned by a Conditional Access policy.`n`n%TestResult%"

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
            $tiPolicyLinks = @($baselineProfile.policies | Where-Object {
                $_.'@odata.type' -eq $THREAT_INTELLIGENCE_POLICY_LINK_TYPE -and
                $_.policy.id -and $threatIntelPolicyIds.Contains($_.policy.id)
            })

            $enabledTiLinks = @($tiPolicyLinks | Where-Object { $_.state -eq 'enabled' })
            $baselineHasTI = $enabledTiLinks.Count -gt 0 -and $baselineProfile.state -eq 'enabled'
        }

        if ($baselineHasTI) {
            # Baseline has enabled TI policy link - Pass
            $passed = $true
        }
        elseif ($q3Error) {
            # Q3 is only required when baseline is not effective.
            $passed = $false
            $customStatus = 'Investigate'
            $testResultMarkdown = $investigateMessage
        }
        else {
            # Step 3: Check CA policies for GSA session controls
            $enabledCAPoliciesWithGSA = @()
            if ($caPolicies) {
                $enabledCAPoliciesWithGSA = @($caPolicies | Where-Object {
                    $_.state -eq 'enabled' -and
                    $_.sessionControls.globalSecureAccessFilteringProfile.isEnabled -eq $true
                })
            }

            # Step 4: Cross-reference profileIds with filtering profiles
            $foundValidProfile = $false
            foreach ($caPolicy in $enabledCAPoliciesWithGSA) {
                $profileId = $caPolicy.sessionControls.globalSecureAccessFilteringProfile.profileId
                $linkedProfile = $filteringProfiles | Where-Object { $_.id -eq $profileId }

                if ($linkedProfile) {
                    # Check if this profile is enabled and has an enabled threat intelligence policy link
                    $tiLinks = @($linkedProfile.policies | Where-Object {
                        $_.'@odata.type' -eq $THREAT_INTELLIGENCE_POLICY_LINK_TYPE -and
                        $_.policy.id -and $threatIntelPolicyIds.Contains($_.policy.id)
                    })
                    $enabledTiLinks = @($tiLinks | Where-Object { $_.state -eq 'enabled' })

                    if ($linkedProfile.state -eq 'enabled' -and $enabledTiLinks.Count -gt 0) {
                        $foundValidProfile = $true
                        break
                    }
                }
            }

            $passed = $foundValidProfile
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

    if (-not $q1Error -and -not $q2Error) {
        $baselineProfile = $filteringProfiles | Where-Object { $_.priority -eq $BASELINE_PROFILE_PRIORITY }

        if ($baselineProfile) {
            $baselineName = Get-SafeMarkdown $baselineProfile.name
            $baselineId = $baselineProfile.id
            $baselineState = $baselineProfile.state
            $baselineTitle = [System.Uri]::EscapeDataString("Edit $($baselineProfile.name)")
            $baselineProfileLink = "https://entra.microsoft.com/#view/Microsoft_Azure_Network_Access/EditProfileMenuBlade.MenuView/~/basics/profileId/$baselineId/title/$baselineTitle/defaultMenuItemId/Basics"
            $baselineNameWithLink = "[$baselineName]($baselineProfileLink)"

            $tiPolicyLinks = @($baselineProfile.policies | Where-Object {
                $_.'@odata.type' -eq $THREAT_INTELLIGENCE_POLICY_LINK_TYPE -and
                $_.policy.id -and $threatIntelPolicyIds.Contains($_.policy.id)
            })
            $enabledTiLinks = @($tiPolicyLinks | Where-Object { $_.state -eq 'enabled' })

            $hasTI = $tiPolicyLinks.Count -gt 0
            $policyLinkState = if ($enabledTiLinks.Count -gt 0) {
                'enabled'
            }
            elseif ($tiPolicyLinks.Count -gt 0) {
                if ($tiPolicyLinks[0].state) { $tiPolicyLinks[0].state } else { 'N/A' }
            }
            else {
                'N/A'
            }

            $hasTIDisplay = if ($hasTI) { '✅ Yes' } else { '❌ No' }

            $table2Template = @'

## [{0}]({1})

| Profile Name | [Has Threat Intelligence Policy]({6}) | Policy Link State | Profile State |
| :----------- | :----------------------------- | :---------------- | :------------ |
| {2} | {3} | {4} | {5} |
'@

            $table2 = $table2Template -f $table2Title, $table2Link, $baselineNameWithLink, $hasTIDisplay, $policyLinkState, $baselineState, $threatPolicyLink
        }
        else {
            $table2 = @"

## [$table2Title]($table2Link)

No baseline profile found.
"@
        }

        $mdInfo += $table2

        # Table 3: Conditional Access Policies with Global Secure Access Session Control
        $table3Title = 'Conditional Access Policies with Global Secure Access Session Control'
        $table3Link = 'https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/ConditionalAccessBlade/~/Policies'

        $enabledCAPoliciesWithGSA = @()
        if ($caPolicies) {
            $enabledCAPoliciesWithGSA = @($caPolicies | Where-Object {
                $_.state -eq 'enabled' -and
                $_.sessionControls.globalSecureAccessFilteringProfile.isEnabled -eq $true
            })
        }

        if ($q3Error) {
            $table3 = @"

## [$table3Title]($table3Link)

Unable to retrieve Conditional Access policies from Microsoft Graph, so Conditional Access enforcement could not be evaluated.
"@
        }
        elseif ($enabledCAPoliciesWithGSA.Count -gt 0) {
            $table3Rows = foreach ($caPolicy in $enabledCAPoliciesWithGSA) {
                $caPolicyName = Get-SafeMarkdown $caPolicy.displayName
                $caPolicyId = $caPolicy.id
                $caPolicyState = $caPolicy.state
                $profileId = $caPolicy.sessionControls.globalSecureAccessFilteringProfile.profileId

                # Find the linked profile
                $linkedProfile = $filteringProfiles | Where-Object { $_.id -eq $profileId }
                $profileName = if ($linkedProfile) { Get-SafeMarkdown $linkedProfile.name } else { 'N/A' }
                $profileState = if ($linkedProfile -and $linkedProfile.state) { $linkedProfile.state } else { 'N/A' }
                $profileNameWithLink = if ($linkedProfile) {
                    $profileTitle = [System.Uri]::EscapeDataString("Edit $($linkedProfile.name)")
                    $profileLink = "https://entra.microsoft.com/#view/Microsoft_Azure_Network_Access/EditProfileMenuBlade.MenuView/~/basics/profileId/$profileId/title/$profileTitle/defaultMenuItemId/Basics"
                    "[$profileName]($profileLink)"
                }
                else {
                    'N/A'
                }

                # Check if profile has TI policy
                $profileHasTI = if ($linkedProfile) {
                    @($linkedProfile.policies | Where-Object {
                        $_.'@odata.type' -eq $THREAT_INTELLIGENCE_POLICY_LINK_TYPE -and
                        $_.policy.id -and $threatIntelPolicyIds.Contains($_.policy.id)
                    }).Count -gt 0
                }
                else {
                    $false
                }

                $profileTiLinks = if ($linkedProfile) {
                    @($linkedProfile.policies | Where-Object {
                        $_.'@odata.type' -eq $THREAT_INTELLIGENCE_POLICY_LINK_TYPE -and
                        $_.policy.id -and $threatIntelPolicyIds.Contains($_.policy.id)
                    })
                }
                else {
                    @()
                }

                $enabledProfileTiLinks = @($profileTiLinks | Where-Object { $_.state -eq 'enabled' })
                $policyLinkState = if ($enabledProfileTiLinks.Count -gt 0) {
                    'enabled'
                }
                elseif ($profileTiLinks.Count -gt 0) {
                    if ($profileTiLinks[0].state) { $profileTiLinks[0].state } else { 'N/A' }
                }
                else {
                    'N/A'
                }

                $profileHasTIDisplay = if ($profileHasTI) { '✅ Yes' } else { '❌ No' }

                $caPolicyLink = "https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/$caPolicyId"

                "| [$caPolicyName]($caPolicyLink) | $caPolicyState | $profileNameWithLink | $profileState | $profileHasTIDisplay | $policyLinkState |"
            }

            $table3Template = @'

## [{0}]({1})

| CA Policy Name | CA Policy State | Profile Name | Profile State | [Profile Has TI Policy]({3}) | Policy Link State |
| :------------- | :-------------- | :----------- | :------------ | :-------------------- | :---------------- |
{2}
'@

            $table3 = $table3Template -f $table3Title, $table3Link, ($table3Rows -join "`n"), $threatPolicyLink
        }
        else {
            $table3 = @"

## [$table3Title]($table3Link)

No Conditional Access policies with Global Secure Access session control found.
"@
        }

        $mdInfo += $table3
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
