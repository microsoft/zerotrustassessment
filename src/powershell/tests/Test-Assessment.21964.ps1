<#
.SYNOPSIS

#>

function Test-Assessment-21964 {
    [ZtTest(
        Category = 'Access control',
        ImplementationCost = 'Low',
        Pillar = 'Identity',
        RiskLevel = 'Low',
        SfiPillar = 'Protect identities and secrets',
        TenantType = ('Workforce', 'External'),
        TestId = 21964,
        Title = 'Enable protected actions to secure Conditional Access policy creation and changes',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "Checking Enable protected actions to secure Conditional Access policy creation and changes"
    Write-ZtProgress -Activity $activity -Status "Getting policy"

    # Protected actions for Conditional Access policy operations
    $protectedActions = @(
        "microsoft.directory-conditionalAccessPolicies-basic-update-patch",
        "microsoft.directory-conditionalAccessPolicies-create-post",
        "microsoft.directory-conditionalAccessPolicies-delete-delete",
        "microsoft.directory-resourceNamespaces-resourceActions-authenticationContext-update-post"
    )

    # Get protected action settings for each action
    $protectedActionResults = @()
    foreach ($action in $protectedActions) {
        #Write-ZtProgress -Activity $activity -Status "Checking protected action: $action"

        $actionResult = Invoke-ZtGraphRequest -RelativeUri "roleManagement/directory/resourceNamespaces/microsoft.directory/resourceActions/$action" -ApiVersion beta -Select "authenticationContextId,isAuthenticationContextSettable,name"
        $protectedActionResults += $actionResult
    }

    # Check if all protected actions have authentication context configured
    $unprotectedActions = $protectedActionResults | Where-Object { [string]::IsNullOrEmpty($_.authenticationContextId) }
    $query1 = $unprotectedActions.Count -eq 0
    $passed = $query1
    if ($query1) {
        $testResultMarkdown += "All protected actions for Conditional Access policy operations have authentication context configured ✅"
    }
    else {
        $unprotectedCount = $unprotectedActions.Count
        $testResultMarkdown = "Found $unprotectedCount protected actions without authentication context configured ❌`n`n"
        $testResultMarkdown += "## Unprotected Actions`n`n"
        $testResultMarkdown += "| Action | Name | Authentication Context Settable |`n"
        $testResultMarkdown += "| :--- | :--- | :--- |`n"

        foreach ($action in $unprotectedActions) {
            if ($action.isAuthenticationContextSettable) {
                $settable = "✅ Yes"
            }
            else {
                "❌ No"
            }
            $testResultMarkdown += "| $($action.name) | $($action.name) | $settable |`n"
        }
        Add-ZtTestResultDetail -TestId '21964' -Title "Enable protected actions to secure Conditional Access policy creation and changes" `
            -UserImpact Low -Risk Low -ImplementationCost Low `
            -AppliesTo Identity -Tag Identity `
            -Status $passed -Result $testResultMarkdown
        return
    }
    # For each protected action, check if there is a Conditional Access policy targeting its authenticationContextId and if any are enabled
    $policiesPerAction = @()
    $query2 = $true
    foreach ($action in $protectedActionResults) {
        if (-not [string]::IsNullOrEmpty($action.authenticationContextId)) {
            $filter = "conditions/applications/includeAuthenticationContextClassReferences/any(c:c eq '$($action.authenticationContextId)')"
            $policyResult = Invoke-ZtGraphRequest -RelativeUri "identity/conditionalAccess/policies" -ApiVersion Beta -Select "id,displayName,state,conditions" -Filter $filter
            $policiesPerAction += $policyResult
            $enabledPolicies = $policyResult | Where-Object { $_.state -eq 'enabled' }
            if (($policyResult.Count -eq 0) -or ($enabledPolicies.Count -eq 0)) {
                $query2 = $false
                break
            }
        }
    }
    $passed = $query2
    if ($query2) {
        $testResultMarkdown += "All Conditional Access policies with protected actions are enabled "
    }
    else {
        $testResultMarkdown = $null
        $unprotectedActions = $policiesPerAction | Where-Object { $_.state -eq 'disabled' }
        $testResultMarkdown = "Found Conditional Access policies with protected actions disabled `n`n"
        $testResultMarkdown += "## Unprotected Actions`n`n"
        $testResultMarkdown += "| Display Name | State | `n"
        $testResultMarkdown += "| :--- | :--- |`n"

        foreach ($action in $unprotectedActions) {
            Write-Host $action -ForegroundColor Yellow
            $testResultMarkdown += "| $($action.displayName) | $(Get-FormattedPolicyState -PolicyState $action.state)| `n"
        }
        Add-ZtTestResultDetail -TestId '21964' -Title "Enable protected actions to secure Conditional Access policy creation and changes" `
            -UserImpact Low -Risk Low -ImplementationCost Low `
            -AppliesTo Identity -Tag Identity `
            -Status $passed -Result $testResultMarkdown
        #return
    }
    # Q3: For each enabled policy, check if it requires authentication strength
    $query3 = $true
    $query4 = $true
    $query5 = $true

    $testResultMarkdown = "Found Conditional Access policies without authentication strength | device filters | SignIn frequency configured `n`n"
    $testResultMarkdown += "| Display Name | State | Authentication Strength | Device Filters | SignIn Frequency |`n"
    $testResultMarkdown += "| :--- | :--- | :--- | :--- | :--- |`n"

    foreach ($policy in $policiesPerAction) {
        $policyDetails = Invoke-ZtGraphRequest -RelativeUri "identity/conditionalAccess/policies/$($policy.id)" -ApiVersion Beta -Select "grantControls,conditions,sessionControls,displayName,state"
        foreach ($tempPolicyDetails in $policyDetails) {
            Write-Host $policyDetails
            $authStrength = '✅'
            $devices = '✅'
            $signInFrequency = '✅'
            if ($null -eq $policyDetails.grantControls.'authenticationStrength@odata.context') {
                $query3 = $false
                $authStrength = '❌'
            }
            if ($null -eq $policyDetails.conditions.devices) {
                $query4 = $false
                $devices = '❌'
            }
            if ($null -eq $policyDetails.sessionControls) {
                $query5 = $false
                $signInFrequency = '❌'
            }
            $testResultMarkdown += "| $($tempPolicyDetails.displayName) | $(Get-FormattedPolicyState -PolicyState $tempPolicyDetails.state) | $authStrength | $devices | $signInFrequency |`n"
        }
    }
    $passed = $query3 -and $query4 -and $query5
    if ($passed) {
        $testResultMarkdown = $null
        $testResultMarkdown += "`nAll Conditional Access policies with protected actions require authentication strength, have device filters, and have SignIn frequency configured ✅"
    }
    else {
        Add-ZtTestResultDetail -TestId '21964' -Title "Enable protected actions to secure Conditional Access policy creation and changes" `
            -UserImpact Low -Risk Low -ImplementationCost Low `
            -AppliesTo Identity -Tag Identity `
            -Status $passed -Result $testResultMarkdown
        #return
    }

    # Q6: Check allowedCombinations for Passwordless MFA and Phishing-resistant MFA methods
    $requiredMethods = @('windowsHelloForBusiness', 'fido2', 'x509CertificateMultiFactor', 'certificateBasedAuthenticationPki', 'deviceBasedPush') -join '|'
    $authStrengthPolicies = Invoke-ZtGraphRequest -RelativeUri "identity/conditionalAccess/authenticationStrength/policies" -ApiVersion beta -Filter "policyType eq 'builtIn'"
    $query6 = $false
    foreach ($policy in $authStrengthPolicies) {
        if ($policy.allowedCombinations) {
            foreach ($combination in $policy.allowedCombinations) {
                    if ($combination -match $requiredMethods) {
                        $query6 = $true
                        break

                    }
                    else {
                        $query6 = $false
                    }

            }
        }
    }
    $passed = $query6
    if ($query6) {
        $testResultMarkdown = $null
        $testResultMarkdown += "`nAuthentication strength policies (built-in) include Passwordless MFA or Phishing-resistant MFA methods ✅"
    }
    else {
        $testResultMarkdown = $null
        $testResultMarkdown += "`nNo built-in authentication strength policies include Passwordless MFA or Phishing-resistant MFA methods ❌"
        Add-ZtTestResultDetail -TestId '21964' -Title "Enable protected actions to secure Conditional Access policy creation and changes" `
            -UserImpact Low -Risk Low -ImplementationCost Low `
            -AppliesTo Identity -Tag Identity `
            -Status $passed -Result $testResultMarkdown
        return
    }

    $passed = $query1 -and $query2 -and $query3 -and $query4 -and $query5 -and $query6
    Add-ZtTestResultDetail -TestId '21964' -Title "Enable protected actions to secure Conditional Access policy creation and changes" `
        -UserImpact Low -Risk Low -ImplementationCost Low `
        -AppliesTo Identity -Tag Identity `
        -Status $passed -Result $testResultMarkdown
}
