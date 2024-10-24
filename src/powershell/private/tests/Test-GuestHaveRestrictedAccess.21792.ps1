
<#
.SYNOPSIS

#>

function Test-GuestHaveRestrictedAccess {
    [CmdletBinding()]
    param(
        $Database
    )

    Write-PSFMessage '🟦 Start' -Tag Test

    $guestRestrictedRoleId = "2af84b1e-32c8-42b7-82bc-daa82404023b"

    $result = Invoke-ZtGraphRequest -RelativeUri "policies/authorizationPolicy"

    $passed = $result.guestUserRoleId -eq $guestRestrictedRoleId

    if ($passed) {
        $testResultMarkdown += "✅ Validated guest user access is restricted."
    }
    else {
        $testResultMarkdown += "❌ Guest users can invite other guests`n`n%TestResult%"
    }

    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo

    Add-ZtTestResultDetail -TestId '21792' -Title 'Guests have restricted access to directory objects' `
        -UserImpact Medium -Risk Medium -ImplementationCost Low `
        -AppliesTo Entra -Tag Application `
        -Status $passed -Result $testResultMarkdown
}
