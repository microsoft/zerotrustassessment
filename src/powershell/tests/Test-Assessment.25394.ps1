<#
.SYNOPSIS
    Checks that Quick Access is bound to a Conditional Access policy.

.DESCRIPTION
    Verifies that the Quick Access application in Entra Private Access is protected by at least one enabled
    Conditional Access policy with grant controls configured. Quick Access without Conditional Access enforcement
    allows compromised credentials to access private resources without additional verification.

.NOTES
    Test ID: 25394
    Category: Private Access
    Required API: servicePrincipals (v1.0), identity/conditionalAccess/policies (v1.0)
#>

function Test-Assessment-25394 {
    [ZtTest(
        Category = 'Private Access',
        ImplementationCost = 'Low',
        MinimumLicense = ('Entra_Premium_Private_Access'),
        Pillar = 'Network',
        RiskLevel = 'High',
        SfiPillar = 'Protect networks',
        TenantType = ('Workforce', 'External'),
        TestId = '25394',
        Title = 'Quick Access is bound to a Conditional Access policy',
        UserImpact = 'Medium'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose
    $activity = 'Checking Quick Access Conditional Access policy binding'
    Write-ZtProgress -Activity $activity -Status 'Querying Quick Access application'

    # Q1: Find Quick Access application
    $quickAccessApp = Invoke-ZtGraphRequest -RelativeUri 'servicePrincipals' -Filter "tags/any(c:c eq 'NetworkAccessQuickAccessApplication')" -Select 'appId,displayName' -ApiVersion beta

    # Initialize test variables
    $testResultMarkdown = ''
    $passed = $false
    $quickAccessAppId = $null
    $quickAccessDisplayName = $null
    $applicablePolicies = @()
    #endregion Data Collection

    #region Assessment Logic
    # Assessment Logic 1: Check if Quick Access application exists
    if (-not $quickAccessApp -or $quickAccessApp.Count -eq 0) {
        $testResultMarkdown = "❌ No Quick Access application found with 'NetworkAccessQuickAccessApplication' tag."
        $passed = $false
    }
    else {
        $quickAccessAppId = $quickAccessApp.appId
        $quickAccessDisplayName = $quickAccessApp.displayName

        Write-ZtProgress -Activity $activity -Status "Checking Conditional Access policies for Quick Access"
        # Q2: Get all enabled Conditional Access policies
        $caaPolicies = Invoke-ZtGraphRequest -RelativeUri "identity/conditionalAccess/policies" -Filter "state eq 'enabled'" -ApiVersion beta

        # Assessment Logic 2: Check if Quick Access is protected by Conditional Access policies
        if ($caaPolicies -and $caaPolicies.Count -gt 0) {
            foreach ($policy in $caaPolicies) {
                # Check if policy targets "All" applications or includes Quick Access app
                if ($policy.conditions.applications.includeApplications -contains "All" -or
                    $policy.conditions.applications.includeApplications -contains $quickAccessAppId) {

                    # Check if grant controls are configured
                    if ($policy.grantControls -and
                        (($policy.grantControls.builtInControls -and $policy.grantControls.builtInControls.Count -gt 0) -or
                         ($policy.grantControls.authenticationStrength))) {

                        $policyInfo = [PSCustomObject]@{
                            DisplayName = $policy.displayName
                            Id = $policy.id
                            GrantControls = @()
                        }

                        # Collect built-in controls
                        if ($policy.grantControls.builtInControls) {
                            $policyInfo.GrantControls += $policy.grantControls.builtInControls
                        }

                        # Collect authentication strength if present
                        if ($policy.grantControls.authenticationStrength) {
                            $policyInfo.GrantControls += "AuthenticationStrength: $($policy.grantControls.authenticationStrength.displayName)"
                        }

                        $applicablePolicies += $policyInfo
                    }
                }
            }
        }

        # Determine pass/fail status
        if ($applicablePolicies.Count -gt 0) {
            $passed = $true
        }
        else {
            $passed = $false
        }

        # Build results table
        $testResultMarkdown += "`n| Setting | Value |`n"
        $testResultMarkdown += "|---------|-------|`n"
        $testResultMarkdown += "| Quick Access Application | $quickAccessDisplayName |`n"
        $testResultMarkdown += "| App ID | $quickAccessAppId |`n"
        $testResultMarkdown += "| Conditional Access Policies | $(if ($applicablePolicies.Count -gt 0) { $applicablePolicies.Count } else { "None" }) |`n`n"

        # Show applicable policies if any
        if ($applicablePolicies.Count -gt 0) {
            $testResultMarkdown += "### ✅ Applicable Conditional Access Policies`n`n"
            $testResultMarkdown += "| Policy Name | Policy ID | Grant Controls |`n"
            $testResultMarkdown += "|---|---|---|`n"
            foreach ($policy in $applicablePolicies) {
                $grantControlsStr = $([string]::Join(', ', $policy.GrantControls))
                $testResultMarkdown += "| $($policy.DisplayName) | $($policy.Id) | $grantControlsStr |`n"
            }
            $testResultMarkdown += "`n"
        }
        else {
            $testResultMarkdown += "### ❌ No Conditional Access Policies Found`n`n"
            $testResultMarkdown += "Quick Access application is not protected by any Conditional Access policies with grant controls.`n`n"
        }
    }
    #endregion Assessment Logic

    # Determine final pass/fail message
    if ($passed) {
        $testResultMarkdown = "✅ Quick Access is bound to a Conditional Access policy with grant controls.`n`n" + $testResultMarkdown
    }
    else {
        $testResultMarkdown = "❌ Quick Access is not bound to a Conditional Access policy with grant controls.`n`n" + $testResultMarkdown
    }

    $params = @{
        TestId = '25394'
        Title  = 'Quick Access is bound to a Conditional Access policy'
        Status = $passed
        Result = $testResultMarkdown
    }
    # Add test result details
    Add-ZtTestResultDetail @params

}
