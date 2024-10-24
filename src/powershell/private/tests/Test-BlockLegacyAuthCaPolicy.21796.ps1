<#
.SYNOPSIS
    Checks that legacy auth is blocked.
#>

function Test-BlockLegacyAuthCaPolicy {
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "Checking blocking of legacy authentication"
    Write-ZtProgress -Activity $activity -Status "Getting CA policies"

    $caps = Invoke-ZtGraphRequest -RelativeUri 'identity/conditionalAccess/policies' -ApiVersion beta

    $blockPolicies = $caps | Where-Object {`
            $_.grantControls.builtInControls -contains "block" -and `
            $_.conditions.clientAppTypes -contains "exchangeActiveSync" -and `
            $_.conditions.clientAppTypes -contains "other" }


    $passed = $blockPolicies.conditions.users.includeUsers -contains "All" -and $blockPolicies.state -eq "enabled"

    if ($passed) {
        $testResultMarkdown = "Conditional Access to block legacy Authentication are configured and enabled.`n`n%TestResult%"
    }
    elseif (($blockPolicies | Measure-Object).Count -ge 1) {
        $testResultMarkdown = "Policies to block legacy authentication were found but are not properly configured.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "No conditional access to block legacy authentication were found."
    }

    Add-ZtTestResultDetail -TestId '21796' -Title 'Block legacy authentication policies are configured' `
        -UserImpact Medium -Risk Medium -ImplementationCost Low `
        -AppliesTo Entra -Tag User, Credential `
        -Status $passed -Result $testResultMarkdown -GraphObjectType ConditionalAccess -GraphObjects $blockPolicies
}
