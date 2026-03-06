<#
.SYNOPSIS
    Sensitive data exfiltration through file transfers is prevented by network content filtering policies.
.DESCRIPTION
    Verifies that file policies are configured in Global Secure Access and enforced through filtering profiles.
    The test passes if file policies exist and are enforced either through the Baseline Profile or through
    Security Profiles assigned to Conditional Access policies.
#>

function Test-Assessment-25413 {
    [ZtTest(
        Category = 'Global Secure Access',
        ImplementationCost = 'High',
        MinimumLicense = ('Entra_Premium_Internet_Access'),
        Pillar = 'Network',
        RiskLevel = 'High',
        SfiPillar = 'Protect networks',
        TenantType = ('Workforce'),
        TestId = 25413,
        Title = 'Sensitive data exfiltration through file transfers is prevented by network content filtering policies',
        UserImpact = 'Medium'
    )]
    [CmdletBinding()]
    param()

    # Define constants
    [int]$BASELINE_PROFILE_PRIORITY = 65000

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking file policy configuration for data exfiltration prevention'
    Write-ZtProgress -Activity $activity -Status 'Querying file policies'

    # Step 1: Get file policies
    $filePolicies = Invoke-ZtGraphRequest -RelativeUri 'networkAccess/filePolicies' -ApiVersion beta

    # Step 2: Get filtering profiles with linked policies and CA policies
    Write-ZtProgress -Activity $activity -Status 'Querying filtering profiles and linked policies'
    $filteringProfiles = Invoke-ZtGraphRequest -RelativeUri 'networkAccess/filteringProfiles' -QueryParameters @{
        '$select' = 'id,name,description,state,version,priority'
        '$expand' = 'policies($select=id,state;$expand=policy($select=id,name,version)),conditionalAccessPolicies($select=id,displayName)'
    } -ApiVersion beta

    # Step 3: Get all Conditional Access policies
    Write-ZtProgress -Activity $activity -Status 'Querying Conditional Access policies'
    $allCAPolicies = Get-ZtConditionalAccessPolicy

    $enabledSecurityProfiles = @()
    $enabledBaselineProfiles = @()
    $allLinkedProfiles = @()

    foreach ($filePolicy in $filePolicies) {
        $findParams = @{
            PolicyId          = $filePolicy.id
            FilteringProfiles = $filteringProfiles
            CAPolicies        = $allCAPolicies
            BaselinePriority  = $BASELINE_PROFILE_PRIORITY
            PolicyLinkType    = 'filePolicyLink'
            PolicyRules       = $filePolicy
        }

        $linkedProfiles = Find-ZtProfilesLinkedToPolicy @findParams

        foreach ($profileLink in $linkedProfiles) {
            $allLinkedProfiles += [PSCustomObject]@{
                ProfileId       = $profileLink.ProfileId
                ProfileName     = $profileLink.ProfileName
                ProfileType     = $profileLink.ProfileType
                ProfileState    = $profileLink.ProfileState
                ProfilePriority = $profileLink.ProfilePriority
                PolicyLinkState = $profileLink.PolicyLinkState
                FilePolicyId    = $filePolicy.id
                FilePolicyName  = $filePolicy.name
                CAPolicy        = $profileLink.CAPolicy
            }

            if ($profileLink.ProfileType -eq 'Baseline Profile' -and $profileLink.PassesCriteria -and $profileLink.ProfileState -eq 'enabled') {
                $enabledBaselineProfiles += [PSCustomObject]@{
                    ProfileId           = $profileLink.ProfileId
                    ProfileName         = $profileLink.ProfileName
                    ProfileState        = $profileLink.ProfileState
                    ProfilePriority     = $profileLink.ProfilePriority
                    FilePolicyId        = $filePolicy.id
                    FilePolicyName      = $filePolicy.name
                    FilePolicyLinkState = $profileLink.PolicyLinkState
                }
            }
            elseif ($profileLink.ProfileType -eq 'Security Profile' -and $profileLink.PassesCriteria -and $profileLink.ProfileState -eq 'enabled') {
                $matchedCAPolicies = if ($null -ne $profileLink.CAPolicy) { @($profileLink.CAPolicy) } else { @() }

                $enabledSecurityProfiles += [PSCustomObject]@{
                    ProfileId           = $profileLink.ProfileId
                    ProfileName         = $profileLink.ProfileName
                    ProfileState        = $profileLink.ProfileState
                    ProfilePriority     = $profileLink.ProfilePriority
                    FilePolicyId        = $filePolicy.id
                    FilePolicyName      = $filePolicy.name
                    FilePolicyLinkState = $profileLink.PolicyLinkState
                    MatchedCAPolicies   = $matchedCAPolicies
                    CAPolicyCount       = $matchedCAPolicies.Count
                }
            }
        }
    }

    #endregion Data Collection

    #region Assessment Logic
    $testResultMarkdown = ''
    $passed = $false
    $mdInfo = ''
    $successMessage = @"
✅ File policies are configured and actively enforced through a filtering profile, protecting against data exfiltration through unmonitored file transfers.

%TestResult%
"@
    $hasEnabledProfiles = $enabledBaselineProfiles.Count -gt 0 -or $enabledSecurityProfiles.Count -gt 0

    if ($null -eq $filePolicies -or $filePolicies.Count -eq 0) {
        $testResultMarkdown = @"
❌ No file policy is configured. File transfers are unmonitored and the organization is exposed to data exfiltration risk.

%TestResult%
"@
        $passed = $false
    }
    elseif ($hasEnabledProfiles) {
        $testResultMarkdown = $successMessage
        $passed = $true
    }
    else {
        $testResultMarkdown = @"
❌ File policies are either not configured or not linked to an active filtering profile, leaving file transfers unmonitored and exposing the organization to data exfiltration risk.

%TestResult%
"@
        $passed = $false
    }

    #endregion Assessment Logic

    #region Report Generation

    # Table 1: File Policy Configuration (always shown when policies exist)
    if ($filePolicies -and $filePolicies.Count -gt 0) {
        $mdInfo += @"

## File Policy Configuration

| File Policy Name | File Policy ID | Default Action |
| :--- | :--- | :--- |
"@
        foreach ($fp in $filePolicies) {
            $fpPortalLink = 'https://entra.microsoft.com/#view/Microsoft_Azure_Network_Access/SecurityFiltering.ReactView'
            $fpName = Get-SafeMarkdown -Text $fp.name
            $defaultAction = if ($fp.settings -and $fp.settings.defaultAction) { $fp.settings.defaultAction } else { 'N/A' }
            $mdInfo += "| [$fpName]($fpPortalLink) | $($fp.id) | $defaultAction |`n"
        }
    }

    # Table 2: Baseline Profile linkages (all, not just passing)
    $baselineProfileLinks = @($allLinkedProfiles | Where-Object { $_.ProfileType -eq 'Baseline Profile' })
    if ($baselineProfileLinks.Count -gt 0) {
        $mdInfo += @"

## File Policies Linked to Baseline Profile

| Linked Profile Name | Linked Profile Priority | Linked File Policy Name | Policy Link State | Profile State |
| :--- | :--- | :--- | :--- | :--- |
"@
        foreach ($baselineProfile in $baselineProfileLinks) {
            $profilePortalLink = "https://entra.microsoft.com/#view/Microsoft_Azure_Network_Access/EditProfileMenuBlade.MenuView/~/basics/profileId/$($baselineProfile.ProfileId)"
            $profileName = Get-SafeMarkdown -Text $baselineProfile.ProfileName
            $filePolicyName = Get-SafeMarkdown -Text $baselineProfile.FilePolicyName
            $mdInfo += "| [$profileName]($profilePortalLink) | $($baselineProfile.ProfilePriority) | $filePolicyName | $($baselineProfile.PolicyLinkState) | $($baselineProfile.ProfileState) |`n"
        }
    }

    # Table 3: Security Profile linkages with CA enforcement (all, not just passing)
    $securityProfileLinks = @($allLinkedProfiles | Where-Object { $_.ProfileType -eq 'Security Profile' })
    if ($securityProfileLinks.Count -gt 0) {
        $mdInfo += @"

## Security Profiles Linked to Conditional Access Policies

| Linked Profile Name | Linked Profile Priority | CA Policy Names | CA Policy State | Profile State | File Policy Name |
| :--- | :--- | :--- | :--- | :--- | :--- |
"@
        foreach ($securityProfile in $securityProfileLinks) {
            $profilePortalLink = "https://entra.microsoft.com/#view/Microsoft_Azure_Network_Access/EditProfileMenuBlade.MenuView/~/basics/profileId/$($securityProfile.ProfileId)"
            $profileName = Get-SafeMarkdown -Text $securityProfile.ProfileName
            $filePolicyName = Get-SafeMarkdown -Text $securityProfile.FilePolicyName
            $caPolicyLinksMarkdown = @()
            $caPolicyStatesList = @()
            foreach ($caPolicy in @($securityProfile.CAPolicy)) {
                if ($null -ne $caPolicy) {
                    $caPolicyPortalLink = "https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/$($caPolicy.Id)"
                    $safeName = Get-SafeMarkdown -Text $caPolicy.DisplayName
                    $caPolicyLinksMarkdown += "[$safeName]($caPolicyPortalLink)"
                    $caPolicyStatesList += $caPolicy.State
                }
            }
            $caPolicyNamesLinked = if ($caPolicyLinksMarkdown.Count -gt 0) { $caPolicyLinksMarkdown -join ', ' } else { 'None' }
            $caPolicyStates = if ($caPolicyStatesList.Count -gt 0) { $caPolicyStatesList -join ', ' } else { 'N/A' }
            $mdInfo += "| [$profileName]($profilePortalLink) | $($securityProfile.ProfilePriority) | $caPolicyNamesLinked | $caPolicyStates | $($securityProfile.ProfileState) | $filePolicyName |`n"
        }
    }

    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo

    #endregion Report Generation

    $params = @{
        TestId = '25413'
        Status = $passed
        Result = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
