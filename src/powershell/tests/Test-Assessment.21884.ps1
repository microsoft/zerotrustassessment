<#
.SYNOPSIS
    Tests if workload identities are protected by location-based Conditional Access policies.
#>

function Test-Assessment-21884 {
    [ZtTest(
        Category = 'Conditional Access',
        ImplementationCost = 'Medium',
        Pillar = 'Identity',
        RiskLevel = 'High',
        SfiPillar = 'Protect identities and secrets',
        TenantType = ('Workforce','External'),
        TestId = 21884,
        Title = 'Workload identities based on known networks are configured',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "Checking if workload identities are protected by location-based Conditional Access policies"
    Write-ZtProgress -Activity $activity -Status "Getting service principals"

    try {
        # Get current tenant ID for Q2 first as we'll need it for both SP and app queries
        $tenant = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/organization"
        $tenantId = $tenant.value.id

        # Q1: Get all service principals with credential information
        $servicePrincipals = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/servicePrincipals?`$select=id,appId,displayName,servicePrincipalType,passwordCredentials,keyCredentials,appOwnerOrganizationId&`$filter=servicePrincipalType eq 'Application'"

        # Filter service principals owned by current tenant
        $ownedServicePrincipals = $servicePrincipals.value | Where-Object { $_.appOwnerOrganizationId -eq $tenantId }

        if ($ownedServicePrincipals.Count -eq 0) {
            Write-PSFMessage "No service principals found in tenant" -Level Warning
            $testResultMarkdown = "No service principals found in the tenant to evaluate. The test result is inconclusive as there are no workload identities to assess."
            $passed = [bool]$false  # Change from null to false for inconclusive result

            Add-ZtTestResultDetail -TestId '21884' -Status $passed -Result $testResultMarkdown
            return
        }

        $servicePrincipalsWithCreds = @()
        foreach ($sp in $ownedServicePrincipals) {
            $hasCreds = $false

            # Check direct credentials
            if (($sp.passwordCredentials.Count -gt 0) -or ($sp.keyCredentials.Count -gt 0)) {
                $hasCreds = $true
            } else {
                # Q3: Check associated application for credentials
                try {
                    $app = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/applications/$($sp.appId)?`$select=id,appId,displayName,passwordCredentials,keyCredentials,signInAudience"
                    if ($app.signInAudience -eq 'AzureADMyOrg' -and
                        (($app.passwordCredentials.Count -gt 0) -or ($app.keyCredentials.Count -gt 0))) {
                        $hasCreds = $true
                    }
                } catch {
                    Write-PSFMessage "Failed to get application details for $($sp.appId): $($_.Exception.Message)" -Level Warning
                }
            }

            if ($hasCreds) {
                $servicePrincipalsWithCreds += $sp
            }
        }

        # Q4: Get CA policies targeting workload identities
        $policies = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/identity/conditionalAccess/policies?`$filter=conditions/clientApplications/includeServicePrincipals/any(x:x eq 'ServicePrincipalsAndManagedIdentities')"

        # Check for a global policy that covers all service principals
        $allSpPolicy = $policies.value | Where-Object {
            $_.state -eq "enabled" -and
            $_.conditions.clientApplications.includeServicePrincipals -contains "ServicePrincipalsInMyTenant" -and
            (-not $_.conditions.clientApplications.excludeServicePrincipals)
        }

        if ($allSpPolicy) {
            # Verify location conditions in the global policy
            $hasValidLocations = $false
            foreach ($policy in $allSpPolicy) {
                $policyDetails = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/identity/conditionalAccess/policies/$($policy.id)"

                if ($policyDetails.conditions.locations.includeLocations -or
                    $policyDetails.conditions.locations.excludeLocations) {
                    $hasValidLocations = $true
                    break
                }
            }

            if ($hasValidLocations) {
                $testResultMarkdown = "Pass: All workload identities are protected by global service principal policies with location restrictions."
                $passed = [bool]$true

                Add-ZtTestResultDetail -TestId '21884' -Status $passed -Result $testResultMarkdown
                return
            }
        }

        if ($servicePrincipalsWithCreds.Count -gt 0 -and $policies.value.Count -eq 0) {
            $testResultMarkdown = "Fail: No Conditional Access policies found that protect workload identities.`n`n"
            $testResultMarkdown += "The following service principals have credentials but no network restrictions:`n`n"
            $testResultMarkdown += "| Service Principal | App ID | Credential Types |`n"
            $testResultMarkdown += "|------------------|---------|-----------------|`n"

            foreach ($sp in $servicePrincipalsWithCreds) {
                $credTypes = @()
                if ($sp.passwordCredentials.Count -gt 0) { $credTypes += "Password" }
                if ($sp.keyCredentials.Count -gt 0) { $credTypes += "Certificate" }

                $testResultMarkdown += "| $($sp.displayName) | $($sp.appId) | $($credTypes -join ', ') |`n"
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

        # Q6: Get named locations
        $namedLocations = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/identity/conditionalAccess/namedLocations"
        $validLocationIds = $namedLocations.value.id

        if ($namedLocations.value.Count -eq 0) {
            $testResultMarkdown = "Fail: No named locations found. Cannot implement network-based restrictions without defined locations."
            $passed = [bool]$false

            Add-ZtTestResultDetail -TestId '21884' -Status $passed -Result $testResultMarkdown
            return
        }

        $unprotectedSPs = @()

        foreach ($sp in $servicePrincipalsWithCreds) {
            $isProtected = $false

            # Check each policy
            foreach ($policy in $policies.value) {
                # Q5: Check location conditions
                $policyDetails = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/identity/conditionalAccess/policies/$($policy.id)"

                if ($policyDetails.state -eq "enabled") {
                    # Check if policy includes all service principals without exclusions
                    if ($policyDetails.conditions.clientApplications.includeServicePrincipals -contains "ServicePrincipalsInMyTenant" -and
                        (-not $policyDetails.conditions.clientApplications.excludeServicePrincipals)) {
                        $isProtected = $true
                        break
                    }

                    # Check location conditions
                    $hasLocationRestriction = $false
                    if ($policyDetails.conditions.locations.includeLocations) {
                        $hasLocationRestriction = $true
                        # Verify locations exist
                        $locationIds = $policyDetails.conditions.locations.includeLocations
                        if (-not ($locationIds | Where-Object { $validLocationIds -contains $_ })) {
                            $hasLocationRestriction = $false
                        }
                    }
                    if ($policyDetails.conditions.locations.excludeLocations) {
                        $hasLocationRestriction = $true
                        # Verify locations exist
                        $locationIds = $policyDetails.conditions.locations.excludeLocations
                        if (-not ($locationIds | Where-Object { $validLocationIds -contains $_ })) {
                            $hasLocationRestriction = $false
                        }
                    }

                    if ($hasLocationRestriction) {
                        $isProtected = $true
                        break
                    }
                }
            }

            if (-not $isProtected) {
                $credTypes = @()
                if ($sp.passwordCredentials.Count -gt 0) { $credTypes += "Password" }
                if ($sp.keyCredentials.Count -gt 0) { $credTypes += "Certificate" }

                $unprotectedSPs += @{
                    DisplayName = $sp.displayName
                    AppId = $sp.appId
                    CredentialTypes = $credTypes -join ", "
                }
            }
        }

        $result = $unprotectedSPs.Count -eq 0
        if ($result) {
            $testResultMarkdown = "Pass: All workload identities with credentials are protected by location-based Conditional Access policies."
        } else {
            $testResultMarkdown = "Fail: Found workload identities with credentials that lack network-based access restrictions.`n`n"
            $testResultMarkdown += "| Service Principal | App ID | Credential Types |`n"
            $testResultMarkdown += "|------------------|---------|-----------------|`n"
            foreach ($sp in $unprotectedSPs) {
                $testResultMarkdown += "| $($sp.DisplayName) | $($sp.AppId) | $($sp.CredentialTypes) |`n"
            }
        }

        $passed = [bool]$result

    } catch {
        Write-PSFMessage -Level Error -Message "Error in Test-Assessment-21884: $($_.Exception.Message)"
        Add-ZtTestResultDetail -TestId '21884' -Status $false -Result "Error occurred while checking workload identity protections: $($_.Exception.Message)"
        return
    }

    # Only execute this if we haven't hit an error
    Add-ZtTestResultDetail -TestId '21884' -Status [bool]$passed -Result $testResultMarkdown
}
