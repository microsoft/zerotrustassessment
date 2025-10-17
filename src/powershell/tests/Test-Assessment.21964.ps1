<#
.SYNOPSIS
    Checks Enable protected actions to secure Conditional Access policy creation and changes
#>

#region Helper Functions
function Get-AuthContextDetails {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [array]$AuthContextId
    )

    # Return null if $AuthContextId is null or empty
    if ($null -eq $AuthContextId -or $AuthContextId.Count -eq 0) {
        return $null
    }

    # Format auth context IDs for filter query
    $formattedIds = $AuthContextId | ForEach-Object { "'$_'" }
    $filterQuery = $formattedIds -join ','

    # Get authentication context details
    $authContextDetails = Invoke-ZtGraphRequest -RelativeUri "identity/conditionalAccess/authenticationContextClassReferences?`$filter=id in ($filterQuery)" -ApiVersion beta

    return $authContextDetails
}
function Test-ProtectedActionPolicyCompliance {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [AllowNull()]
        [AllowEmptyCollection()]
        [array]$Policies
    )

    $results = @{
        HasEnabledPolicies = $false
        AllHaveAuthStrength = $false
        AllHaveSessionControls = $false
        AllHaveDeviceFilters = $false
        HasPhishingResistantMethods = $false
        TotalPolicies = 0
        EnabledPolicies = 0
    }

    if ($null -eq $Policies -or $Policies.Count -eq 0) {
        return $results
    }

    # Get unique policies based on policy ID
    $uniquePolicies = $Policies | Where-Object { $null -ne $_.OriginalPolicy } | Group-Object -Property { $_.OriginalPolicy.id } | ForEach-Object { $_.Group[0] }

    if ($null -eq $uniquePolicies -or $uniquePolicies.Count -eq 0) {
        return $results
    }

    $results.TotalPolicies = $uniquePolicies.Count
    $enabledPolicies = @($uniquePolicies | Where-Object { $null -ne $_.OriginalPolicy -and $_.OriginalPolicy.state -eq 'enabled' })
    $results.EnabledPolicies = $enabledPolicies.Count
    $results.HasEnabledPolicies = $enabledPolicies.Count -gt 0

    # If no enabled policies, return with all false
    if ($enabledPolicies.Count -eq 0) {
        return $results
    }

    # Check if all enabled policies have required controls (no null values allowed)
    # Count how many policies are missing each control
    $missingAuthStrength = @($Policies | Where-Object { $null -ne $_.OriginalPolicy -and $null -eq $_.OriginalPolicy.grantControls.'authenticationStrength@odata.context' }).Count
    $missingSessionControls = @($Policies | Where-Object { $null -ne $_.OriginalPolicy -and $null -eq $_.OriginalPolicy.sessionControls.signInFrequency }).Count
    $missingDeviceFilters = @($Policies | Where-Object { $null -ne $_.OriginalPolicy -and $null -eq $_.OriginalPolicy.conditions.devices }).Count

    # All policies must have these controls (zero missing = all have it)
    $results.AllHaveAuthStrength = $missingAuthStrength -eq 0
    $results.AllHaveSessionControls = $missingSessionControls -eq 0
    $results.AllHaveDeviceFilters = $missingDeviceFilters -eq 0

    # Check if authentication strength uses phishing-resistant methods (only if all have auth strength)
    if ($results.AllHaveAuthStrength) {
        $requiredMethods = @('windowsHelloForBusiness', 'fido2', 'x509CertificateMultiFactor', 'certificateBasedAuthenticationPki', 'deviceBasedPush')
        $authStrengthPolicies = Invoke-ZtGraphRequest -RelativeUri 'identity/conditionalAccess/authenticationStrength/policies' -ApiVersion beta -Filter "policyType eq 'builtIn'"
        foreach ($authPolicy in $authStrengthPolicies) {
            if ($authPolicy.allowedCombinations) {
                foreach ($combination in $authPolicy.allowedCombinations) {
                    if ($requiredMethods -contains $combination) {
                        $results.HasPhishingResistantMethods = $true
                        break
                    }
                }
                if ($results.HasPhishingResistantMethods) { break }
            }
        }
    }

    return $results
}
function Get-ProtectedActionCAPolicy {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$AuthenticationContextId,
        [Parameter(Mandatory = $true)]
        [object]$Action
    )

    # Get protected action CA Policy details
    $filter = "conditions/applications/includeAuthenticationContextClassReferences/any(c:c eq '$AuthenticationContextId')"
    $policyResult = Invoke-ZtGraphRequest -RelativeUri "identity/conditionalAccess/policies" -ApiVersion Beta -Filter $filter

    $results = @()
    foreach ($policy in $policyResult) {
        # Create a custom object to avoid modifying the original policy object
        $policyWithProtectedAction = [PSCustomObject]@{
            ProtectedActionName = $Action.name
            ProtectedActionDescription = $Action.description
            OriginalPolicy = $policy
        }
        $results += $policyWithProtectedAction
    }

    return $results
}
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

    $activity = 'Checking Enable protected actions to secure Conditional Access policy creation and changes'
    $testResultMarkdown = ""
    Write-ZtProgress -Activity $activity -Status "Getting policy"

    # Protected actions for Conditional Access policy operations
    $protectedActions = @(
        'microsoft.directory-conditionalAccessPolicies-basic-update-patch',
        'microsoft.directory-conditionalAccessPolicies-create-post',
        'microsoft.directory-conditionalAccessPolicies-delete-delete',
        'microsoft.directory-resourceNamespaces-resourceActions-authenticationContext-update-post'
    )

    # Get protected action settings for each action
    $protectedActionResults = @()
    foreach ($action in $protectedActions) {
        #Write-ZtProgress -Activity $activity -Status "Checking protected action: $action"

        $actionResult = Invoke-ZtGraphRequest -RelativeUri "roleManagement/directory/resourceNamespaces/microsoft.directory/resourceActions/$action" -ApiVersion beta -Select "authenticationContextId,isAuthenticationContextSettable,name,description"
        $protectedActionResults += $actionResult
    }

    # Check if all protected actions have authentication context configured
    $unprotectedActions = $protectedActionResults | Where-Object { [string]::IsNullOrEmpty($_.authenticationContextId) }
    $unprotectedActionsResult = $unprotectedActions.Count -eq 0

    # For each protected action, check if there is a Conditional Access policy targeting its authenticationContextId and if any are enabled
    $policiesPerAction = @()
    foreach ($action in $protectedActionResults) {
            # Skip if authenticationContextId is null or empty
            if (-not [string]::IsNullOrEmpty($action.authenticationContextId)) {
                $policiesPerAction += Get-ProtectedActionCAPolicy -AuthenticationContextId $action.authenticationContextId -Action $action
            }
    }
    if( $policiesPerAction.Count -eq 0) {
        $testResultMarkdown = "## Conditional Access Policies by Protected Action`n`n"
        $testResultMarkdown += "*No Conditional Access policies found for any protected actions.*`n`n"
    }
    # Check compliance for ALL policies together (not per action)
    $protectedActionCAPolicyComplaince = Test-ProtectedActionPolicyCompliance -Policies $policiesPerAction
    $caPolicyResult = $protectedActionCAPolicyComplaince.HasEnabledPolicies
    $caPolicyRequireAuthStrength = $protectedActionCAPolicyComplaince.AllHaveAuthStrength
    $caPolicyHasSessionControls = $protectedActionCAPolicyComplaince.AllHaveSessionControls
    $caAllowedCombinationResult = $protectedActionCAPolicyComplaince.HasPhishingResistantMethods

    $testResultMarkdown += "`n### Conditional Access Policies by Protected Action`n`n"

    # Group policies by protected action
    $groupedPolicies = $policiesPerAction | Group-Object -Property ProtectedActionName

    foreach ($action in $protectedActionResults) {
        # Check if authentication context is configured
        $hasAuthContext = -not [string]::IsNullOrEmpty($action.authenticationContextId)

        if (-not $hasAuthContext) {
            $testResultMarkdown += "#### $($action.description) - ❌ Fail`n`n"
            $testResultMarkdown += "*Authentication context not configured for this protected action.*`n`n"
            continue
        }

        # Get auth context details
        $authContext = Get-AuthContextDetails -AuthContextId $action.authenticationContextId
        $authContextInfo = if ($authContext) {
            "**Auth Context:** $($authContext.displayName) (ID: $($authContext.id))"
        } else {
            "**Auth Context ID:** $($action.authenticationContextId)"
        }
        $actionPolicies = $groupedPolicies | Where-Object { ($_.Name -eq $action.name) }

        # Use overall compliance result (not per-action check)
        $status = if ($authContext -and ($actionPolicies.Group.OriginalPolicy.state -eq 'enabled')) {
            '✅ Pass'
        } else {
            '❌ Fail'
        }

        $testResultMarkdown += "#### $($action.description) - $status`n`n"
        $testResultMarkdown += "$authContextInfo`n`n"

        if ($actionPolicies -and $actionPolicies.Group.Count -gt 0) {
            $testResultMarkdown += "| Display Name | State | Authentication Context | Authentication Strength | Device Filters | SignIn Frequency |`n"
            $testResultMarkdown += "| :--- | :--- | :--- | :--- | :--- | :--- |`n"

            foreach ($policy in @($actionPolicies.Group)) {
                $authStrength = '✅'
                $devices = '✅'
                $signInFrequency = '✅'
                $caPolicyAuthContext = Get-AuthContextDetails -AuthContextId $policy.OriginalPolicy.conditions.applications.includeAuthenticationContextClassReferences

                if ($null -eq $policy.OriginalPolicy.grantControls.'authenticationStrength@odata.context') {
                    $authStrength = '❌'
                }
                if ($null -eq $policy.OriginalPolicy.conditions.devices) {
                    $devices = '❌'
                }
                if ($null -eq $policy.OriginalPolicy.sessionControls) {
                    $signInFrequency = '❌'
                }
                if ($null -eq $policy.OriginalPolicy.conditions.applications.includeAuthenticationContextClassReferences) {
                    $caPolicyAuthContext = '❌'
                }

                $portalLink = "https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/$($policy.id)"
                $testResultMarkdown += "| [$(Get-SafeMarkdown $policy.OriginalPolicy.displayName)]($portalLink) | $(Get-FormattedPolicyState -PolicyState $policy.OriginalPolicy.state) | $($caPolicyAuthContext.displayName -join ',') | $authStrength | $devices | $signInFrequency |`n"
            }
            $testResultMarkdown += "`n"
        }
        else {
            $testResultMarkdown += "*No Conditional Access policies found for this protected action.*`n`n"
        }
    }

    $passed = $unprotectedActionsResult -and $caPolicyResult -and  (($caPolicyRequireAuthStrength -and $caAllowedCombinationResult) -or $caPolicyHasSessionControls)
    $params = @{
            Status = $passed
            Result = $testResultMarkdown
        }
    if (!$passed) {
        $params.CustomStatus = 'Investigate'
    }

    Add-ZtTestResultDetail @params
}
