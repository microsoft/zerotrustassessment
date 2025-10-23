<#
.SYNOPSIS
    Checks if all entitlement management packages that apply to guests have expirations or access reviews configured in their assignment policies.
#>

function Test-Assessment-21929{
    [ZtTest(
    	Category = 'Access control',
    	ImplementationCost = 'Medium',
    	Pillar = 'Identity',
    	RiskLevel = 'Medium',
    	SfiPillar = 'Protect identities and secrets',
    	TenantType = ('Workforce','External'),
    	TestId = 21929,
    	Title = 'All entitlement management packages that apply to guests have expirations or access reviews configured in their assignment policies',
    	UserImpact = 'Medium'
    )]
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking entitlement management packages for external users have proper controls'
    Write-ZtProgress -Activity $activity -Status 'Getting assignment policies'

    # Query 1: Get all assignment policies with expanded access package information
    $assignmentPolicies = Invoke-ZtGraphRequest -RelativeUri 'identityGovernance/entitlementManagement/assignmentPolicies' -QueryParameters @{'$expand' = 'accessPackage'} -ApiVersion v1.0

    # Handle case where no policies exist or API returns null
    if ($null -eq $assignmentPolicies -or $assignmentPolicies.Count -eq 0) {
        Write-PSFMessage 'No assignment policies found in the tenant' -Level Verbose
        $assignmentPolicies = @()
    }

    # Client-side filter for policies that apply to external users
    $externalUserPolicies = @()

    foreach ($policy in $assignmentPolicies) {
        # Skip if requestorSettings is null or missing
        if ($null -eq $policy.requestorSettings) {
            Write-PSFMessage "Skipping policy $($policy.id) - no requestorSettings" -Level Debug
            continue
        }

        $requestorSettings = $policy.requestorSettings

        # Check if policy allows self-service or on-behalf requests
        $allowsSelfService = $requestorSettings.enableTargetsToSelfAddAccess -eq $true -or
                           $requestorSettings.enableTargetsToSelfRemoveAccess -eq $true -or
                           $requestorSettings.enableTargetsToSelfUpdateAccess -eq $true -or
                           $requestorSettings.enableOnBehalfRequestorsToAddAccess -eq $true -or
                           $requestorSettings.enableOnBehalfRequestorsToRemoveAccess -eq $true -or
                           $requestorSettings.enableOnBehalfRequestorsToUpdateAccess -eq $true

        # Check if policy applies to external users using allowedTargetScope property
        $appliesToExternal = Test-ZtExternalUserScope -TargetScope $policy.allowedTargetScope

        # Include policy if it allows requests AND applies to external users
        if ($allowsSelfService -and $appliesToExternal) {
            $externalUserPolicies += $policy
        }
    }

    Write-PSFMessage "Found $($externalUserPolicies.Count) assignment policies that apply to external users" -Level Verbose

    # Query 2: Evaluate expiration and access review controls for each policy
    $policiesWithoutControls = @()
    $allPoliciesData = @()

    foreach ($policy in $externalUserPolicies) {
        # Check expiration configuration - handle null expiration object
        $hasExpiration = $null -ne $policy.expiration -and $policy.expiration.type -ne 'noExpiration'

        # Check access review configuration
        # Review settings must be enabled AND have a schedule with recurrence pattern configured
        $hasAccessReview = $false
        if ($null -ne $policy.reviewSettings -and $policy.reviewSettings.isEnabled -eq $true) {
            # Check if schedule exists with proper recurrence pattern
            if ($null -ne $policy.reviewSettings.schedule -and
                $null -ne $policy.reviewSettings.schedule.recurrence -and
                $null -ne $policy.reviewSettings.schedule.recurrence.pattern) {
                $hasAccessReview = $true
            }
        }

        # Skip policies with missing access package information
        if ($null -eq $policy.accessPackage) {
            Write-PSFMessage "Skipping policy $($policy.id) - no accessPackage information" -Level Warning
            continue
        }

        # Create policy data for reporting
        $policyData = [PSCustomObject]@{
            AccessPackageId = $policy.accessPackage.id
            AccessPackageName = $policy.accessPackage.displayName
            AssignmentPolicyId = $policy.id
            AssignmentPolicyName = $policy.displayName
            HasExpiration = $hasExpiration
            HasAccessReview = $hasAccessReview
            HasControls = $hasExpiration -or $hasAccessReview
        }

        $allPoliciesData += $policyData

        # Track policies without proper controls
        if (-not ($hasExpiration -or $hasAccessReview)) {
            $policiesWithoutControls += $policyData
        }
    }

    # Assessment logic
    $passed = $policiesWithoutControls.Count -eq 0

    # Build report markdown
    $portalLink = 'https://entra.microsoft.com/#view/Microsoft_AAD_ERM/DashboardBlade/~/elmEntitlement'

    if ($passed) {
        $testResultMarkdown = "All access package assignment policies for external users include expiration or access reviews.`n`n%PolicyDetails%"
    } else {
        $testResultMarkdown = "Access package assignment policies without expiration and without access reviews were found for external users.`n`n%PolicyDetails%"
    }

    # Build policy details table
    $mdInfo = "## [Access package assignment policies for external users]($portalLink)`n`n"

    if ($allPoliciesData.Count -gt 0) {
        $mdInfo += "| Access package | Assignment policy | Expiry configured | Access review configured | Status |`n"
        $mdInfo += "| :------------- | :---------------- | :------------------ | :--------------------- | :----- |`n"

        # Sort to show non-compliant policies first, then by access package and policy name
        foreach ($policyData in ($allPoliciesData | Sort-Object HasControls, AccessPackageName, AssignmentPolicyName)) {
            $packageName = Get-SafeMarkdown -Text $policyData.AccessPackageName
            $policyName = Get-SafeMarkdown -Text $policyData.AssignmentPolicyName

            $expirationStatus = if ($policyData.HasExpiration) { 'Yes' } else { 'No' }
            $reviewStatus = if ($policyData.HasAccessReview) { 'Yes' } else { 'No' }
            $overallStatus = if ($policyData.HasControls) { '✅ Compliant' } else { '❌ Non-compliant' }

            $mdInfo += "| $packageName | $policyName | $expirationStatus | $reviewStatus | $overallStatus |`n"
        }
    } else {
        $mdInfo += "No access package assignment policies found that apply to external users.`n"
    }

    # Replace placeholder in test result markdown
    $testResultMarkdown = $testResultMarkdown -replace "%PolicyDetails%", $mdInfo

    $params = @{
        TestId = '21929'
        Status = $passed
        Result = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
