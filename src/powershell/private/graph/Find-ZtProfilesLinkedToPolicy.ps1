function Find-ZtProfilesLinkedToPolicy {
    <#
    .SYNOPSIS
        Finds filtering profiles that are linked to a specific policy and evaluates if they meet pass criteria.

    .DESCRIPTION
        This function searches through Global Secure Access filtering profiles to find those linked to a specific policy.
        It evaluates whether each linked profile meets the pass criteria based on profile type:
        - Baseline Profile (priority = 65000): Passes automatically regardless of link state
        - Security Profile (priority < 65000): Passes only if linked to an enabled Conditional Access policy

    .PARAMETER PolicyId
        The ID of the filtering policy to search for.

    .PARAMETER FilteringProfiles
        Collection of all filtering profiles to search through.

    .PARAMETER CAPolicies
        Collection of Conditional Access policies for Security Profile validation.

    .PARAMETER BaselinePriority
        The priority value that identifies the Baseline Profile (typically 65000).

    .PARAMETER PolicyLinkType
        The type of policy link to search for. Valid values:
        - filteringPolicyLink (Web Content Filtering)
        - tlsInspectionPolicyLink (TLS Inspection)
        - filePolicyLink (File Policy)
        - promptPolicyLink (Prompt Policy)

    .PARAMETER PolicyRules
        Collection of policy rules associated with the policy (e.g., webCategory rules, TLS inspection rules).

    .EXAMPLE
        $findParams = @{
            PolicyId          = $policyId
            FilteringProfiles = $filteringProfiles
            CAPolicies        = $caPolicies
            BaselinePriority  = 65000
            PolicyLinkType    = 'filteringPolicyLink'
            PolicyRules       = $webCategoryRules
        }
        $linkedProfiles = Find-ZtProfilesLinkedToPolicy @findParams

    .OUTPUTS
        Array of PSCustomObject with the following properties:
        - ProfileId: The profile ID
        - ProfileName: The profile name
        - ProfileType: 'Baseline Profile' or 'Security Profile'
        - ProfileState: The profile state
        - ProfilePriority: The profile priority value
        - PolicyLinkState: The state of the policy link (enabled/disabled/unknown)
        - PassesCriteria: Boolean indicating if the profile meets pass criteria
        - CAPolicy: Linked Conditional Access policies (for Security Profiles only)
        - PolicyRules: The policy rules passed in

    .NOTES
        This function is used by Global Secure Access assessment tests to evaluate policy enforcement.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$PolicyId,

        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [object[]]$FilteringProfiles,

        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [object[]]$CAPolicies,

        [Parameter(Mandatory)]
        [int]$BaselinePriority,

        [Parameter(Mandatory)]
        [ValidateSet('filteringPolicyLink', 'tlsInspectionPolicyLink', 'filePolicyLink', 'promptPolicyLink')]
        [string]$PolicyLinkType,

        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [object[]]$PolicyRules
    )

    # OData type lookup for type safety
    $odataTypeMap = @{
        'filteringPolicyLink'     = '#microsoft.graph.networkaccess.filteringPolicyLink'
        'tlsInspectionPolicyLink' = '#microsoft.graph.networkaccess.tlsInspectionPolicyLink'
        'filePolicyLink'          = '#microsoft.graph.networkaccess.filePolicyLink'
        'promptPolicyLink'        = '#microsoft.graph.networkaccess.promptPolicyLink'
    }

    $odataType = $odataTypeMap[$PolicyLinkType]
    if (-not $odataType) {
        Write-PSFMessage "Unknown PolicyLinkType: $PolicyLinkType" -Tag Test -Level Warning
        return @()
    }

    $linkedProfiles = [System.Collections.Generic.List[PSCustomObject]]::new()

    foreach ($filteringProfile in $FilteringProfiles) {
        # Get profile policies safely
        $profilePolicies = @()
        if ($null -ne $filteringProfile.policies) {
            # Force array to handle both scalar and array returns from Graph API
            $profilePolicies = @($filteringProfile.policies)
        }

        foreach ($policyLink in $profilePolicies) {
            $plinkType = $policyLink.'@odata.type'
            $linkedPolicyId = $null

            # Only process the specified policy link type
            if ($plinkType -eq $odataType -and $null -ne $policyLink.policy) {
                $linkedPolicyId = $policyLink.policy.id
            }

            if ($null -ne $linkedPolicyId -and $linkedPolicyId -eq $PolicyId) {
                # Determine profile type based on priority
                $priority = if ($null -ne $filteringProfile.priority) {
                    [int]$filteringProfile.priority
                }
                else {
                    $null
                }

                # Per spec: Only process Baseline Profile (priority = 65000) or Security Profile (priority < 65000)
                if ($null -eq $priority) {
                    Write-PSFMessage "Skipping profile '$($filteringProfile.name)' (ID: $($filteringProfile.id)) - missing priority property" -Tag Test -Level Debug
                    continue
                }

                $linkState = if ($null -ne $policyLink.state) {
                    $policyLink.state
                }
                else {
                    'unknown'
                }

                if ($priority -eq $BaselinePriority) {
                    # Baseline Profile: passes regardless of enabled state per spec
                    $profileInfo = [PSCustomObject]@{
                        ProfileId      = $filteringProfile.id
                        ProfileName    = $filteringProfile.name
                        ProfileType    = 'Baseline Profile'
                        ProfileState   = $filteringProfile.state
                        ProfilePriority = $priority
                        PolicyLinkState = $linkState
                        PassesCriteria = $true
                        CAPolicy       = $null
                        PolicyRules    = $PolicyRules
                    }
                    $linkedProfiles.Add($profileInfo) | Out-Null
                }
                elseif ($priority -lt $BaselinePriority) {
                    # Security Profile: check if linked to enabled CA policy
                    $linkedCAPolicies = $CAPolicies | Where-Object {
                        # Use null-conditional operator for safe navigation
                        $_.sessionControls?.globalSecureAccessFilteringProfile?.profileId -eq $filteringProfile.id -and
                        $_.sessionControls?.globalSecureAccessFilteringProfile?.isEnabled -eq $true
                    }

                    $profileInfo = [PSCustomObject]@{
                        ProfileId      = $filteringProfile.id
                        ProfileName    = $filteringProfile.name
                        ProfileType    = 'Security Profile'
                        ProfileState   = $filteringProfile.state
                        ProfilePriority = $priority
                        PolicyLinkState = $linkState
                        PassesCriteria = $false
                        CAPolicy       = $null
                        PolicyRules    = $PolicyRules
                    }

                    if ($linkedCAPolicies) {
                        # Check if at least one CA policy is enabled
                        $enabledCAPolicies = $linkedCAPolicies | Where-Object { $_.state -eq 'enabled' }
                        if ($enabledCAPolicies) {
                            $profileInfo.PassesCriteria = $true
                        }
                        $profileInfo.CAPolicy = $linkedCAPolicies
                    }

                    $linkedProfiles.Add($profileInfo) | Out-Null
                }
                else {
                    # Priority > BaselinePriority
                    Write-PSFMessage "Skipping profile '$($filteringProfile.name)' (ID: $($filteringProfile.id)) - unexpected priority value: $priority (expected <= $BaselinePriority)" -Tag Test -Level Debug
                }
            }
        }
    }

    return $linkedProfiles
}
