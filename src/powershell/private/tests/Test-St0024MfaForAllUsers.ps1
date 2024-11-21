<#
.SYNOPSIS
    Checks that MFA is enforced for all users.
#>

function Test-St0024MfaForAllUsers {
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "Checking MFA for all users"
    Write-ZtProgress -Activity $activity

    $caps = Invoke-ZtGraphRequest -RelativeUri 'identity/conditionalAccess/policies' -ApiVersion beta

    $mfaPolicies = $caps | Where-Object {`
            $_.grantControls.builtInControls -contains "mfa" -or `
            $_.grantControls.authenticationStrength }

    $mfaAllUsersPolicies = $mfaPolicies | Where-Object {`
            $_.conditions.users.includeUsers -contains "All" `
            -and $_.state -eq "enabled" `
            -and $_.conditions.users.includeUsers -contains "All" }

    $passed = ($mfaAllUsersPolicies | Measure-Object).Count -ge 1

    $totalMfaPolicies = ($mfaPolicies | Measure-Object).Count

    if ($passed) {
        $testResultMarkdown = "Tenant is configured to require multi-factor authentication for all users.`n`n%TestResult%"
        $mfaPolicies = $mfaAllUsersPolicies # Only show the policies that target all users
    }
    elseif ($totalMfaPolicies -ge 1) {
        $testResultMarkdown = "Tenant is configured to require multi-factor authentication but does not target all users and apps or is not enabled.`n`n"
        $testResultMarkdown += "Found $totalMfaPolicies policies requiring multi-factor authentication.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "Tenant does not have any conditional access policies that require multi-factor authentication."
    }

    Add-ZtTestResultDetail -TestId 'ST0024' -Title 'Users have strong authentication methods configured'`
        -UserImpact Medium -Risk Medium -ImplementationCost Low `
        -AppliesTo Identity -Tag User, Credential `
        -Status $passed -Result $testResultMarkdown -GraphObjectType ConditionalAccess -GraphObjects $mfaPolicies
}
