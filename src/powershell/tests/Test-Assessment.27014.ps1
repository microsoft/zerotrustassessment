<#
.SYNOPSIS
    Validates that internet-bound traffic is inspected across all Secure Web Gateway defense layers.

.DESCRIPTION
    This test verifies that all four SWG enforcement layers are configured, linked to the Baseline Profile
    or an active Security Profile, and enforced through Conditional Access where required:
    - URL Filtering: Web content filtering policies with webCategory, fqdn, or url rules
    - TLS Inspection: TLS inspection policies for encrypted traffic inspection
    - Threat Intelligence: Threat intelligence policies blocking known-malicious infrastructure
    - AI Gateway: Prompt protection policies governing interactions with generative AI services

    When any of these layers is missing, threat actors can exploit the gap to download tools,
    exfiltrate data, or maintain persistent C2 channels.

.NOTES
    Test ID: 27014
    Category: Global Secure Access
    Required APIs:
    - networkAccess/filteringProfiles (beta)
    - networkAccess/filteringPolicies (beta)
    - networkAccess/tlsInspectionPolicies (beta)
    - networkAccess/threatIntelligencePolicies (beta)
    - networkAccess/promptPolicies (beta)
    - identity/conditionalAccess/policies (beta)
#>

function Test-Assessment-27014 {
    [ZtTest(
        Category = 'Global Secure Access',
        ImplementationCost = 'Medium',
        MinimumLicense = ('Entra_Premium_Internet_Access'),
        Pillar = 'Network',
        RiskLevel = 'High',
        SfiPillar = 'Protect networks',
        TenantType = ('Workforce'),
        TestId = 27014,
        Title = 'Internet-bound traffic is inspected across all Secure Web Gateway defense layers',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    # Constants
    [int]$BASELINE_PROFILE_PRIORITY = 65000

    #region Data Collection
    Write-PSFMessage '🟦 Start SWG defense layers evaluation' -Tag Test -Level VeryVerbose

    $activity = 'Checking Secure Web Gateway enforcement layers'

    # Q1: Retrieve all filtering profiles with linked policies
    Write-ZtProgress -Activity $activity -Status 'Querying filtering profiles with linked policies'
    $filteringProfiles = Invoke-ZtGraphRequest -RelativeUri 'networkAccess/filteringProfiles' -QueryParameters @{
        '$select' = 'id,name,state,priority'
        '$expand' = 'policies($select=id,state;$expand=policy($select=id,name,version))'
    } -ApiVersion beta

    # Q2: Retrieve all filtering policies with rules (for URL filtering layer verification)
    Write-ZtProgress -Activity $activity -Status 'Querying filtering policies with rules'
    $filteringPolicies = Invoke-ZtGraphRequest -RelativeUri 'networkAccess/filteringPolicies' -QueryParameters @{
        '$select' = 'id,name,version'
        '$expand' = 'policyRules'
    } -ApiVersion beta

    # Q3: Retrieve TLS inspection policies
    Write-ZtProgress -Activity $activity -Status 'Querying TLS inspection policies'
    $tlsInspectionPolicies = Invoke-ZtGraphRequest -RelativeUri 'networkAccess/tlsInspectionPolicies' -ApiVersion beta

    # Q4: Retrieve threat intelligence policies
    Write-ZtProgress -Activity $activity -Status 'Querying threat intelligence policies'
    $threatIntelPolicies = Invoke-ZtGraphRequest -RelativeUri 'networkAccess/threatIntelligencePolicies' -ApiVersion beta

    # Q5: Retrieve Conditional Access policies
    Write-ZtProgress -Activity $activity -Status 'Querying Conditional Access policies'
    $caPolicies = Get-ZtConditionalAccessPolicy

    # Q6: Retrieve AI Gateway prompt policies
    Write-ZtProgress -Activity $activity -Status 'Querying prompt protection policies'
    $promptPolicies = Invoke-ZtGraphRequest -RelativeUri 'networkAccess/promptPolicies' -QueryParameters @{
        '$expand' = 'policyRules'
    } -ApiVersion beta

    #endregion Data Collection

    #region Assessment Logic
    Write-ZtProgress -Activity $activity -Status 'Evaluating enforcement layers'

    # Initialize layer status tracking using PSCustomObject for reliable property access
    $layerResults = @{
        'URL Filtering' = [PSCustomObject]@{
            Status = 'Missing'
            EnforcementMethod = 'None'
            ProfileName = $null
            ProfileId = $null
            PolicyName = $null
            RuleCount = 0
            CAPolicies = $null
            Note = $null
        }
        'TLS Inspection' = [PSCustomObject]@{
            Status = 'Missing'
            EnforcementMethod = 'None'
            ProfileName = $null
            ProfileId = $null
            PolicyName = $null
            RuleCount = 0
            CAPolicies = $null
            Note = $null
        }
        'Threat Intelligence' = [PSCustomObject]@{
            Status = 'Missing'
            EnforcementMethod = 'None'
            ProfileName = $null
            ProfileId = $null
            PolicyName = $null
            RuleCount = 0
            CAPolicies = $null
            Note = $null
        }
        'AI Gateway' = [PSCustomObject]@{
            Status = 'Missing'
            EnforcementMethod = 'None'
            ProfileName = $null
            ProfileId = $null
            PolicyName = $null
            RuleCount = 0
            CAPolicies = $null
            Note = $null
        }
    }

    # Helper function to check if a security profile has an enabled CA policy
    function Test-SecurityProfileEnforced {
        param(
            [string]$ProfileId,
            [object[]]$CAPolicies
        )
        if ($null -eq $CAPolicies) { return $null }

        $linkedCAPolicies = $CAPolicies | Where-Object {
            $_.sessionControls?.globalSecureAccessFilteringProfile?.profileId -eq $ProfileId -and
            $_.sessionControls?.globalSecureAccessFilteringProfile?.isEnabled -eq $true -and
            $_.state -eq 'enabled'
        }
        return $linkedCAPolicies
    }

    # Process filtering profiles to check all layers
    if ($null -ne $filteringProfiles -and $filteringProfiles.Count -gt 0) {
        foreach ($profile in $filteringProfiles) {
            $isBaseline = $profile.priority -eq $BASELINE_PROFILE_PRIORITY
            $profileEnabled = $profile.state -eq 'enabled'
            $profilePolicies = @($profile.policies)

            # Skip disabled profiles
            if (-not $profileEnabled) { continue }

            foreach ($policyLink in $profilePolicies) {
                $policyLinkEnabled = $policyLink.state -eq 'enabled'
                if (-not $policyLinkEnabled) { continue }

                $odataType = $policyLink.'@odata.type'
                $policyId = $policyLink.policy?.id
                $policyName = $policyLink.policy?.name

                # Determine enforcement method
                $enforcementMethod = 'None'
                $linkedCAPolicies = $null
                if ($isBaseline) {
                    $enforcementMethod = 'Baseline'
                }
                else {
                    $linkedCAPolicies = Test-SecurityProfileEnforced -ProfileId $profile.id -CAPolicies $caPolicies
                    if ($linkedCAPolicies -and @($linkedCAPolicies).Count -gt 0) {
                        $enforcementMethod = 'CA Policy'
                    }
                }

                # Only mark as active if enforced
                if ($enforcementMethod -eq 'None') { continue }

                # Check URL Filtering layer (filteringPolicyLink)
                if ($odataType -eq '#microsoft.graph.networkaccess.filteringPolicyLink') {
                    # Look up policy details from pre-fetched Q2 data
                    $policyDetails = $filteringPolicies | Where-Object { $_.id -eq $policyId }

                    $urlRules = @($policyDetails.policyRules) | Where-Object {
                        $_.ruleType -in @('webCategory', 'fqdn', 'url')
                    }

                    if ($urlRules.Count -gt 0) {
                        $currentLayer = $layerResults['URL Filtering']
                        if ($currentLayer.Status -eq 'Missing' -or
                            ($currentLayer.EnforcementMethod -ne 'Baseline' -and $enforcementMethod -eq 'Baseline')) {
                            $layerResults['URL Filtering'] = [PSCustomObject]@{
                                Status = 'Active'
                                EnforcementMethod = $enforcementMethod
                                ProfileName = $profile.name
                                ProfileId = $profile.id
                                PolicyName = $policyName
                                RuleCount = $urlRules.Count
                                CAPolicies = $linkedCAPolicies
                                Note = $null
                            }
                        }
                    }
                }

                # Check TLS Inspection layer
                if ($odataType -eq '#microsoft.graph.networkaccess.tlsInspectionPolicyLink') {
                    $currentLayer = $layerResults['TLS Inspection']
                    if ($currentLayer.Status -eq 'Missing' -or
                        ($currentLayer.EnforcementMethod -ne 'Baseline' -and $enforcementMethod -eq 'Baseline')) {
                        $layerResults['TLS Inspection'] = [PSCustomObject]@{
                            Status = 'Active'
                            EnforcementMethod = $enforcementMethod
                            ProfileName = $profile.name
                            ProfileId = $profile.id
                            PolicyName = $policyName
                            RuleCount = 0
                            CAPolicies = $linkedCAPolicies
                            Note = $null
                        }
                    }
                }

                # Check Threat Intelligence layer
                if ($odataType -eq '#microsoft.graph.networkaccess.threatIntelligencePolicyLink') {
                    $currentLayer = $layerResults['Threat Intelligence']
                    if ($currentLayer.Status -eq 'Missing' -or
                        ($currentLayer.EnforcementMethod -ne 'Baseline' -and $enforcementMethod -eq 'Baseline')) {
                        $layerResults['Threat Intelligence'] = [PSCustomObject]@{
                            Status = 'Active'
                            EnforcementMethod = $enforcementMethod
                            ProfileName = $profile.name
                            ProfileId = $profile.id
                            PolicyName = $policyName
                            RuleCount = 0
                            CAPolicies = $linkedCAPolicies
                            Note = $null
                        }
                    }
                }

                # Check AI Gateway layer (promptPolicyLink)
                if ($odataType -eq '#microsoft.graph.networkaccess.promptPolicyLink') {
                    $currentLayer = $layerResults['AI Gateway']
                    if ($currentLayer.Status -eq 'Missing' -or
                        ($currentLayer.EnforcementMethod -ne 'Baseline' -and $enforcementMethod -eq 'Baseline')) {
                        $layerResults['AI Gateway'] = [PSCustomObject]@{
                            Status = 'Active'
                            EnforcementMethod = $enforcementMethod
                            ProfileName = $profile.name
                            ProfileId = $profile.id
                            PolicyName = $policyName
                            RuleCount = 0
                            CAPolicies = $linkedCAPolicies
                            Note = $null
                        }
                    }
                }
            }
        }
    }

    # Additional validation: Verify TLS inspection policies exist (Q3)
    if ($layerResults['TLS Inspection'].Status -eq 'Active') {
        if ($null -eq $tlsInspectionPolicies -or $tlsInspectionPolicies.Count -eq 0) {
            $layerResults['TLS Inspection'] = [PSCustomObject]@{
                Status = 'Missing'
                EnforcementMethod = 'None'
                ProfileName = $null
                ProfileId = $null
                PolicyName = $null
                RuleCount = 0
                CAPolicies = $null
                Note = 'No TLS inspection policies found'
            }
        }
    }

    # Additional validation: Verify threat intelligence policy configuration (Q4)
    if ($layerResults['Threat Intelligence'].Status -eq 'Active') {
        if ($null -eq $threatIntelPolicies -or $threatIntelPolicies.Count -eq 0) {
            $layerResults['Threat Intelligence'] = [PSCustomObject]@{
                Status = 'Missing'
                EnforcementMethod = 'None'
                ProfileName = $null
                ProfileId = $null
                PolicyName = $null
                RuleCount = 0
                CAPolicies = $null
                Note = 'No threat intelligence policies found'
            }
        }
    }

    # Additional validation: Verify AI Gateway prompt policies exist and have enabled rules (Q6)
    if ($layerResults['AI Gateway'].Status -eq 'Missing') {
        # Check if prompt policies exist even if not linked to profiles
        if ($null -ne $promptPolicies -and $promptPolicies.Count -gt 0) {
            $hasEnabledRules = $false
            foreach ($policy in $promptPolicies) {
                $enabledRules = @($policy.policyRules) | Where-Object { $_.settings?.status -eq 'enabled' }
                if ($enabledRules.Count -gt 0) {
                    $hasEnabledRules = $true
                    break
                }
            }
            if ($hasEnabledRules) {
                $layerResults['AI Gateway'].Note = 'Prompt policies exist but are not linked to any profile'
            }
        }
    }
    elseif ($null -eq $promptPolicies -or $promptPolicies.Count -eq 0) {
        $layerResults['AI Gateway'] = [PSCustomObject]@{
            Status = 'Missing'
            EnforcementMethod = 'None'
            ProfileName = $null
            ProfileId = $null
            PolicyName = $null
            RuleCount = 0
            CAPolicies = $null
            Note = 'No prompt policies found'
        }
    }

    # Count active and missing layers
    $activeLayers = @($layerResults.Keys | Where-Object { $layerResults[$_].Status -eq 'Active' })
    $missingLayers = @($layerResults.Keys | Where-Object { $layerResults[$_].Status -eq 'Missing' })

    # Determine overall pass/fail
    $passed = $missingLayers.Count -eq 0

    #endregion Assessment Logic

    #region Report Generation
    $testResultMarkdown = ''
    $mdInfo = ''

    if ($passed) {
        $testResultMarkdown = "✅ All SWG enforcement layers (URL filtering, TLS inspection, threat intelligence, AI Gateway) are active and enforced through the Baseline Profile or Conditional Access-linked Security Profiles.`n`n%TestResult%"
    }
    else {
        $missingLayerList = $missingLayers -join ', '
        $testResultMarkdown = "❌ One or more SWG enforcement layers are missing or not enforced. Missing layers: $missingLayerList.`n`n%TestResult%"
    }

    # Build summary table
    $mdInfo += "## [SWG Enforcement Layer Analysis](https://entra.microsoft.com/#view/Microsoft_Azure_Network_Access/InternetAccess.ReactView)`n`n"

    $mdInfo += "| Enforcement Layer | Status | Enforcement Method | Profile Name |`n"
    $mdInfo += "| :---------------- | :----- | :----------------- | :----------- |`n"

    $layerOrder = @('URL Filtering', 'TLS Inspection', 'Threat Intelligence', 'AI Gateway')
    foreach ($layerName in $layerOrder) {
        $layer = $layerResults[$layerName]
        $statusIcon = if ($layer.Status -eq 'Active') { '✅ Active' } else { '❌ Missing' }
        $enforcementMethod = $layer.EnforcementMethod
        $profileName = if ($layer.ProfileName) {
            $profileLink = "https://entra.microsoft.com/#view/Microsoft_Azure_Network_Access/EditProfileMenuBlade.MenuView/~/basics/profileId/$($layer.ProfileId)"
            $safeProfileName = Get-SafeMarkdown -Text $layer.ProfileName
            "[$safeProfileName]($profileLink)"
        }
        else {
            'N/A'
        }

        $mdInfo += "| $layerName | $statusIcon | $enforcementMethod | $profileName |`n"
    }

    # Add details for active layers
    $activeLayersWithDetails = $layerOrder | Where-Object { $layerResults[$_].Status -eq 'Active' -and $layerResults[$_].PolicyName }

    if ($activeLayersWithDetails.Count -gt 0) {
        $mdInfo += "`n### Enforcement Details`n`n"

        foreach ($layerName in $activeLayersWithDetails) {
            $layer = $layerResults[$layerName]

            $mdInfo += "**$layerName**`n"

            if ($layer.PolicyName) {
                $mdInfo += "- Policy: $(Get-SafeMarkdown -Text $layer.PolicyName)`n"
            }
            if ($layer.RuleCount -gt 0) {
                $mdInfo += "- Active rules: $($layer.RuleCount)`n"
            }
            if ($layer.EnforcementMethod -eq 'CA Policy' -and $layer.CAPolicies) {
                $caNames = @($layer.CAPolicies | ForEach-Object {
                    $caPolicyLink = "https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/$($_.id)"
                    $safeName = Get-SafeMarkdown -Text $_.displayName
                    "[$safeName]($caPolicyLink)"
                }) -join ', '
                $mdInfo += "- Conditional Access: $caNames`n"
            }

            $mdInfo += "`n"
        }
    }

    # Add notes for missing layers
    $missingLayersWithNotes = $layerOrder | Where-Object {
        $layerResults[$_].Status -eq 'Missing' -and $layerResults[$_].Note
    }

    if ($missingLayersWithNotes.Count -gt 0) {
        $mdInfo += "`n### Notes`n`n"
        foreach ($layerName in $missingLayersWithNotes) {
            $note = $layerResults[$layerName].Note
            $mdInfo += "- **$layerName**: $note`n"
        }
    }

    # Add portal links for remediation
    $mdInfo += "`n### Configuration Links`n`n"
    $mdInfo += "- [Web Content Filtering](https://entra.microsoft.com/#view/Microsoft_Azure_Network_Access/WebFilteringPolicy.ReactView)`n"
    $mdInfo += "- [TLS Inspection](https://entra.microsoft.com/#view/Microsoft_Azure_Network_Access/TLSInspectionPolicy.ReactView)`n"
    $mdInfo += "- [Threat Intelligence](https://entra.microsoft.com/#view/Microsoft_Azure_Network_Access/ThreatProtection.ReactView)`n"
    $mdInfo += "- [AI Gateway / Prompt Shield](https://entra.microsoft.com/#view/Microsoft_Azure_Network_Access/PromptPolicy.ReactView)`n"

    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo

    #endregion Report Generation

    $params = @{
        TestId = '27014'
        Title  = 'Internet-bound traffic is inspected across all Secure Web Gateway defense layers'
        Status = $passed
        Result = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
