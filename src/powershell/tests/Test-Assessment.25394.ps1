<#
.SYNOPSIS
    Checks that Quick Access is bound to a Conditional Access policy.

.DESCRIPTION
    Verifies that the Quick Access application in Entra Private Access is protected by at least one enabled
    Conditional Access policy with meaningful security controls (MFA, device compliance, or authentication strength).
    Quick Access without Conditional Access enforcement allows compromised credentials to access private resources
    without additional verification, creating security risks for internal resources.

.NOTES
    Test ID: 25394
    Category: Global Secure Access
    Required API: servicePrincipals (beta), identity/conditionalAccess/policies (beta), applications/{AppID}/onPremisesPublishing (beta)
#>

function Test-Assessment-25394 {
    [ZtTest(
        Category = 'Global Secure Access',
        ImplementationCost = 'Low',
        MinimumLicense = ('Entra_Premium_Private_Access', 'AAD_PREMIUM'),
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
    $activity = 'Checking Quick Access Conditional Access policy protection'
    Write-ZtProgress -Activity $activity -Status 'Querying Quick Access application'

    # Q1: Get Quick Access application
    $quickAccessApp = Invoke-ZtGraphRequest -RelativeUri 'servicePrincipals' -Filter "tags/any(c:c eq 'NetworkAccessQuickAccessApplication')" -Select 'appId,displayName,id' -ApiVersion beta
    $quickAccessAppId = $null
    if ($quickAccessApp -and $quickAccessApp.Count -gt 0) {
        $quickAccessAppId = $quickAccessApp.appId
    }

    # Q2: Get all enabled Conditional Access policies
    $caPolicies = $null
    if ($null -ne $quickAccessApp -and $quickAccessApp.Count -gt 0) {
        Write-ZtProgress -Activity $activity -Status 'Checking Conditional Access policies for Quick Access'
        $allCAPolicies = Get-ZtConditionalAccessPolicy
        $caPolicies = $allCAPolicies | Where-Object { $_.state -eq 'enabled' }
    }

    #endregion Data Collection

    #region Assessment Logic
    # Initialize test variables
    $testResultMarkdown = ''
    $passed = $false
    $applicablePolicies = @()

    # Check if Quick Access application exists
    if (-not $quickAccessApp -or $quickAccessApp.Count -eq 0) {
        $testResultMarkdown = "⚠️ No Quick Access application is configured, review the documentation on how to enable Quick Access if needed.`n`n%TestResult%"
    }
    else {
        # Check Conditional Access policy coverage
        if ($null -eq $caPolicies -or $caPolicies.Count -eq 0) {
            Write-PSFMessage 'Failed to retrieve Conditional Access policies or no policies are enabled' -Level Warning
            $passed = $false
            $testResultMarkdown = "❌ Quick Access application found without Conditional Access policy enforcement.`n`n%TestResult%"
        }
        else {
            foreach ($policy in $caPolicies) {
                $policyTargetsQuickAccess = $false
                # Check if "All" apps are targeted
                if ($policy.conditions.applications.includeApplications -contains 'All') {
                    $policyTargetsQuickAccess = $true
                }
                # Check if Quick Access appId is explicitly included
                elseif ($policy.conditions.applications.includeApplications -contains $quickAccessAppId) {
                    $policyTargetsQuickAccess = $true
                }

                if ($policyTargetsQuickAccess) {
                    # Verify meaningful grant controls
                    $hasMeaningfulControls = $false
                    $grantControlsList = @()

                    if ($null -ne $policy.grantControls) {
                        # Check for meaningful built-in controls
                        if ($null -ne $policy.grantControls.builtInControls -and $policy.grantControls.builtInControls.Count -gt 0) {
                            foreach ($control in $policy.grantControls.builtInControls) {
                                if ($control -in @('mfa', 'compliantDevice', 'domainJoinedDevice', 'approvedApplication')) {
                                    $hasMeaningfulControls = $true
                                }
                                $grantControlsList += $control
                            }
                        }

                        # Check for authentication strength
                        if ($null -ne $policy.grantControls.authenticationStrength) {
                            $hasMeaningfulControls = $true
                            if ($null -ne $policy.grantControls.authenticationStrength.displayName) {
                                $grantControlsList += "AuthenticationStrength: $($policy.grantControls.authenticationStrength.displayName)"
                            }
                        }
                    }

                    if ($hasMeaningfulControls) {
                        $policyInfo = [PSCustomObject]@{
                            DisplayName = $policy.displayName
                            Id = $policy.id
                            GrantControls = $grantControlsList
                        }
                        $applicablePolicies += $policyInfo
                    }
                }
            }
        }

        # Determine pass/fail status
        if ($applicablePolicies.Count -gt 0) {
            $passed = $true
            $testResultMarkdown = "✅ Quick Access application is protected by Conditional Access policies with authentication controls.`n`n%TestResult%"
        }
        else {
            $passed = $false
            $testResultMarkdown = "❌ Quick Access application found without Conditional Access policy enforcement.`n`n%TestResult%"
        }
    }
    #endregion Assessment Logic

    #region Report Generation
    # Build detailed markdown information
    $mdInfo = ''

    if ($null -ne $quickAccessApp -and $quickAccessApp.Count -gt 0) {
        $appPortalLink = "https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/overview/appId/$($quickAccessApp.appId)"
        $mdInfo += "**Quick Access application name:** [$(Get-SafeMarkdown -Text $quickAccessApp.displayName)]($appPortalLink)`n`n"

        # Show applicable policies if any
        if ($applicablePolicies.Count -gt 0) {
            $mdInfo += "### [Applicable Conditional Access policies](https://entra.microsoft.com/#view/Microsoft_AAD_IAM/QuickAccessMenuBlade/~/GlobalSecureAccess)`n`n"
            $mdInfo += "| Policy name | Grant controls configured |`n"
            $mdInfo += "| :---------- | :------------------------ |`n"

            foreach ($policy in $applicablePolicies) {
                $grantControlsStr = $([string]::Join(', ', $policy.GrantControls))
                # blade link for Conditional Access policy (fixed: no ~/ before policyId)
                $policyPortalLink = "https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/$($policy.Id)"
                $mdInfo += "| [$(Get-SafeMarkdown -Text $policy.DisplayName)]($policyPortalLink) | $grantControlsStr |`n"
            }
            $mdInfo += "`n"
        }
    }

    # Replace the placeholder with detailed information
    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '25394'
        Title  = 'Quick Access is protected by Conditional Access policies'
        Status = $passed
        Result = $testResultMarkdown
    }

    # Add Investigate status if Quick Access is not configured
    if (-not $quickAccessApp -or $quickAccessApp.Count -eq 0) {
        $params.CustomStatus = 'Investigate'
    }

    # Add test result details
    Add-ZtTestResultDetail @params

}
