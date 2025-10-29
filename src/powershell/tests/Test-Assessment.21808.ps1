<#
.SYNOPSIS
    Checks if device code flow is restricted in the tenant using Conditional Access policies.
#>
function Test-Assessment-21808{
    [ZtTest(
    	Category = 'Access control',
    	ImplementationCost = 'Low',
    	Pillar = 'Identity',
    	RiskLevel = 'High',
    	SfiPillar = 'Protect identities and secrets',
    	TenantType = ('Workforce','External'),
    	TestId = 21808,
    	Title = 'Restrict device code flow',
    	UserImpact = 'Medium'
    )]
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "Checking Restrict device code flow"
    Write-ZtProgress -Activity $activity -Status "Getting conditional access policies"

    # Get all CA policies from the tenant
    $allCAPolicies = Invoke-ZtGraphRequest -RelativeUri "identity/conditionalAccess/policies" -ApiVersion 'beta'

    # Filter enabled policies locally
    $enabledPolicies = $allCAPolicies | Where-Object { $_.state -eq 'enabled' }
    $disabledPolicies = $allCAPolicies | Where-Object { $_.state -ne 'enabled' }

    # Find policies that target device code flow authentication - handle comma-separated values
    $deviceCodeFlowPolicies = $enabledPolicies | Where-Object {
        # Check if transferMethods contains deviceCodeFlow (handle comma-separated values)
        if ($_.conditions.authenticationFlows.transferMethods) {
            # Split by comma and check if deviceCodeFlow is in the array
            $transferMethods = $_.conditions.authenticationFlows.transferMethods -split ','
            $transferMethods -contains "deviceCodeFlow"
        } else {
            $false
        }
    }

    # Find inactive policies that target device code flow - for reporting if test fails
    $inactiveDeviceCodePolicies = $disabledPolicies | Where-Object {
        if ($_. conditions.authenticationFlows.transferMethods) {
            $transferMethods = $_.conditions.authenticationFlows.transferMethods -split ','
            $transferMethods -contains "deviceCodeFlow"
        } else {
            $false
        }
    }

    # Determine pass/fail status based on requirements
    $result = $false
    if ($deviceCodeFlowPolicies.Count -gt 0) {
        # Check if any policy has block control (only block is considered valid)
        $properlyConfiguredPolicies = $deviceCodeFlowPolicies | Where-Object {
            $policy = $_
            # Check for block control only
            $hasBlockControl = $policy.grantControls.builtInControls -contains "block"

            # If the policy has block control, set result to true
            if ($hasBlockControl) {
                $result = $true
                return $true
            }

            return $false
        }
    }

    # Prepare the markdown output, starting with the main check result
    $testResultMarkdown = ""

    if ($result) {
        $testResultMarkdown += "Device code flow is properly restricted in the tenant.%TestResult%"
    }
    else {
        if ($deviceCodeFlowPolicies.Count -eq 0) {
            $testResultMarkdown += "No Conditional Access policies found that target device code flow authentication.%TestResult%"
        } else {
            $testResultMarkdown += "Device code flow policies exist but none are configured to block device code flow.%TestResult%"
        }
    }

    # Build the detailed sections of the markdown
    $mdInfo = ""

    # Include CA policies information
    $mdInfo += "`n## Conditional Access Policies targeting Device Code Flow`n`n"

    if ($deviceCodeFlowPolicies.Count -gt 0) {
        $mdInfo += "| Policy Name | Status | Target Users | Target Resources | Grant Controls |`n"
        $mdInfo += "| :---------- | :----- | :----------- | :--------------- | :------------ |`n"

        foreach ($policy in $deviceCodeFlowPolicies) {
            $portalLink = "https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/{0}" -f $policy.id

            # Format target users
            $targetUsers = "All Users"
            if ($policy.conditions.users.includeUsers -contains "All") {
                $targetUsers = "All Users"
            }
            elseif ($policy.conditions.users.includeUsers.Count -gt 0) {
                $targetUsers = "Included: $($policy.conditions.users.includeUsers.Count) users/groups"
            }

            if ($policy.conditions.users.excludeUsers.Count -gt 0) {
                $targetUsers += ", Excluded: $($policy.conditions.users.excludeUsers.Count) users/groups"
            }

            # Format target resources
            $targetResources = "All Apps"
            if ($policy.conditions.applications.includeApplications -contains "All") {
                $targetResources = "All Applications"
            }
            elseif ($policy.conditions.applications.includeApplications.Count -gt 0) {
                $targetResources = "Included: $($policy.conditions.applications.includeApplications.Count) apps"
            }

            if ($policy.conditions.applications.excludeApplications.Count -gt 0) {
                $targetResources += ", Excluded: $($policy.conditions.applications.excludeApplications.Count) apps"
            }

            # Format grant controls
            $grantControls = "None"
            if ($policy.grantControls.builtInControls -contains "block") {
                $grantControls = "Block"
            }
            elseif ($policy.grantControls.builtInControls.Count -gt 0) {
                $grantControls = $policy.grantControls.builtInControls -join ", "
            }

            if ($policy.grantControls.operator -eq "OR") {
                $grantControls += " (ANY)"
            } else {
                $grantControls += " (ALL)"
            }

            $mdInfo += "| [$(Get-SafeMarkdown($policy.displayName))]($portalLink) | Enabled | $targetUsers | $targetResources | $grantControls |`n"
        }
    } else {
        $mdInfo += "No Conditional Access policies targeting device code flow authentication were found.`n"
    }

    # If the test failed and there are inactive policies, show them
    if (!$result && $inactiveDeviceCodePolicies.Count -gt 0) {
        $mdInfo += "`n## Inactive Conditional Access Policies targeting Device Code Flow`n"
        $mdInfo += "These policies are not contributing to your security posture because they are not enabled:`n`n"

        $mdInfo += "| Policy Name | Status | Target Users | Target Resources | Grant Controls |`n"
        $mdInfo += "| :---------- | :----- | :----------- | :--------------- | :------------ |`n"

        foreach ($policy in $inactiveDeviceCodePolicies) {
            $portalLink = "https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/{0}" -f $policy.id

            # Format policy status
            $status = if ($policy.state -eq "enabledForReportingButNotEnforced") { "Report-only" } else { "Disabled" }

            # Format target users
            $targetUsers = "All Users"
            if ($policy.conditions.users.includeUsers -contains "All") {
                $targetUsers = "All Users"
            }
            elseif ($policy.conditions.users.includeUsers.Count -gt 0) {
                $targetUsers = "Included: $($policy.conditions.users.includeUsers.Count) users/groups"
            }

            if ($policy.conditions.users.excludeUsers.Count -gt 0) {
                $targetUsers += ", Excluded: $($policy.conditions.users.excludeUsers.Count) users/groups"
            }

            # Format target resources
            $targetResources = "All Apps"
            if ($policy.conditions.applications.includeApplications -contains "All") {
                $targetResources = "All Applications"
            }
            elseif ($policy.conditions.applications.includeApplications.Count -gt 0) {
                $targetResources = "Included: $($policy.conditions.applications.Count) apps"
            }

            if ($policy.conditions.applications.excludeApplications.Count -gt 0) {
                $targetResources += ", Excluded: $($policy.conditions.applications.excludeApplications.Count) apps"
            }

            # Format grant controls
            $grantControls = "None"
            if ($policy.grantControls.builtInControls -contains "block") {
                $grantControls = "Block"
            }
            elseif ($policy.grantControls.builtInControls.Count -gt 0) {
                $grantControls = $policy.grantControls.builtInControls -join ", "
            }

            if ($policy.grantControls.operator -eq "OR") {
                $grantControls += " (ANY)"
            } else {
                $grantControls += " (ALL)"
            }

            $mdInfo += "| [$(Get-SafeMarkdown($policy.displayName))]($portalLink) | $status | $targetUsers | $targetResources | $grantControls |`n"
        }
    }

    # Replace the placeholder with the detailed information
    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo

    $passed = $result

    Add-ZtTestResultDetail -TestId '21808' -Title "Restrict device code flow" `
        -UserImpact Medium -Risk High -ImplementationCost Low `
        -AppliesTo Identity -Tag ConditionalAccess `
        -Status $passed -Result $testResultMarkdown
}
