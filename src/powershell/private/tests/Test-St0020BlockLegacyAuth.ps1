<#
.SYNOPSIS
    Checks that legacy auth is blocked.
#>

function Test-St0020BlockLegacyAuth {
    [CmdletBinding()]
    param()

    $caps = Invoke-ZtGraphRequest -RelativeUri 'identity/conditionalAccess/policies' -ApiVersion beta

    $blockPolicies = $caps | Where-Object {`
            $_.grantControls.builtInControls -contains "block" -and `
            $_.conditions.clientAppTypes -contains "exchangeActiveSync" -and `
            $_.conditions.clientAppTypes -contains "other" }


    $passed = $blockPolicies.conditions.users.includeUsers -contains "All" -and $blockPolicies.state -eq "enabled"

    if ($passed) {
        $testResultMarkdown = "Tenant is configured to block legacy authentication for all users.`n`n%TestResult%"
    }
    elseif (($blockPolicies | Measure-Object).Count -ge 1) {
        $testResultMarkdown = "Tenant has a policy to block legacy authentication but does not target all users or is not enabled.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "Tenant does not have any conditional access policies that block legacy authentication."
    }


    Add-ZtTestResultDetail -TestId 'ST0020' -Title 'Block legacy authentication' -Impact High `
        -Likelihood HighlyLikely -AppliesTo Entra -Tag User, Credential `
        -Status $passed -Result $testResultMarkdown -GraphObjectType ConditionalAccess -GraphObjects $blockPolicies
}
