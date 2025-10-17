<#
.SYNOPSIS
    Checks if all entitlement management policies that apply to external users require approval
#>

function Test-Assessment-21879{
    [ZtTest(
    	Category = 'Access control',
    	ImplementationCost = 'Medium',
    	Pillar = 'Identity',
    	RiskLevel = 'Medium',
    	SfiPillar = 'Protect identities and secrets',
    	TenantType = ('Workforce','External'),
    	TestId = 21879,
    	Title = 'All entitlement management policies that apply to External users require approval',
    	UserImpact = 'Medium'
    )]
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking All entitlement management policies that apply to external users require approval'
    Write-ZtProgress -Activity $activity -Status 'Getting access packages and assignment policies'

    try {
        # Query access packages with expanded assignment policies
        $accessPackages = Invoke-ZtGraphRequest -RelativeUri 'identityGovernance/entitlementManagement/accessPackages' -ApiVersion beta -QueryParameters @{
            '$expand' = 'accessPackageAssignmentPolicies'
        }

        if (-not $accessPackages -or $accessPackages.Count -eq 0) {
            $testResultMarkdown = 'No access packages found in the tenant.'
            $passed = $true
        }
        else {
            Write-ZtProgress -Activity $activity -Status 'Filtering policies for external users'

            # Filter to find policies that apply to external users
            $externalUserPolicies = @()
            $externalScopeTypes = @('SpecificConnectedOrganizationSubjects', 'AllConfiguredConnectedOrganizationSubjects', 'AllExternalSubjects')

            foreach ($package in $accessPackages) {
                if ($package.accessPackageAssignmentPolicies) {
                    foreach ($policy in $package.accessPackageAssignmentPolicies) {
                        # Check if policy is enabled and applies to external users
                        if ($policy.requestorSettings.acceptRequests -eq $true -and
                            $policy.requestorSettings.allowedRequestors) {

                            foreach ($requestor in $policy.requestorSettings.allowedRequestors) {
                                if ($requestor.scopeType -in $externalScopeTypes) {
                                    $externalUserPolicies += @{
                                        AccessPackageId = $package.id
                                        AccessPackageName = $package.displayName
                                        PolicyId = $policy.id
                                        PolicyName = $policy.displayName
                                        ScopeType = $requestor.scopeType
                                        IsApprovalRequired = $policy.requestorSettings.approvalSettings.isApprovalRequired
                                    }
                                    break # Only need to add the policy once per package
                                }
                            }
                        }
                    }
                }
            }

            Write-ZtProgress -Activity $activity -Status 'Evaluating approval requirements'

            if ($externalUserPolicies.Count -eq 0) {
                $testResultMarkdown = 'No access package assignment policies found that apply to external users.'
                $passed = $true
            }
            else {
                # Check if any policies don't require approval
                $policiesWithoutApproval = $externalUserPolicies | Where-Object { $_.IsApprovalRequired -eq $false }

                if ($policiesWithoutApproval.Count -eq 0) {
                    $passed = $true
                    $testResultMarkdown = 'All access package assignment policies for external users require approval.'

                    # Add summary details
                    $testResultMarkdown += "`n`n## Summary`n`n"
                    $testResultMarkdown += "- Total access packages: $($accessPackages.Count)`n"
                    $testResultMarkdown += "- Policies applying to external users: $($externalUserPolicies.Count)`n"
                    $testResultMarkdown += "- Policies requiring approval: $($externalUserPolicies.Count)`n"
                }
                else {
                    $passed = $false
                    $testResultMarkdown = 'Access package assignment policies for external users without approval are found in the tenant.`n`n'

                    # Add details table for policies without approval
                    $testResultMarkdown += '## Policies without approval requirement`n`n'
                    $testResultMarkdown += '| Access Package | Assignment Policy | Scope Type | Approval Required |`n'
                    $testResultMarkdown += '| :--- | :--- | :--- | :--- |`n'

                    foreach ($policy in $policiesWithoutApproval) {
                        $packageLink = 'https://entra.microsoft.com/#view/Microsoft_AAD_ERM/DashboardBlade/~/elmEntitlementManagement/menuId/AccessPackages'
                        $testResultMarkdown += "| [$(Get-SafeMarkdown($policy.AccessPackageName))]($packageLink) | $(Get-SafeMarkdown($policy.PolicyName)) | $($policy.ScopeType) | $($policy.IsApprovalRequired) |`n"
                    }

                    # Add summary
                    $testResultMarkdown += '`n## Summary`n`n'
                    $testResultMarkdown += "- Total access packages: $($accessPackages.Count)`n"
                    $testResultMarkdown += "- Policies applying to external users: $($externalUserPolicies.Count)`n"
                    $testResultMarkdown += "- Policies requiring approval: $(($externalUserPolicies | Where-Object { $_.IsApprovalRequired -eq $true }).Count)`n"
                    $testResultMarkdown += "- Policies **not** requiring approval: $($policiesWithoutApproval.Count)`n"
                }

                # Add detailed information for all external user policies
                if ($externalUserPolicies.Count -gt 0) {
                    $testResultMarkdown += '`n`n## Details`n`n'
                    $testResultMarkdown += 'For each policy found that applies to external users:`n`n'
                    $testResultMarkdown += '| Access Package ID | Access Package Name | Assignment Policy ID | Assignment Policy Name | Assignment Policy ScopeType | Assignment Policy isApprovalRequired |`n'
                    $testResultMarkdown += '| :--- | :--- | :--- | :--- | :--- | :--- |`n'

                    foreach ($policy in $externalUserPolicies) {
                        $packageLink = 'https://entra.microsoft.com/#view/Microsoft_AAD_ERM/DashboardBlade/~/elmEntitlementManagement/menuId/AccessPackages'
                        $testResultMarkdown += "| $($policy.AccessPackageId) | [$(Get-SafeMarkdown($policy.AccessPackageName))]($packageLink) | $($policy.PolicyId) | $(Get-SafeMarkdown($policy.PolicyName)) | $($policy.ScopeType) | $($policy.IsApprovalRequired) |`n"
                    }
                }
            }
        }
    }
    catch {
        Write-PSFMessage "Error querying entitlement management: $($_.Exception.Message)" -Level Warning
        $testResultMarkdown = 'Unable to query entitlement management policies. This may indicate that Entitlement Management is not enabled or configured in the tenant, or insufficient permissions to access the data.'
        $passed = $false
    }

    $params = @{
        TestId             = '21879'
        Status             = $passed
        Result             = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
