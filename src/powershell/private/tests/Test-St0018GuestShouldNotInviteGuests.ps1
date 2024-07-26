<#
.SYNOPSIS
    Checks that a guest user does not invite other guests.
#>

function Test-St0018GuestShouldNotInviteGuests{
    [CmdletBinding()]
    param()

    $result = Invoke-ZtGraphRequest -RelativeUri "policies/authorizationPolicy" -ApiVersion v1.0

    $testResult = $result.allowInvitesFrom -eq "adminsAndGuestInviters"

    if ($testResult) {
        $testResultMarkdown = "Tenant restricts who can invite guests:`n`n%TestResult%"
    } else {
        $testResultMarkdown = "Tenant allows any user (including other guests) to invite guests."
    }
    Add-ZtTestResultDetail -TestId 'ST0018' -Title 'Guests should not invite other guests' -Impact High -Likelihood HighlyLikely -AppliesTo Entra -Tag ExternalCollaboration -Result $testResultMarkdown
}
