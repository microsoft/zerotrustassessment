<#
.SYNOPSIS
    Conditional Access RMS Exclusions
#>

function Test-Assessment-35001 {
    [ZtTest(
        Category = 'Entra',
        ImplementationCost = 'Low',
        MinimumLicense = ('Microsoft 365 E5'),
        Pillar = 'Data',
        RiskLevel = 'High',
        SfiPillar = '',
        TenantType = ('Workforce','External'),
        TestId = 35001,
        Title = 'Conditional Access RMS Exclusions',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking Conditional Access RMS Exclusions'
    Write-ZtProgress -Activity $activity -Status 'Getting Conditional Access policies'

    $rmsAppId = '00000012-0000-0000-c000-000000000000'
    $blockingPolicies = @()
    $policies = @()
    $errorMsg = $null

    try {
        # Query: Get all enabled Conditional Access policies
        $policies = Get-ZtConditionalAccessPolicy | Where-Object { $_.state -eq 'enabled' }
    }
    catch {
        $errorMsg = $_
        Write-PSFMessage "Error querying Conditional Access policies: $_" -Level Error
    }
    #endregion Data Collection

    #region Assessment Logic
    if ($errorMsg) {
        $passed = $false
    }
    else {
        foreach ($policy in $policies) {
            $includedApps = $policy.conditions.applications.includeApplications
            $excludedApps = $policy.conditions.applications.excludeApplications

            $isRmsIncluded = ($includedApps -contains 'All') -or ($includedApps -contains $rmsAppId)
            $isRmsExcluded = $excludedApps -contains $rmsAppId

            if ($isRmsIncluded -and -not $isRmsExcluded) {
                $blockingPolicies += $policy
            }
        }

        $passed = $blockingPolicies.Count -eq 0
    }
    #endregion Assessment Logic

    #region Report Generation
    if ($errorMsg) {
        $testResultMarkdown = "❌ Unable to determine RMS exclusion status due to error: $errorMsg"
    }
    elseif ($passed) {
        $testResultMarkdown = "✅ Microsoft Rights Management Service (RMS) is excluded from Conditional Access policies that enforce authentication controls."
    }
    else {
        $testResultMarkdown = "❌ Microsoft Rights Management Service (RMS) is blocked or restricted by one or more Conditional Access policies.`n`n"
        $testResultMarkdown += "**Policies Affecting RMS:**`n`n"
        $testResultMarkdown += "| Policy Name | State | RMS Targeted | RMS Excluded | Grant Controls | Session Controls |`n"
        $testResultMarkdown += "| :--- | :--- | :--- | :--- | :--- | :--- |`n"

        foreach ($policy in $blockingPolicies) {
            $policyLink = "https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/$($policy.id)"

            # Grant Controls
            $grantControls = @()
            if ($policy.grantControls) {
                if ($policy.grantControls.builtInControls) { $grantControls += $policy.grantControls.builtInControls }
                if ($policy.grantControls.termsOfUse) { $grantControls += "Terms of Use" }
            }
            $grantDisplay = if ($grantControls.Count -gt 0) { $grantControls -join ', ' } else { 'None' }

            # Session Controls
            $sessionControls = @()
            if ($policy.sessionControls) {
                foreach ($prop in $policy.sessionControls.PSObject.Properties) {
                    $name = $prop.Name
                    $value = $prop.Value

                    if ($null -eq $value) { continue }

                    $isSet = $false
                    if ($value -is [bool]) {
                        $isSet = $value
                    }
                    else {
                        if ($value.PSObject.Properties.Match('isEnabled')) {
                            $isSet = $value.isEnabled
                        }
                        else {
                            $isSet = $true
                        }
                    }

                    if ($isSet) {
                        $displayName = $name -replace '([a-z])([A-Z])', '$1 $2'
                        $displayName = $displayName.Substring(0,1).ToUpper() + $displayName.Substring(1)

                        switch ($name) {
                            'disableResilienceDefaults' { $displayName = 'Disable Resilience Defaults' }
                            'cloudAppSecurity' { $displayName = 'Cloud App Security' }
                            'signInFrequency' { $displayName = 'Sign-in Frequency' }
                            'persistentBrowser' { $displayName = 'Persistent Browser' }
                            'continuousAccessEvaluation' { $displayName = 'Customize Continuous Access Evaluation' }
                            'globalSecureAccessFilteringProfile' { $displayName = 'Global Secure Access Security Profile' }
                            'secureSignInSession' { $displayName = 'Secure Sign-in Session' }
                            'applicationEnforcedRestrictions' { $displayName = 'App Enforced Restrictions' }
                            'networkAccessSecurity' { $displayName = 'Network Access Security' }
                        }
                        $sessionControls += $displayName
                    }
                }
            }
            $sessionDisplay = if ($sessionControls.Count -gt 0) { $sessionControls -join ', ' } else { 'None' }

            $policyName = Get-SafeMarkdown -Text $policy.displayName

            $testResultMarkdown += "| [$policyName]($policyLink) | $($policy.state) | Yes | No | $grantDisplay | $sessionDisplay |`n"
        }
    }
    #endregion Report Generation

    $testResultDetail = @{
        TestId             = '35001'
        Title              = 'Conditional Access RMS Exclusions'
        Status             = $passed
        Result             = $testResultMarkdown
    }
    Add-ZtTestResultDetail @testResultDetail
}
