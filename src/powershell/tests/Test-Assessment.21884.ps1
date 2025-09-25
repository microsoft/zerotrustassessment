<#
.SYNOPSIS
    Tests if workload identities are protected by location-based Conditional Access policies.
#>

function Test-Assessment-21884 {
    [ZtTest(
    	Category = 'External collaboration',
    	ImplementationCost = 'Medium',
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

    $activity = "Checking if workload identities are protected by location-based Conditional Access policies"
    Write-ZtProgress -Activity $activity -Status "Getting service principals"

    # Check if we have data in the database
    $sqlCount = "SELECT COUNT(*) ItemCount FROM ServicePrincipal WHERE ID IS NOT NULL"
    $resultCount = Invoke-DatabaseQuery -Database $Database -Sql $sqlCount
    $hasData = $resultCount.ItemCount -gt 0

    if (-not $hasData) {
        $testResultMarkdown = "No service principals found in the tenant to evaluate. The test result is inconclusive as there are no workload identities to assess."

        $params = @{
            TestId = '21884'
            Status = [bool]$false
            Result = $testResultMarkdown
        }
        Add-ZtTestResultDetail @params
        return
    }

    # Get current tenant ID from context
    $tenantId = (Get-MgContext).TenantId

    # Q1: Get all service principals with credential information from database
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
"@

    $ownedServicePrincipals = Invoke-DatabaseQuery -Database $Database -Sql $sqlServicePrincipals

        if ($ownedServicePrincipals.Count -eq 0) {
            $testResultMarkdown = "No service principals found in the tenant to evaluate. The test result is inconclusive as there are no workload identities to assess."

            $params = @{
                TestId = '21884'
                Status = [bool]$false
                Result = $testResultMarkdown
            }
            Add-ZtTestResultDetail @params
            return
        }

        $servicePrincipalsWithCreds = @()
        foreach ($sp in $ownedServicePrincipals) {
            $hasCreds = $false

            # Check direct credentials
            $hasPassword = ($sp.passwordCredentials -ne '[]') -and ($sp.passwordCredentials -ne $null)
            $hasCertificate = ($sp.keyCredentials -ne '[]') -and ($sp.keyCredentials -ne $null)
            if ($hasPassword -or $hasCertificate) {
                $hasCreds = $true
            } else {
                # Q3: Check associated application for credentials from database
                $sqlApp = @"
                SELECT
                    id,
                    appId,
                    displayName,
                    passwordCredentials,
                    keyCredentials,
                    signInAudience
                FROM Application
                WHERE appId = '$($sp.appId)'
"@
                $app = Invoke-DatabaseQuery -Database $Database -Sql $sqlApp
                if ($app -and $app.Count -gt 0) {
                    $appRecord = $app[0]
                    $appHasPassword = ($appRecord.passwordCredentials -ne '[]') -and ($appRecord.passwordCredentials -ne $null)
                    $appHasCertificate = ($appRecord.keyCredentials -ne '[]') -and ($appRecord.keyCredentials -ne $null)
                    if ($appRecord.signInAudience -eq 'AzureADMyOrg' -and ($appHasPassword -or $appHasCertificate)) {
                        $hasCreds = $true
                    }
                }
            }

            if ($hasCreds) {
                $servicePrincipalsWithCreds += $sp
            }
        }

        # Q4: Get CA policies targeting workload identities from Graph API
        # (Conditional Access policies are not stored in the database, so we still need to use Graph API)
        $policies = Invoke-ZtGraphRequest -RelativeUri "identity/conditionalAccess/policies" -Filter "conditions/clientApplications/includeServicePrincipals/any(x:x eq 'ServicePrincipalsAndManagedIdentities')" -ApiVersion v1.0

        # Check for a global policy that covers all service principals
        $allSpPolicy = $policies | Where-Object {
            $_.state -eq "enabled" -and
            $_.conditions.clientApplications.includeServicePrincipals -contains "ServicePrincipalsInMyTenant" -and
            (-not $_.conditions.clientApplications.excludeServicePrincipals)
        }

        if ($allSpPolicy) {
            # Verify location conditions in the global policy
            $hasValidLocations = $false
            foreach ($policy in $allSpPolicy) {
                $policyDetails = Invoke-ZtGraphRequest -RelativeUri "identity/conditionalAccess/policies/$($policy.id)" -ApiVersion v1.0

                if ($policyDetails.conditions.locations.includeLocations -or
                    $policyDetails.conditions.locations.excludeLocations) {
                    $hasValidLocations = $true
                    break
                }
            }

            if ($hasValidLocations) {
                $testResultMarkdown = "Pass: All workload identities are protected by global service principal policies with location restrictions."

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
            $testResultMarkdown = "**Fail**: No Conditional Access policies found that protect workload identities.`n`n"
            $testResultMarkdown += "## Unprotected Service Principals`n`n"
            $testResultMarkdown += "| Service Principal Display Name | Service Principal App ID | Credential Type | Applied Policy Names | Location Restrictions |`n"
            $testResultMarkdown += "|-------------------------------|--------------------------|-----------------|---------------------|---------------------|`n"

            foreach ($sp in $servicePrincipalsWithCreds) {
                $credTypes = @()
                if (($sp.passwordCredentials -ne '[]') -and ($sp.passwordCredentials -ne $null)) { $credTypes += "Password" }
                if (($sp.keyCredentials -ne '[]') -and ($sp.keyCredentials -ne $null)) { $credTypes += "Certificate" }

                $testResultMarkdown += "| $($sp.displayName) | $($sp.appId) | $($credTypes -join ', ') | None | None |`n"
            }

            $passed = $false

            $params = @{
                TestId              = '21884'
                Title              = "Workload identities based on known networks are configured"
                UserImpact         = "Low"
                Risk               = "High"
                ImplementationCost = "Medium"
                AppliesTo          = "Identity"
                Tag                = "Identity"
                Status             = $passed
                Result             = $testResultMarkdown
            }

            Add-ZtTestResultDetail @params
            return
        }

        # Q6: Get named locations from Graph API (not stored in database)
        $namedLocations = Invoke-ZtGraphRequest -RelativeUri "identity/conditionalAccess/namedLocations" -ApiVersion v1.0
        $validLocationIds = $namedLocations.id

        if ($namedLocations.Count -eq 0) {
            $testResultMarkdown = "Fail: No named locations found. Cannot implement network-based restrictions without defined locations."

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
            if (($sp.passwordCredentials -ne '[]') -and ($sp.passwordCredentials -ne $null)) { $credTypes += "Password" }
            if (($sp.keyCredentials -ne '[]') -and ($sp.keyCredentials -ne $null)) { $credTypes += "Certificate" }

            $appliedPolicies = @()
            $locationRestrictions = @()
            $isProtected = $false

            # Check each policy for this SP
            foreach ($policy in $policies) {
                # Q5: Get detailed policy information
                $policyDetails = Invoke-ZtGraphRequest -RelativeUri "identity/conditionalAccess/policies/$($policy.id)" -ApiVersion v1.0

                if ($policyDetails.state -eq "enabled") {
                    $policyApplies = $false
                    $hasLocationRestriction = $false
                    $locationDetails = ""

                    # Check if policy applies to this service principal
                    if ($policyDetails.conditions.clientApplications.includeServicePrincipals -contains "ServicePrincipalsInMyTenant" -and
                        (-not $policyDetails.conditions.clientApplications.excludeServicePrincipals)) {
                        $policyApplies = $true
                        # Special callout for global policy
                        $appliedPolicies += "$($policyDetails.displayName) (Global - covers ServicePrincipalsInMyTenant)"
                    } elseif ($policyDetails.conditions.clientApplications.includeServicePrincipals -contains $sp.id) {
                        $policyApplies = $true
                        $appliedPolicies += $policyDetails.displayName
                    }

                    # Check location conditions if policy applies
                    if ($policyApplies) {
                        if ($policyDetails.conditions.locations.includeLocations -or $policyDetails.conditions.locations.excludeLocations) {
                            $hasLocationRestriction = $true

                            # Build location details
                            $locationParts = @()
                            if ($policyDetails.conditions.locations.includeLocations) {
                                $includeLocations = $policyDetails.conditions.locations.includeLocations
                                if ($includeLocations -contains "All") {
                                    $locationParts += "Include: All Locations"
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
                            if ($policyDetails.conditions.locations.excludeLocations) {
                                $excludeLocations = $policyDetails.conditions.locations.excludeLocations
                                if ($excludeLocations -contains "All") {
                                    $locationParts += "Exclude: All Locations"
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
                CredentialTypes = $credTypes -join ', '
                AppliedPolicies = if ($appliedPolicies.Count -gt 0) { $appliedPolicies -join '; ' } else { "None" }
                LocationRestrictions = if ($locationRestrictions.Count -gt 0) { $locationRestrictions -join '; ' } else { "None" }
                IsProtected = $isProtected
            }

            if ($isProtected) {
                $protectedSPs += $spInfo
            } else {
                $unprotectedSPs += $spInfo
            }
        }

        $result = $unprotectedSPs.Count -eq 0

        if ($result) {
            $testResultMarkdown = "**Pass**: All workload identities with credentials are protected by location-based Conditional Access policies.`n`n"

            if ($protectedSPs.Count -gt 0) {
                $testResultMarkdown += "## Protected Service Principals`n`n"
                $testResultMarkdown += "| Service Principal Display Name | Service Principal App ID | Credential Type | Applied Policy Names | Location Restrictions |`n"
                $testResultMarkdown += "|-------------------------------|--------------------------|-----------------|---------------------|---------------------|`n"
                foreach ($sp in $protectedSPs) {
                    $testResultMarkdown += "| $($sp.DisplayName) | $($sp.AppId) | $($sp.CredentialTypes) | $($sp.AppliedPolicies) | $($sp.LocationRestrictions) |`n"
                }
            }
        } else {
            $testResultMarkdown = "**Fail**: Found workload identities with credentials that lack network-based access restrictions.`n`n"

            if ($unprotectedSPs.Count -gt 0) {
                $testResultMarkdown += "## Unprotected Service Principals`n`n"
                $testResultMarkdown += "| Service Principal Display Name | Service Principal App ID | Credential Type | Applied Policy Names | Location Restrictions |`n"
                $testResultMarkdown += "|-------------------------------|--------------------------|-----------------|---------------------|---------------------|`n"
                foreach ($sp in $unprotectedSPs) {
                    $testResultMarkdown += "| $($sp.DisplayName) | $($sp.AppId) | $($sp.CredentialTypes) | $($sp.AppliedPolicies) | $($sp.LocationRestrictions) |`n"
                }
            }

            if ($protectedSPs.Count -gt 0) {
                $testResultMarkdown += "`n## Protected Service Principals (for reference)`n`n"
                $testResultMarkdown += "| Service Principal Display Name | Service Principal App ID | Credential Type | Applied Policy Names | Location Restrictions |`n"
                $testResultMarkdown += "|-------------------------------|--------------------------|-----------------|---------------------|---------------------|`n"
                foreach ($sp in $protectedSPs) {
                    $testResultMarkdown += "| $($sp.DisplayName) | $($sp.AppId) | $($sp.CredentialTypes) | $($sp.AppliedPolicies) | $($sp.LocationRestrictions) |`n"
                }
            }
        }

    $passed = [bool]$result

    $params = @{
        TestId = '21884'
        Status = $passed
        Result = $testResultMarkdown
    }
    Add-ZtTestResultDetail @params
}
