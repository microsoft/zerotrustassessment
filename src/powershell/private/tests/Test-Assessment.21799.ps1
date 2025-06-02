<#
.SYNOPSIS

#>

function Test-Assessment-21799 {
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "Checking Block high risk sign-ins"
    Write-ZtProgress -Activity $activity -Status "Getting policy"

    $authMethodPolicy = Invoke-ZtGraphRequest -RelativeUri "policies/authenticationMethodsPolicy" -ApiVersion 'v1.0'
    $allCAPolicies = Invoke-ZtGraphRequest -RelativeUri "identity/conditionalAccess/policies" -ApiVersion 'v1.0'
    $matchedPolicies = $null

    if (($authMethodPolicy.authenticationMethodConfigurations.state -eq 'enabled').count -gt 0) {
        # Local filtering for high risk sign-ins - only consider enabled policies
        $matchedPolicies = $allCAPolicies | Where-Object {
            $_.conditions.signInRiskLevels -eq 'high' -and
            ($_.conditions.users.includeUsers -contains 'All') -and
            ($_.grantControls.builtInControls -contains 'block' -or $_.grantControls.builtInControls -contains 'mfa' -or $null -ne $_.grantControls.authenticationStrength) -and
            ($_.state -eq 'enabled')
        }
    }
    else {
        # Local filtering for high risk sign-ins - only consider enabled policies
        $matchedPolicies = $allCAPolicies | Where-Object {
            $_.conditions.signInRiskLevels -eq 'high' -and
            ($_.conditions.users.includeUsers -contains 'All') -and
            ($_.grantControls.builtInControls -contains 'block') -and
            ($_.state -eq 'enabled')
        }
    }

    $testResultMarkdown = ""

    if ($matchedPolicies.Count -gt 0) {
        $passed = $true
        $testResultMarkdown += "All high-risk sign-in attempts are mitigated by Conditional Access policies enforcing appropriate controls.%TestResult%"
    }
    else {
        $passed = $false
        $testResultMarkdown += "Some high-risk sign-in attempts are not adequately mitigated by Conditional Access policies."
    }


    # Build the detailed sections of the markdown

    # Define variables to insert into the format string
    $reportTitle = "Conditional Access Policies targeting high-risk sign-in attempts"
    $tableRows = ""

    if ($matchedPolicies.Count -gt 0) {
        # Create a here-string with format placeholders {0}, {1}, etc.
        $formatTemplate = @'

## {0}


| Policy Name | Grant Controls | Target Users |
| :---------- | :------------- | :----------- |
{1}

'@

        foreach ($policy in $matchedPolicies) {
            $portalLink = "https://entra.microsoft.com/#view/Microsoft_AAD_ConditionalAccess/PolicyBlade/policyId/{0}" -f $policy.id

            $grantControls = switch ($policy.grantControls) {
                {$_.builtInControls -contains 'block'} {
                    "Block Access"
                }
                {$_.builtInControls -contains 'mfa'} {
                    "Require Multi-Factor Authentication"
                }
                {$null -ne $_.authenticationStrength} {
                    "Require Authentication Strength"
                }
            }

            $targetUsers = if ($policy.conditions.users.includeUsers -contains 'All') {
                "All Users"
            }
            else {
                $policy.conditions.users.includeUsers -join ', '
            }

            $tableRows += @"
| [$(Get-SafeMarkdown($policy.displayName))]($portalLink) | $grantControls | $targetUsers |`n
"@
        }

        # Format the template by replacing placeholders with values
        $mdInfo = $formatTemplate -f $reportTitle, $tableRows
    }
    else {
        $mdInfo = "Some high-risk sign-in attempts are not adequately mitigated by Conditional Access policies.`n"
    }

    # Replace the placeholder with the detailed information
    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo


    $params = @{
        TestId             = '21799'
        Title              = "Block high risk sign-ins"
        UserImpact         = 'Medium'
        Risk               = 'High'
        ImplementationCost = 'Medium'
        AppliesTo          = 'Identity'
        Tag                = 'Identity'
        Status             = $passed
        Result             = $testResultMarkdown
    }
    Add-ZtTestResultDetail @params
}
