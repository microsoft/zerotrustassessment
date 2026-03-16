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

    # Collect all linked profiles
    $allLinkedProfiles = @()
    foreach ($filePolicy in $filePolicies) {
        $linkedProfiles = Find-ZtProfilesLinkedToPolicy -PolicyId $filePolicy.id -FilteringProfiles $filteringProfiles -CAPolicies $allCAPolicies -BaselinePriority $BASELINE_PROFILE_PRIORITY -PolicyLinkType 'filePolicyLink' -PolicyRules $filePolicy

        foreach ($profileLink in $linkedProfiles) {
            $allLinkedProfiles += [PSCustomObject]@{
                ProfileId       = $profileLink.ProfileId
                ProfileName     = $profileLink.ProfileName
                ProfileType     = $profileLink.ProfileType
                ProfileState    = $profileLink.ProfileState
                ProfilePriority = $profileLink.ProfilePriority
                PolicyLinkState = $profileLink.PolicyLinkState
                PassesCriteria  = $profileLink.PassesCriteria
                CAPolicy        = $profileLink.CAPolicy
            }
        }
    }

    #endregion Data Collection

    #region Assessment Logic
    # Pass if any profile passes criteria (enabled baseline OR enabled security profile with CA)
    $passed = ($allLinkedProfiles | Where-Object { $_.PassesCriteria -and $_.ProfileState -eq 'enabled' -and $_.PolicyLinkState -eq 'enabled' }).Count -gt 0

    $successMessage = @"
✅ File policies are configured and actively enforced through a filtering profile, protecting against data exfiltration through unmonitored file transfers.

%TestResult%
"@

    if ($null -eq $filePolicies -or $filePolicies.Count -eq 0) {
        $testResultMarkdown = "❌ No file policy is configured. File transfers are unmonitored and the organization is exposed to data exfiltration risk.`n`n%TestResult%"
    }
    elseif ($passed) {
        $testResultMarkdown = $successMessage
    }
    else {
        $testResultMarkdown = "❌ File policies are either not configured or not linked to an active filtering profile, leaving file transfers unmonitored and exposing the organization to data exfiltration risk.`n`n%TestResult%"
    }

    #endregion Assessment Logic

    #region Report Generation
    $mdInfo = ''

    # Table 1: File Policy Configuration
    if ($filePolicies -and $filePolicies.Count -gt 0) {
        $table1Title = 'File Policy Configuration'
        $table1Link = 'https://entra.microsoft.com/#view/Microsoft_Azure_Network_Access/SecurityFiltering.ReactView'

        $table1Template = @'

## [{0}]({1})

| File Policy Name | File Policy ID | Default Action |
| :--------------- | :------------- | :------------- |
{2}
'@

        $table1Rows = ''
        foreach ($fp in $filePolicies) {
            $fpName = Get-SafeMarkdown -Text $fp.name
            $defaultAction = if ($fp.settings.defaultAction) { $fp.settings.defaultAction } else { 'N/A' }
            $fpLink = "https://entra.microsoft.com/#view/Microsoft_Azure_Network_Access/EditFilePolicyMenuBlade.MenuView/~/basics/policyId/$($fp.id)"
            $table1Rows += "| [$fpName]($fpLink) | $($fp.id) | $defaultAction |`n"
        }

        $mdInfo += $table1Template -f $table1Title, $table1Link, $table1Rows
    }

    # Table 2: Filtering Profile Linkage (unified - baseline and security profiles)
    if ($allLinkedProfiles.Count -gt 0) {
        $table2Title = 'Filtering Profile Linkage'
        $table2Link = 'https://entra.microsoft.com/#view/Microsoft_Azure_Network_Access/SecurityProfiles.ReactView'

        $table2Template = @'

## [{0}]({1})

| Linked Profile Name | Profile ID | Profile State | Policy Link State |
| :------------------ | :--------- | :------------ | :---------------- |
{2}
'@

        $table2Rows = ''
        foreach ($profile in ($allLinkedProfiles | Sort-Object -Property ProfilePriority)) {
            $profileLink = "https://entra.microsoft.com/#view/Microsoft_Azure_Network_Access/EditProfileMenuBlade.MenuView/~/basics/profileId/$($profile.ProfileId)"
            $profileName = Get-SafeMarkdown -Text $profile.ProfileName
            $table2Rows += "| [$profileName]($profileLink) | $($profile.ProfileId) | $($profile.ProfileState) | $($profile.PolicyLinkState) |`n"
        }

        $mdInfo += $table2Template -f $table2Title, $table2Link, $table2Rows
    }

    # Table 3: Conditional Access Enforcement
    $caPoliciesForReport = @($allLinkedProfiles.CAPolicy | Where-Object { $_ -ne $null } | Sort-Object -Property Id -Unique)

    if ($caPoliciesForReport.Count -gt 0) {
        $table3Title = 'Conditional Access Enforcement'
        $table3Link = 'https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/ConditionalAccessBlade/~/Policies'

        $table3Template = @'

## [{0}]({1})

| CA Policy Name | CA Policy ID | CA Policy State |
| :------------- | :----------- | :-------------- |
{2}
'@

        $table3Rows = ''
        foreach ($ca in ($caPoliciesForReport | Sort-Object -Property DisplayName)) {
            $caLink = "https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/$($ca.Id)"
            $caName = Get-SafeMarkdown -Text $ca.DisplayName
            $table3Rows += "| [$caName]($caLink) | $($ca.Id) | $($ca.State) |`n"
        }

        $mdInfo += $table3Template -f $table3Title, $table3Link, $table3Rows
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
