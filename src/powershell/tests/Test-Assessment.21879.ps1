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
    Write-ZtProgress -Activity $activity -Status 'Getting assignment policies'

    try {
        # Query assignment policies directly with expanded access package information (more efficient than expanding from access packages)
        $assignmentPolicies = Invoke-ZtGraphRequest -RelativeUri 'identityGovernance/entitlementManagement/assignmentPolicies' -QueryParameters @{'$expand' = 'accessPackage'} -ApiVersion v1.0

        # Handle case where no policies exist or API returns null
        if ($null -eq $assignmentPolicies -or $assignmentPolicies.Count -eq 0) {
            Write-PSFMessage 'No assignment policies found in the tenant' -Level Verbose
            $testResultMarkdown = 'No access package assignment policies found in the tenant.'
            $passed = $true
        }
        else {
            Write-ZtProgress -Activity $activity -Status 'Filtering policies for external users'

            # Client-side filter for policies that apply to external users
            $externalUserPolicies = @()

            foreach ($policy in $assignmentPolicies) {
                # Skip if requestorSettings is null or missing
                if ($null -eq $policy.requestorSettings) {
                    Write-PSFMessage "Skipping policy $($policy.id) - no requestorSettings" -Level Debug
                    continue
                }

                # Check if policy accepts requests
                if ($policy.requestorSettings.acceptRequests -eq $true) {
                    # Use the existing Test-ZtExternalUserScope function to check if policy applies to external users
                    $appliesToExternal = Test-ZtExternalUserScope -TargetScope $policy.allowedTargetScope

                    if ($appliesToExternal) {
                        $externalUserPolicies += [PSCustomObject]@{
                            AccessPackageId = $policy.accessPackage.id
                            AccessPackageName = $policy.accessPackage.displayName
                            AssignmentPolicyId = $policy.id
                            AssignmentPolicyName = $policy.displayName
                            AssignmentPolicyScopeType = $policy.allowedTargetScope
                            IsApprovalRequired = [bool]($policy.requestorSettings.approvalSettings.isApprovalRequired)
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
                # Pass/Fail Logic: If there is at least one result where isApprovalRequired == "false", fail the test. Else pass the test
                $policiesWithoutApproval = $externalUserPolicies | Where-Object { $_.IsApprovalRequired -eq $false }

                if ($policiesWithoutApproval.Count -eq 0) {
                    # PASS: No policies without approval
                    $passed = $true
                    $testResultMarkdown = 'All access package assignment policies for external users require approval'
                }
                else {
                    # FAIL: At least one policy without approval
                    $passed = $false
                    $testResultMarkdown = 'Access package assignment policies for external users without approval are found in the tenant'
                }

                # Details: For each policy found
                $testResultMarkdown += "`n`n## Details`n`n"
                $testResultMarkdown += "Assignment policies that apply to external users:`n`n"
                $testResultMarkdown += '| Access package ID | Access package name | Assignment policy ID | Assignment policy Name | Assignment policy scopeType | Assignment policy isApprovalRequired |`n'
                $testResultMarkdown += '|:---|:---|:---|:---|:---|:---|`n'

                foreach ($policy in $externalUserPolicies) {
                    $packageLink = "https://entra.microsoft.com/#view/Microsoft_AAD_ERM/DashboardBlade/~/elmEntitlementManagement/menuId/AccessPackages"
                    $approvalStatus = if ($policy.IsApprovalRequired) { 'true' } else { 'false' }

                    $testResultMarkdown += "| ``$($policy.AccessPackageId)`` | [$(Get-SafeMarkdown $policy.AccessPackageName)]($packageLink) | ``$($policy.AssignmentPolicyId)`` | $(Get-SafeMarkdown $policy.AssignmentPolicyName) | $($policy.AssignmentPolicyScopeType) | **$approvalStatus** |`n"
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
