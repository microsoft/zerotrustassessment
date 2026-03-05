<#
.SYNOPSIS
    Checks if high-risk web content filtering categories (Criminal activity, Hacking, Illegal software) are blocked.

.DESCRIPTION
    This check evaluates whether Global Secure Access web content filtering policies block three
    high-risk Liability categories: Criminal activity, Hacking, and Illegal software. It validates
    that the blocking is effective through either the baseline profile or security profiles with
    active Conditional Access enforcement.

.NOTES
    Test ID: 27000
    Category: Global Secure Access
    Risk Level: High
#>

function Test-Assessment-27000 {
    [ZtTest(
        Category = 'Global Secure Access',
        ImplementationCost = 'Low',
        MinimumLicense = ('Entra_Premium_Internet_Access'),
        Pillar = 'Network',
        RiskLevel = 'High',
        SfiPillar = 'Protect networks',
        TenantType = ('Workforce'),
        TestId = 27000,
        Title = 'High-risk WCF categories (Criminal activity, Hacking, Illegal software) are blocked',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Helper Functions
    function New-FailedCategoryResults {
        <#
        .SYNOPSIS
            Creates failed category results when policies or profiles are missing.
        #>
        param(
            [Parameter(Mandatory)]
            [array]$RequiredCategories,

            [Parameter(Mandatory)]
            [hashtable]$CategoryDisplayNames
        )

        $results = @()
        foreach ($catName in $RequiredCategories) {
            $results += [PSCustomObject]@{
                Category   = $CategoryDisplayNames[$catName]
                EnforcedBy = 'None'
                CAEnforced = 'N/A'
                Status     = 'Not Blocked'
            }
        }
        return $results
    }
    #endregion Helper Functions

    #region Data Collection
    Write-PSFMessage '🟦 Start high-risk WCF category block evaluation' -Tag Test -Level VeryVerbose
    $activity = 'Checking high-risk WCF categories are blocked'

    $filteringPolicies = $null
    $filteringProfiles = $null
    $caPolicies = $null
    $errorMsg = $null

    try {
        # Q1: Get all filtering policies with policy rules
        Write-ZtProgress -Activity $activity -Status 'Getting filtering policies'
        $filteringPolicies = Invoke-ZtGraphRequest -RelativeUri 'networkAccess/filteringPolicies' -QueryParameters @{ '$expand' = 'policyRules' } -ApiVersion beta -ErrorAction Stop
        Write-PSFMessage "Found $($filteringPolicies.Count) filtering policies" -Level Verbose

        # Q2: Get all filtering profiles with expanded policies (following 25407 pattern)
        if ($filteringPolicies -and $filteringPolicies.Count -gt 0) {
            Write-ZtProgress -Activity $activity -Status 'Getting filtering profiles'
            $filteringProfiles = Invoke-ZtGraphRequest -RelativeUri 'networkAccess/filteringProfiles' -QueryParameters @{ '$expand' = 'policies($expand=policy)' } -ApiVersion beta -ErrorAction Stop
            Write-PSFMessage "Found $($filteringProfiles.Count) filtering profiles" -Level Verbose
        }

        # Q3: Get CA policies (following 25407 pattern)
        if ($filteringPolicies -and $filteringPolicies.Count -gt 0 -and
            $filteringProfiles -and $filteringProfiles.Count -gt 0) {
            Write-ZtProgress -Activity $activity -Status 'Getting Conditional Access policies'
            $caPolicies = Get-ZtConditionalAccessPolicy
        }
    }
    catch {
        $errorMsg = $_
        Write-PSFMessage "Failed to retrieve data: $_" -Level Error
    }
    #endregion Data Collection

    #region Assessment Logic
    # Required categories to check
    $requiredCategories = @('CriminalActivity', 'Hacking', 'IllegalSoftware')
    $categoryDisplayNames = @{
        'CriminalActivity' = 'Criminal activity'
        'Hacking'          = 'Hacking'
        'IllegalSoftware'  = 'Illegal software'
    }

    # Early validation: Check if we have the required data to proceed
    $passed = $false
    $categoryResults = @()

    if($errorMsg) {
        Write-PSFMessage "Error during data collection: $errorMsg" -Level Error
        $testResultMarkdown = "❌ Failed to retrieve necessary data for assessment.`n`nError: $errorMsg"
    }
    elseif(-not $filteringPolicies -or $filteringPolicies.Count -eq 0 ){
        Write-PSFMessage "No WCF policies found" -Level Warning
        $categoryResults = New-FailedCategoryResults -RequiredCategories $requiredCategories -CategoryDisplayNames $categoryDisplayNames
        $blockedCount = 0
        $notBlockedCount = $requiredCategories.Count
    }
    elseif (-not $filteringProfiles -or $filteringProfiles.Count -eq 0) {
        Write-PSFMessage "No filtering profiles found" -Level Warning
        $categoryResults = New-FailedCategoryResults -RequiredCategories $requiredCategories -CategoryDisplayNames $categoryDisplayNames
        $blockedCount = 0
        $notBlockedCount = $requiredCategories.Count
    }
    else {
        [int]$BASELINE_PROFILE_PRIORITY = 65000
        # Process CA policies to find those with enabled GSA security profiles (following 25407 pattern)
        $gsaPolicies = $caPolicies | Where-Object { ($_.state -eq 'enabled') -and ($null -ne $_.sessionControls.globalSecureAccessFilteringProfile) }
        $gsaPolicyDetails = @()

        foreach ($policy in $gsaPolicies) {
            $profileId = $policy.sessionControls.globalSecureAccessFilteringProfile.profileId
            $caLinkageEnabled = $policy.sessionControls.globalSecureAccessFilteringProfile.isEnabled
            $matchedProfile = $filteringProfiles | Where-Object { $_.id -eq $profileId }
            $gsaPolicyDetails += [PSCustomObject]@{
                PolicyId         = $policy.id
                PolicyDisplayName= $policy.displayName
                PolicyState      = $policy.state
                ProfileId        = $profileId
                CALinkageEnabled = $caLinkageEnabled
                ProfileName      = $matchedProfile.name
                ProfileState     = $matchedProfile.state
            }
        }

        # Build CA enforcement map: profileId -> has active CA enforcement
        $caEnforcementMap = @{}
        $caPolicyWithGsaProfilesEnabled = $gsaPolicyDetails | Where-Object { $_.ProfileState -eq 'enabled' -and $_.CALinkageEnabled -eq $true }
        foreach ($item in $caPolicyWithGsaProfilesEnabled) {
            $caEnforcementMap[$item.ProfileId] = $true
        }

        # Evaluate each category
        foreach ($catName in $requiredCategories) {
            $catDisplay = $categoryDisplayNames[$catName]

            # Find all policies that cover this category using filtering
            $policiesCoveringCategory = @($filteringPolicies | Where-Object {
                $policy = $_
                $webCatRules = @($policy.policyRules | Where-Object { $_.ruleType -eq 'webCategory' })
                $webCatRules | Where-Object {
                    $_.destinations | Where-Object { $_.name -eq $catName }
                }
            })

            # Find all profiles linked to these policies using Find-ZtProfilesLinkedToPolicy
            $profileCandidates = @()
            foreach ($policy in $policiesCoveringCategory) {
                $findParams = @{
                    PolicyId          = $policy.id
                    FilteringProfiles = $filteringProfiles
                    CAPolicies        = $caPolicies
                    BaselinePriority  = $BASELINE_PROFILE_PRIORITY
                    PolicyLinkType    = 'filteringPolicyLink'
                    PolicyRules       = @($policy.policyRules)
                }
                $linkedProfiles = Find-ZtProfilesLinkedToPolicy @findParams

                # For each linked profile, get the policy link priority and action
                foreach ($linkedProfile in $linkedProfiles) {
                    $filteringProfile = $filteringProfiles | Where-Object { $_.id -eq $linkedProfile.ProfileId }
                    if (-not $filteringProfile -or $filteringProfile.state -ne 'enabled') { continue }

                    # Find the policy link and get its priority and action from the expanded policy
                    foreach ($policyLink in $filteringProfile.policies) {
                        if ($policyLink.policy.id -ne $policy.id) { continue }

                        # Skip disabled policy links
                        if ($policyLink.state -ne 'enabled') {
                            Write-PSFMessage "Skipping disabled policy link in profile '$($filteringProfile.name)' for policy '$($policy.name)'" -Level Verbose
                            continue
                        }

                        $linkPriority = try { [int]$policyLink.priority } catch { [int]::MaxValue }

                        # Get action from the expanded policy object
                        $linkAction = if ($policyLink.policy.action) {
                            $policyLink.policy.action.ToString().ToLower()
                        }
                        else {
                            # Default to block for WCF policies
                            'block'
                        }

                        $profileCandidates += [PSCustomObject]@{
                            ProfileId      = $linkedProfile.ProfileId
                            ProfileName    = $linkedProfile.ProfileName
                            ProfilePriority= $linkedProfile.ProfilePriority
                            IsBaseline     = ($linkedProfile.ProfileType -eq 'Baseline Profile')
                            PolicyAction   = $linkAction
                            PolicyPriority = $linkPriority
                            PassesCriteria = $linkedProfile.PassesCriteria
                        }
                    }
                }
            }

            # Sort by profile priority, then policy priority
            $profileCandidates = @($profileCandidates | Sort-Object ProfilePriority, PolicyPriority)

            # Find effective profile per spec logic
            $effectiveProfileName = 'None'
            $caEnforced = 'N/A'  # Default to N/A when no profile found
            $status = 'Not blocked'

            foreach ($pc in $profileCandidates) {
                if ($pc.IsBaseline) {
                    # Baseline profile is always effective
                    $effectiveProfileName = $pc.ProfileName
                    $caEnforced = 'N/A'
                    $status = if ($pc.PolicyAction -eq 'block') { 'Blocked' } else { 'Not blocked' }
                    break
                }
                else {
                    # Security profile - check if it passes CA enforcement criteria
                    if ($pc.PassesCriteria) {
                        $effectiveProfileName = $pc.ProfileName
                        $caEnforced = 'Yes'
                        $status = if ($pc.PolicyAction -eq 'block') { 'Blocked' } else { 'Not blocked' }
                        break
                    }
                }
            }

            $categoryResults += [PSCustomObject]@{
                Category   = $catDisplay
                EnforcedBy = $effectiveProfileName
                CAEnforced = $caEnforced
                Status     = $status
            }
        }

        # Determine pass/fail
        $blockedCount = @($categoryResults | Where-Object { $_.Status -eq 'Blocked' }).Count
        $notBlockedCount = $requiredCategories.Count - $blockedCount
        $passed = $blockedCount -eq $requiredCategories.Count
    }


    #endregion Assessment Logic

    #region Report Generation
    # Only generate full report if we have category results
    if ($errorMsg) {
        # Error message already set, no table needed
    }
    else {
        if ($passed) {
            $testResultMarkdown = "✅ High-risk web content filtering categories (Criminal activity, Hacking, Illegal software) are blocked across enabled security profiles, protecting users from liability risks and malicious content.`n`n%TestResult%"
        }
        else {
            $testResultMarkdown = "❌ One or more high-risk web content filtering categories (Criminal activity, Hacking, Illegal software) are not blocked. Configure web content filtering policies to block these Liability categories to protect against security risks and policy violations.`n`n%TestResult%"
        }

        $reportTitle = 'Web Content Filtering – Category block status'
        $portalLink = 'https://entra.microsoft.com/#view/Microsoft_Azure_Network_Access/WebFilteringPolicy.ReactView'

        # Build table with exactly 4 columns as per spec
        $tableRows = ''
        foreach ($row in $categoryResults) {
            $categoryName = Get-SafeMarkdown -Text $row.Category
            $enforcedBy = Get-SafeMarkdown -Text $row.EnforcedBy
            $statusIcon = if ($row.Status -eq 'Blocked') { '✅ Blocked' } else { '❌ Not blocked' }

            $tableRows += "| $categoryName | $enforcedBy | $($row.CAEnforced) | $statusIcon |`n"
        }

        $formatTemplate = @'

## [{0}]({1})

| Category | Enforced by | CA enforced | Status |
| :------- | :---------- | :---------- | :----- |
{2}

**Summary:**
- Total required categories: {3}
- Categories blocked: {4}
- Categories not blocked: {5}
'@

        $mdInfo = $formatTemplate -f $reportTitle, $portalLink, $tableRows, $requiredCategories.Count, $blockedCount, $notBlockedCount
        $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    }
    #endregion Report Generation

    $params = @{
        TestId = '27000'
        Title  = 'High-risk WCF categories (Criminal activity, Hacking, Illegal software) are blocked'
        Status = $passed
        Result = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
