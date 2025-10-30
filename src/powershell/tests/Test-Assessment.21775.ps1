<#
.SYNOPSIS
    Validates that tenant app management policy is configured with credential restrictions.

.DESCRIPTION
    This test checks if the tenant default app management policy is properly configured with
    active credential restrictions to control application authentication methods and enforce
    security standards for credentials.

.NOTES
    Test ID: 21775
    Category: Access control
    Required API: policies/defaultAppManagementPolicy
#>

function Test-Assessment-21775{
    [ZtTest(
    	Category = 'Access control',
    	ImplementationCost = 'Low',
    	Pillar = 'Identity',
    	RiskLevel = 'Low',
    	SfiPillar = 'Protect identities and secrets',
    	TenantType = ('Workforce','External'),
    	TestId = 21775,
    	Title = 'Tenant app management policy is configured',
    	UserImpact = 'Medium'
    )]
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking Tenant app management policy is configured'
    Write-ZtProgress -Activity $activity -Status 'Getting policy'

    # Query Q1: Get tenant default app management policy configuration
    $policy = Invoke-ZtGraphRequest -RelativeUri 'policies/defaultAppManagementPolicy' -ApiVersion v1.0

    # Initialize test variables
    $testResultMarkdown = ''
    $passed = $false
    $hasCredentialRestrictions = $false
    $credentialRestrictionDetails = @()
    $configurationIssues = @()

    # Step 1: Validate policy exists
    if (-not $policy) {
        $testResultMarkdown = '❌ Tenant app management policy could not be retrieved or does not exist.`n`n%TestResult%'
    }
    # Step 2: Validate policy is enabled
    elseif (-not $policy.isEnabled) {
        $testResultMarkdown = '❌ Tenant app management policy exists but is not enabled.`n`n%TestResult%'
    }
    # Step 3: Validate credential restrictions are configured and enabled
    else {
        # Helper function to process credential restrictions
        $processRestrictions = {
            param($restrictions, $restrictionType, $context)

            if ($restrictions -and $restrictions.Count -gt 0) {
                foreach ($restriction in $restrictions) {
                    if ($restriction.state -eq 'enabled') {
                        $script:hasCredentialRestrictions = $true
                        $script:credentialRestrictionDetails += "✅ $context $restrictionType credentials: $($restriction.restrictionType) (state: enabled)"
                    }
                    else {
                        $script:configurationIssues += "⚠️ $context $restrictionType credential restriction exists but is not enabled (type: $($restriction.restrictionType), state: $($restriction.state))"
                    }
                }
            }
        }

        # Check Application Restrictions
        if ($policy.applicationRestrictions) {
            & $processRestrictions $policy.applicationRestrictions.passwordCredentials 'password' 'Application'
            & $processRestrictions $policy.applicationRestrictions.keyCredentials 'key' 'Application'
        }

        # Check Service Principal Restrictions
        if ($policy.servicePrincipalRestrictions) {
            & $processRestrictions $policy.servicePrincipalRestrictions.passwordCredentials 'password' 'Service principal'
            & $processRestrictions $policy.servicePrincipalRestrictions.keyCredentials 'key' 'Service principal'
        }

        # Determine pass/fail status
        if ($hasCredentialRestrictions) {
            $passed = $true
            $testResultMarkdown = '✅ Tenant app management policy is properly configured with active credential restrictions.`n`n%TestResult%'
        }
        elseif ($configurationIssues.Count -gt 0) {
            $testResultMarkdown = '❌ Tenant app management policy is enabled but credential restrictions are not enabled.`n`n%TestResult%'
        }
        elseif (-not $policy.applicationRestrictions -and -not $policy.servicePrincipalRestrictions) {
            $testResultMarkdown = '❌ Tenant app management policy is enabled but no application or service principal restrictions are configured.`n`n%TestResult%'
        }
        else {
            $testResultMarkdown = '❌ Tenant app management policy is enabled but lacks active credential restrictions.`n`n%TestResult%'
        }
    }

    # Build detailed and clear markdown information
    $mdInfo = ''

    if (-not $policy) {
        $mdInfo += "`n`n## Assessment results`n`n"
        $mdInfo += "❌ **Policy status**: Tenant app management policy could not be retrieved or does not exist.`n`n"
        $mdInfo += "**Next steps**: Ensure that the tenant has the appropriate licensing and permissions to configure app management policies.`n"
    }
    else {
        $mdInfo += "`n`n## Policy configuration assessment`n`n"

        # Policy basic information
        $mdInfo += "| Property | Status | Value |`n"
        $mdInfo += "| :------- | :----- | :---- |`n"
        $policyStatus = if ($policy.isEnabled) { '✅ Yes' } else { '❌ No' }
        $mdInfo += "| Policy enabled | $policyStatus | $($policy.isEnabled) |`n"

        # Configuration details
        $mdInfo += "`n### Configuration details`n`n"

        # Helper function to build restriction tables
        $buildRestrictionTable = {
            param($restrictions, $restrictionName)

            $hasRestrictions = $false
            $tableInfo = ''

            if ($restrictions.passwordCredentials -and $restrictions.passwordCredentials.Count -gt 0) {
                if (-not $hasRestrictions) {
                    $tableInfo += "| Credential type | Restriction type | State | Status |`n"
                    $tableInfo += "| :-------------- | :--------------- | :---- | :----- |`n"
                    $hasRestrictions = $true
                }
                foreach ($pwdCred in $restrictions.passwordCredentials) {
                    $status = if ($pwdCred.state -eq 'enabled') { '✅ Active' } else { '⚠️ Configured but inactive' }
                    $tableInfo += "| Password credentials | $($pwdCred.restrictionType) | $($pwdCred.state) | $status |`n"
                }
            }

            if ($restrictions.keyCredentials -and $restrictions.keyCredentials.Count -gt 0) {
                if (-not $hasRestrictions) {
                    $tableInfo += "| Credential type | Restriction type | State | Status |`n"
                    $tableInfo += "| :-------------- | :--------------- | :---- | :----- |`n"
                    $hasRestrictions = $true
                }
                foreach ($keyCred in $restrictions.keyCredentials) {
                    $status = if ($keyCred.state -eq 'enabled') { '✅ Active' } else { '⚠️ Configured but inactive' }
                    $tableInfo += "| Key credentials | $($keyCred.restrictionType) | $($keyCred.state) | $status |`n"
                }
            }

            return @{ HasRestrictions = $hasRestrictions; TableInfo = $tableInfo }
        }

        # Application Restrictions
        if ($policy.applicationRestrictions) {
            $mdInfo += "**Application restrictions**: ✅ Configured`n`n"
            $appResult = & $buildRestrictionTable $policy.applicationRestrictions 'Application'
            if ($appResult.HasRestrictions) {
                $mdInfo += $appResult.TableInfo + "`n"
            }
            else {
                $mdInfo += "- No specific credential restrictions configured`n`n"
            }
        }
        else {
            $mdInfo += "**Application restrictions**: ❌ Not configured`n`n"
        }

        # Service Principal Restrictions
        if ($policy.servicePrincipalRestrictions) {
            $mdInfo += "**Service principal restrictions**: ✅ Configured`n`n"
            $spResult = & $buildRestrictionTable $policy.servicePrincipalRestrictions 'Service Principal'
            if ($spResult.HasRestrictions) {
                $mdInfo += $spResult.TableInfo + "`n"
            }
            else {
                $mdInfo += "- No specific credential restrictions configured`n`n"
            }
        }
        else {
            $mdInfo += "**Service principal restrictions**: ❌ Not configured`n`n"
        }

        # Summary of active restrictions
        if ($credentialRestrictionDetails.Count -gt 0) {
            $mdInfo += "### ✅ Active credential restrictions`n`n"
            $credentialRestrictionDetails | ForEach-Object { $mdInfo += "- $_`n" }
            $mdInfo += "`n"
        }

        # Configuration issues
        if ($configurationIssues.Count -gt 0) {
            $mdInfo += "### ⚠️ Configuration issues found`n`n"
            $configurationIssues | ForEach-Object { $mdInfo += "- $_`n" }
            $mdInfo += "`n"
        }

        # If no restrictions are configured at all
        if (-not $policy.applicationRestrictions -and -not $policy.servicePrincipalRestrictions) {
            $mdInfo += "### ❌ No restrictions configured`n`n"
            $mdInfo += "- Neither application restrictions nor service principal restrictions are configured`n"
            $mdInfo += "- Policy is enabled but provides no credential management controls`n`n"
        }
    }

    # Replace the placeholder with detailed information
    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo

    # Add test result details
    Add-ZtTestResultDetail -TestId '21775' -Status $passed -Result $testResultMarkdown
}
