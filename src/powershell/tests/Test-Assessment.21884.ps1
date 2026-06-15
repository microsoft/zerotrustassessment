    <#
.SYNOPSIS
    Tests if workload identities are protected by location-based Conditional Access policies.
#>

function Test-Assessment-21884 {
    [ZtTest(
    	Category = 'External collaboration',
    	ImplementationCost = 'Medium',
    	MinimumLicense = ('P1'),
    	Pillar = 'Identity',
    	RiskLevel = 'High',
    	SfiPillar = 'Protect tenants and production systems',
    	TenantType = ('Workforce','External'),
    	TestId = 21884,
    	Title = 'Conditional Access policies for workload identities based on known networks are configured',
    	UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param(
        $Database
    )

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose
    if ( -not (Get-ZtLicense EntraIDP1) ) {
        Add-ZtTestResultDetail -SkippedBecause NotLicensedEntraIDP1
        return
    }

    if ( -not (Get-ZtLicense EntraWorkloadID) ) {
        Add-ZtTestResultDetail -SkippedBecause NotLicensedEntraWorkloadID
        return
    }

    $activity = 'Checking if workload identities are protected by location-based Conditional Access policies'
    Write-ZtProgress -Activity $activity -Status 'Getting service principals'

    # Get current tenant ID from context
    $tenantId = (Get-MgContext).TenantId

    # Q1: Get all service principals with credentials from database (filter in SQL)
    $sqlServicePrincipals = @"
    SELECT
        id,
        appId,
        displayName,
        servicePrincipalType,
        passwordCredentials,
        keyCredentials,
        appOwnerOrganizationId
    FROM ServicePrincipal
    WHERE servicePrincipalType = 'Application'
        AND cast(appOwnerOrganizationId as varchar) = '$tenantId'
        AND ((passwordCredentials IS NOT NULL AND passwordCredentials <> '[]')
             OR (keyCredentials IS NOT NULL AND keyCredentials <> '[]')
             OR appId IN (
                SELECT appId FROM Application
                WHERE signInAudience = 'AzureADMyOrg'
                  AND ((passwordCredentials IS NOT NULL AND passwordCredentials <> '[]')
                       OR (keyCredentials IS NOT NULL AND keyCredentials <> '[]'))
             )
        )
    LIMIT 1001
"@

    $servicePrincipalsWithCreds = Invoke-DatabaseQuery -Database $Database -Sql $sqlServicePrincipals

    if ($servicePrincipalsWithCreds.Count -eq 0) {
        $testResultMarkdown = 'No workload identities with credentials found to evaluate. All are compliant.'
        $params = @{
            TestId = '21884'
            Status = $true
            Result = $testResultMarkdown
        }
        Add-ZtTestResultDetail @params
        return
    }

    $spLimit = 1000
    $spTruncated = $false
    if ($servicePrincipalsWithCreds.Count -gt $spLimit) {
        $servicePrincipalsWithCreds = $servicePrincipalsWithCreds[0..($spLimit-1)]
        $spTruncated = $true
    }

    # Q4: Get all CA policies targeting workload identities from Graph API (fetch once)
    $policies = Invoke-ZtGraphRequest -RelativeUri 'identity/conditionalAccess/policies' -ApiVersion 'beta'

    # Check for a global policy that covers all service principals
    $allSpPolicy = $policies | Where-Object {
        $_.state -eq 'enabled' -and
        $_.conditions.clientApplications.includeServicePrincipals -contains 'ServicePrincipalsInMyTenant' -and
        (-not $_.conditions.clientApplications.excludeServicePrincipals)
    }

    if ($allSpPolicy) {
        # Verify location conditions in the global policy (no extra API call needed)
        $hasValidLocations = $false
        foreach ($policy in $allSpPolicy) {
            if ($policy.conditions.locations.includeLocations -or $policy.conditions.locations.excludeLocations) {
                $hasValidLocations = $true
                break
            }
        }

        if ($hasValidLocations) {
            $testResultMarkdown = 'All workload identities are protected by global service principal policies with location restrictions.'
            $params = @{
                TestId = '21884'
                Status = [bool]$true
                Result = $testResultMarkdown
            }
            Add-ZtTestResultDetail @params
            return
        }
    }

    if ($servicePrincipalsWithCreds.Count -gt 0 -and $policies.Count -eq 0) {
        $unprotectedSPs = @()
        foreach ($sp in $servicePrincipalsWithCreds) {
            $credTypes = @()
            if (($sp.passwordCredentials -ne '[]') -and ($null -ne $sp.passwordCredentials)) { $credTypes += 'Password' }
            if (($sp.keyCredentials -ne '[]') -and ($null -ne $sp.keyCredentials)) { $credTypes += 'Certificate' }
            $spPortalLink = "[$($sp.displayName)](https://portal.azure.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/$($sp.id)/appId/$($sp.appId))"
            $unprotectedSPs += @{ PortalLink = $spPortalLink; CredentialTypes = $credTypes -join ', '; AppliedPolicies = 'None'; LocationRestrictions = 'None' }
        }
        $passed = $false
        $testResultMarkdown = "Found workload identities with credentials that lack network-based access restrictions."
        $testResultMarkdown += "`n`n| Service principal display name | Credential type | Applied policy names | Location restrictions |"
        $testResultMarkdown += "`n|-------------------------------|-----------------|---------------------|---------------------|"
        foreach ($sp in $unprotectedSPs) {
            $testResultMarkdown += "`n| $($sp.PortalLink) | $($sp.CredentialTypes) | $($sp.AppliedPolicies) | $($sp.LocationRestrictions) |"
        }
        if ($spTruncated) {
            $testResultMarkdown += "`n\n_Note: Only the first 1000 service principals are shown._"
        }
        $params = @{
            TestId = '21884'
            Status = $passed
            Result = $testResultMarkdown
        }
        Add-ZtTestResultDetail @params
        return
    }

        # Q6: Get named locations from Graph API (not stored in database)
        $namedLocations = Invoke-ZtGraphRequest -RelativeUri 'identity/conditionalAccess/namedLocations' -ApiVersion 'beta'

        if ($namedLocations.Count -eq 0) {
            $testResultMarkdown = 'No named locations found. Cannot implement network-based restrictions without defined locations.'

            $params = @{
                TestId = '21884'
                Status = [bool]$false
                Result = $testResultMarkdown
            }
            Add-ZtTestResultDetail @params
            return
        }

    $unprotectedSPs = @()
    $protectedSPs = @()

    foreach ($sp in $servicePrincipalsWithCreds) {
        $credTypes = @()
        if (($sp.passwordCredentials -ne '[]') -and ($null -ne $sp.passwordCredentials)) { $credTypes += 'Password' }
        if (($sp.keyCredentials -ne '[]') -and ($null -ne $sp.keyCredentials)) { $credTypes += 'Certificate' }

        $appliedPolicies = @()
        $locationRestrictions = @()
        $isProtected = $false

        # Check each policy for this SP (all policy data is local)
        foreach ($policy in $policies) {
            if ($policy.state -eq 'enabled') {
                $policyApplies = $false
                $hasLocationRestriction = $false
                $locationDetails = ""

                # Check if policy applies to this service principal
                if ($policy.conditions.clientApplications.includeServicePrincipals -contains 'ServicePrincipalsInMyTenant' -and
                    (-not $policy.conditions.clientApplications.excludeServicePrincipals)) {
                    $policyApplies = $true
                    $appliedPolicies += "$($policy.displayName) (Global - covers ServicePrincipalsInMyTenant)"
                } elseif ($policy.conditions.clientApplications.includeServicePrincipals -contains $sp.id) {
                    $policyApplies = $true
                    $appliedPolicies += $policy.displayName
                }

                # Check location conditions if policy applies
                if ($policyApplies) {
                    if ($policy.conditions.locations.includeLocations -or $policy.conditions.locations.excludeLocations) {
                        $hasLocationRestriction = $true

                        # Build location details
                        $locationParts = @()
                        if ($policy.conditions.locations.includeLocations) {
                            $includeLocations = $policy.conditions.locations.includeLocations
                            if ($includeLocations -contains 'All') {
                                $locationParts += 'Include: All Locations'
                            } else {
                                $locationNames = @()
                                foreach ($locId in $includeLocations) {
                                    $location = $namedLocations | Where-Object { $_.id -eq $locId }
                                    if ($location) {
                                        $locationNames += $location.displayName
                                    } else {
                                        $locationNames += $locId
                                    }
                                }
                                $locationParts += "Include: $($locationNames -join ', ')"
                            }
                        }
                        if ($policy.conditions.locations.excludeLocations) {
                            $excludeLocations = $policy.conditions.locations.excludeLocations
                            if ($excludeLocations -contains 'All') {
                                $locationParts += 'Exclude: All Locations'
                            } else {
                                $locationNames = @()
                                foreach ($locId in $excludeLocations) {
                                    $location = $namedLocations | Where-Object { $_.id -eq $locId }
                                    if ($location) {
                                        $locationNames += $location.displayName
                                    } else {
                                        $locationNames += $locId
                                    }
                                }
                                $locationParts += "Exclude: $($locationNames -join ', ')"
                            }
                        }
                        $locationDetails = $locationParts -join '; '
                        $locationRestrictions += $locationDetails
                    }

                    if ($hasLocationRestriction) {
                        $isProtected = $true
                    }
                }
            }
        }

        # Build SP information object
        $spInfo = @{
            DisplayName = $sp.displayName
            AppId = $sp.appId
            PortalLink = "[$($sp.displayName)](https://portal.azure.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/$($sp.id)/appId/$($sp.appId))"
            CredentialTypes = $credTypes -join ', '
            AppliedPolicies = if ($appliedPolicies.Count -gt 0) { $appliedPolicies -join '; ' } else { 'None' }
            LocationRestrictions = if ($locationRestrictions.Count -gt 0) { $locationRestrictions -join '; ' } else { 'None' }
            IsProtected = $isProtected
        }

        if ($isProtected) {
            $protectedSPs += $spInfo
        } else {
            $unprotectedSPs += $spInfo
        }
    }

    $result = $unprotectedSPs.Count -eq 0
    $passed = [bool]$result
    if ($passed) {
        $testResultMarkdown = "All workload identities with credentials are protected by location-based Conditional Access policies."
        if ($protectedSPs.Count -gt 0) {
            $testResultMarkdown += "`n`n## Protected service principals"
            $testResultMarkdown += "`n| Service principal display name | Credential type | Applied policy names | Location restrictions |"
            $testResultMarkdown += "`n|-------------------------------|-----------------|---------------------|---------------------|"
            foreach ($sp in $protectedSPs) {
                $testResultMarkdown += "`n| $($sp.PortalLink) | $($sp.CredentialTypes) | $($sp.AppliedPolicies) | $($sp.LocationRestrictions) |"
            }
            if ($spTruncated) {
                $testResultMarkdown += "`n\n_Note: Only the first 1000 service principals are shown._"
            }
        }
    } else {
        $testResultMarkdown = "Found workload identities with credentials that lack network-based access restrictions."
        if ($unprotectedSPs.Count -gt 0) {
            $testResultMarkdown += "`n`n## Unprotected service principals"
            $testResultMarkdown += "`n| Service principal display name | Credential type | Applied policy names | Location restrictions |"
            $testResultMarkdown += "`n|-------------------------------|-----------------|---------------------|---------------------|"
            foreach ($sp in $unprotectedSPs) {
                $testResultMarkdown += "`n| $($sp.PortalLink) | $($sp.CredentialTypes) | $($sp.AppliedPolicies) | $($sp.LocationRestrictions) |"
            }
            if ($spTruncated) {
                $testResultMarkdown += "`n\n_Note: Only the first 1000 service principals are shown._"
            }
        }
        if ($protectedSPs.Count -gt 0) {
            $testResultMarkdown += "`n`n## Protected service principals (for reference)"
            $testResultMarkdown += "`n| Service principal display name | Credential type | Applied policy names | Location restrictions |"
            $testResultMarkdown += "`n|-------------------------------|-----------------|---------------------|---------------------|"
            foreach ($sp in $protectedSPs) {
                $testResultMarkdown += "`n| $($sp.PortalLink) | $($sp.CredentialTypes) | $($sp.AppliedPolicies) | $($sp.LocationRestrictions) |"
            }
            if ($spTruncated) {
                $testResultMarkdown += "`n\n_Note: Only the first 1000 service principals are shown._"
            }
        }
    }
    $params = @{
        TestId = '21884'
        Status = $passed
        Result = $testResultMarkdown
    }
    Add-ZtTestResultDetail @params
}
