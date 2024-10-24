<#
.SYNOPSIS
    Checks that a guest user does not invite other guests.
#>

function Test-GuestCantInviteGuests{
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "Checking guest authorization policy"
    Write-ZtProgress -Activity $activity -Status "Getting policy"

    $result = Invoke-ZtGraphRequest -RelativeUri "policies/authorizationPolicy" -ApiVersion v1.0

    $passed = $result.allowInvitesFrom -eq "adminsAndGuestInviters"

    if ($passed) {
        $testResultMarkdown = "Tenant restricts who can invite guests:`n`n%TestResult%"
    } else {
        $testResultMarkdown = "Tenant allows any user (including other guests) to invite guests."
    }

    Add-ZtTestResultDetail -TestId '21791' -Title "Guest can’t invite other guests" `
        -UserImpact Medium -Risk Medium -ImplementationCost Low `
        -AppliesTo Entra -Tag ExternalCollaboration `
        -Status $passed -Result $testResultMarkdown
}
