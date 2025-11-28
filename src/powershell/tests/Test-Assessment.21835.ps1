<#
.SYNOPSIS
    Checks if emergency access accounts are configured appropriately

.DESCRIPTION
    This test identifies emergency access accounts based on:
    - Permanent Global Administrator role assignment (cloud-only)
    - Phishing-resistant authentication methods (FIDO2 and/or Certificate)
    - Exclusion from all enabled Conditional Access policies

    The test evaluates whether 2-4 emergency accounts are configured per Microsoft guidance.
#>

function Test-Assessment-21835 {
    [ZtTest(
    	Category = 'Application management',
    	ImplementationCost = 'High',
    	MinimumLicense = ('P1'),
    	Pillar = 'Identity',
    	RiskLevel = 'High',
    	SfiPillar = 'Protect engineering systems',
    	TenantType = ('Workforce'),
    	TestId = 21835,
    	Title = 'Emergency access accounts are configured appropriately',
    	UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose
    if ( -not (Get-ZtLicense EntraIDP1) ) {
        Add-ZtTestResultDetail -SkippedBecause NotLicensedEntraIDP1
        return
    }

    $activity = 'Checking emergency access accounts configuration'
    Write-ZtProgress -Activity $activity -Status 'Starting assessment'

    #region Step 1: Find permanent Global Administrator users
    Write-ZtProgress -Activity $activity -Status 'Finding Global Administrator role members'

    # Global Administrator role template ID: 62e90394-69f5-4237-9190-012177145e10
    $sql = @"
SELECT
    vr.principalId as id,
    vr.principalDisplayName as displayName,
    vr.userPrincipalName,
    vr.privilegeType,
    u.onPremisesSyncEnabled,
    vr."@odata.type"
FROM vwRole vr
LEFT JOIN "User" u ON vr.principalId = u.id
WHERE vr.roleDefinitionId = '62e90394-69f5-4237-9190-012177145e10'
    AND vr.privilegeType = 'Permanent'
    AND vr."@odata.type" = '#microsoft.graph.user'
"@

    $permanentGAUsers = @(Invoke-DatabaseQuery -Database $Database -Sql $sql)

    Write-PSFMessage "Total permanent GA users: $($permanentGAUsers.Count)" -Level Verbose

    #endregion

    #region Step 2: Find cloud-only GAs with phishing-resistant auth methods
    Write-ZtProgress -Activity $activity -Status 'Analyzing authentication methods'

    $emergencyAccountCandidates = @()

    foreach ($user in $permanentGAUsers) {
        # Only process cloud-only accounts (onPremisesSyncEnabled is null or false)
        if ($user.onPremisesSyncEnabled -ne $true) {
            Write-PSFMessage "Checking auth methods for cloud-only user: $($user.userPrincipalName)" -Level Verbose

            # Use Get-ZtUserAuthenticationMethod helper to get authentication methods
            $userAuthInfo = Get-ZtUserAuthenticationMethod -UserId $user.id
            $authMethods = $userAuthInfo.AuthenticationMethods

            if ($authMethods) {
                # Check if user has at least one phishing-resistant auth method (FIDO2 or Certificate)
                # Note: Passwords are always present and cannot be removed, but CA policies can enforce phishing-resistant MFA
                # fix for issue #579 - The logic now checks if users have at least one phishing-resistant authentication method (FIDO2 or Certificate) instead of requiring only those methods.
                # This resolves the issue where passwords auth method were causing all accounts to be filtered out.
                $hasPhishingResistant = $false
                $authMethodTypes = @()

                foreach ($method in $authMethods) {
                    $methodType = $method.'@odata.type'
                    $authMethodTypes += $methodType

                    # Check if this method is FIDO2 or Certificate
                    if ($methodType -eq '#microsoft.graph.fido2AuthenticationMethod' -or
                        $methodType -eq '#microsoft.graph.x509CertificateAuthenticationMethod') {
                        $hasPhishingResistant = $true
                    }
                }

                if ($hasPhishingResistant) {
                    # This is a candidate emergency account
                    $emergencyAccountCandidates += [PSCustomObject]@{
                        Id = $user.id
                        UserPrincipalName = $user.userPrincipalName
                        DisplayName = $user.displayName
                        OnPremisesSyncEnabled = $user.onPremisesSyncEnabled
                        AuthenticationMethods = $authMethodTypes
                        CAPoliciesTargeting = 0
                        ExcludedFromAllCA = $false
                    }

                    Write-PSFMessage "Candidate emergency account found: $($user.userPrincipalName)" -Level Verbose
                }
            }
        }
    }

    Write-PSFMessage "Emergency account candidates (cloud-only with phishing-resistant auth): $($emergencyAccountCandidates.Count)" -Level Verbose

    #endregion

    #region Step 3 & 4: Get CA policies and check if candidates are excluded from all
    Write-ZtProgress -Activity $activity -Status 'Analyzing Conditional Access policies'

    # Use Get-ZtConditionalAccessPolicy helper function
    $allCAPolicies = Get-ZtConditionalAccessPolicy
    $enabledCAPolicies = $allCAPolicies | Where-Object { $_.state -eq 'enabled' }

    Write-PSFMessage "Found $($enabledCAPolicies.Count) enabled CA policies" -Level Verbose

    $emergencyAccessAccounts = @()

    foreach ($candidate in $emergencyAccountCandidates) {
        Write-PSFMessage "Checking CA policy targeting for: $($candidate.UserPrincipalName)" -Level Verbose

        # Query 6: Get transitive group memberships
        $userGroups = Invoke-ZtGraphRequest -RelativeUri "users/$($candidate.Id)/transitiveMemberOf/microsoft.graph.group" `
            -Select 'id' -ApiVersion v1.0
        $userGroupIds = @($userGroups | Select-Object -ExpandProperty id)

        # Query 7: Get directory role memberships
        $userRoles = Invoke-ZtGraphRequest -RelativeUri "users/$($candidate.Id)/memberOf/microsoft.graph.directoryRole" `
            -Select 'id,roleTemplateId' -ApiVersion v1.0
        $userRoleIds = @($userRoles | Select-Object -ExpandProperty id)

        $policiesTargetingUser = 0
        $excludedFromAll = $true

        foreach ($policy in $enabledCAPolicies) {
            $isTargeted = $false

            # Check user includes/excludes
            $includeUsers = @($policy.conditions.users.includeUsers)
            $excludeUsers = @($policy.conditions.users.excludeUsers)

            # Check if user is explicitly included
            if ($includeUsers -contains 'All' -or $includeUsers -contains $candidate.Id) {
                $isTargeted = $true
            }

            # Check if user is excluded
            if ($excludeUsers -contains $candidate.Id) {
                $isTargeted = $false
            }

            # Check group includes/excludes if not already determined
            if (-not $isTargeted -and $userGroupIds.Count -gt 0) {
                $includeGroups = @($policy.conditions.users.includeGroups)
                $excludeGroups = @($policy.conditions.users.excludeGroups)

                foreach ($groupId in $userGroupIds) {
                    if ($includeGroups -contains $groupId) {
                        $isTargeted = $true
                    }
                    if ($excludeGroups -contains $groupId) {
                        $isTargeted = $false
                        break
                    }
                }
            }

            # Check role includes/excludes
            $includeRoles = @($policy.conditions.users.includeRoles)
            $excludeRoles = @($policy.conditions.users.excludeRoles)

            foreach ($roleId in $userRoleIds) {
                $role = $userRoles | Where-Object { $_.id -eq $roleId }
                if ($includeRoles -contains $role.roleTemplateId) {
                    $isTargeted = $true
                }
                if ($excludeRoles -contains $role.roleTemplateId) {
                    $isTargeted = $false
                    break
                }
            }

            if ($isTargeted) {
                $policiesTargetingUser++
                $excludedFromAll = $false
            }
        }

        $candidate.CAPoliciesTargeting = $policiesTargetingUser
        $candidate.ExcludedFromAllCA = $excludedFromAll

        if ($excludedFromAll) {
            $emergencyAccessAccounts += $candidate
            Write-PSFMessage "Emergency access account confirmed: $($candidate.UserPrincipalName)" -Level Verbose
        }
    }

    #endregion

    #region Step 5: Evaluate results and generate report
    Write-ZtProgress -Activity $activity -Status 'Generating results'

    $accountCount = $emergencyAccessAccounts.Count
    Write-PSFMessage "Total emergency access accounts identified: $accountCount" -Level Verbose

    # Determine pass/fail status
    $passed = $false
    $testResultMarkdown = ''

    if ($accountCount -lt 2) {
        $passed = $false
        $testResultMarkdown = "Fewer than two emergency access accounts were identified based on cloud-only state, registered phishing-resistant credentials and Conditional Access policy exclusions.`n`n"
    }
    elseif ($accountCount -ge 2 -and $accountCount -le 4) {
        $passed = $true
        $testResultMarkdown = "Emergency access accounts appear to be configured as per Microsoft guidance based on cloud-only state, registered phishing-resistant credentials and Conditional Access policy exclusions.`n`n"
    }
    else {
        $passed = $false
        $testResultMarkdown = "$accountCount emergency access accounts appear to be configured based on cloud-only state, registered phishing-resistant credentials and Conditional Access policy exclusions. Review these accounts to determine whether this volume is excessive for your organization.`n`n"
    }

    # Add summary information
    $testResultMarkdown += "**Summary:**`n"
    $testResultMarkdown += "- Total permanent Global Administrators: $($permanentGAUsers.Count)`n"
    $testResultMarkdown += "- Cloud-only GAs with phishing-resistant auth: $($emergencyAccountCandidates.Count)`n"
    $testResultMarkdown += "- Emergency access accounts (excluded from all CA): $accountCount`n"
    $testResultMarkdown += "- Enabled Conditional Access policies: $($enabledCAPolicies.Count)`n`n"

    # Add details table
    if ($emergencyAccessAccounts.Count -gt 0) {
        $testResultMarkdown += "## Emergency access accounts`n`n"
        $testResultMarkdown += "| Display name | UPN | Synced from on-premises | Authentication methods |`n"
        $testResultMarkdown += "| :----------- | :-- | :---------------------- | :--------------------- |`n"

        foreach ($account in $emergencyAccessAccounts) {
            $syncStatus = if ($account.onPremisesSyncEnabled -ne $true) { 'No' } else { 'Yes' }
            $authMethodDisplay = ($account.AuthenticationMethods | ForEach-Object {
                $_ -replace '#microsoft.graph.', '' -replace 'AuthenticationMethod', ''
            }) -join ', '

            $portalLink = "https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/overview/userId/$($account.Id)"

            $testResultMarkdown += "| $(Get-SafeMarkdown -Text $account.DisplayName) | [$(Get-SafeMarkdown -Text $account.UserPrincipalName)]($portalLink) | $syncStatus | $authMethodDisplay |`n"
        }
        $testResultMarkdown += "`n"
    }

    # Add comprehensive table of all permanent GA accounts
    if ($permanentGAUsers.Count -gt 0) {
        $testResultMarkdown += "## All permanent Global Administrators`n`n"
        $testResultMarkdown += "| Display name | UPN | Cloud only | All CA excluded | Phishing resistant auth |`n"
        $testResultMarkdown += "| :----------- | :-- | :--------: | :---------: | :---------------------: |`n"

        $userSummary = @()
        foreach ($user in $permanentGAUsers) {
            $portalLink = "https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/overview/userId/$($user.id)"

            # Check if cloud-only
            $isCloudOnly = ($user.onPremisesSyncEnabled -ne $true)
            $cloudOnlyEmoji = if ($isCloudOnly) { '✅' } else { '❌' }

            # Check if in emergency access accounts (excluded from all CA)
            $emergencyAccount = $emergencyAccessAccounts | Where-Object { $_.Id -eq $user.id }
            $caExcludedEmoji = if ($emergencyAccount) { '✅' } else { '❌' }

            # Check if has phishing-resistant auth only
            $candidate = $emergencyAccountCandidates | Where-Object { $_.Id -eq $user.id }
            $phishingResistantEmoji = if ($candidate) { '✅' } else { '❌' }

            $userSummary += [PSCustomObject]@{
                DisplayName = $user.displayName
                UserPrincipalName = $user.userPrincipalName
                CloudOnly = $cloudOnlyEmoji
                CAExcluded = $caExcludedEmoji
                PhishingResistant = $phishingResistantEmoji
            }
        }

        # show users that have passed every criteria first
        $userSummary = $userSummary | Sort-Object -Property CAExcluded, PhishingResistant, CloudOnly

        foreach ($user in $userSummary) {
            $testResultMarkdown += "| $(Get-SafeMarkdown -Text $user.DisplayName) | [$(Get-SafeMarkdown -Text $user.UserPrincipalName)]($portalLink) | $($user.CloudOnly) | $($user.CAExcluded) | $($user.PhishingResistant) |`n"
        }

        $testResultMarkdown += "`n"
    }

    #endregion

    Add-ZtTestResultDetail -TestId '21835' `
        -Status $passed `
        -Result $testResultMarkdown
}
