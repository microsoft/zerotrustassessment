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

    $passed = $result.allowInvitesFrom -ne "everyone"

    if ($passed) {

        Switch ($result.allowInvitesFrom) {
            'none' {
                $allowInvitesFromLabel = "No one in the organization can invite guest users including admins (most restrictive)"
            }
            'adminsAndGuestInviters' {
                $allowInvitesFromLabel = "Only users assigned to specific admin roles can invite guest users"
            }
            'adminsGuestInvitersAndAllMembers' {
                $allowInvitesFromLabel = "Member users and users assigned to specific admin roles can invite guest users including guests with member permissions"
            }
            default {
                $allowInvitesFromLabel = $result.allowInvitesFrom
            }
        }

        $testResultMarkdown = "Tenant restricts who can invite guests.`n`n"
        $testResultMarkdown += "**Guest invite settings**`n`n"
        $testResultMarkdown += "  * Guest invite restrictions → $allowInvitesFromLabel"
    } else {
        $testResultMarkdown = "Tenant allows any user (including other guests) to invite guests."
    }

    Add-ZtTestResultDetail -TestId '21791' -Title "Guest can’t invite other guests" `
        -UserImpact Medium -Risk Medium -ImplementationCost Low `
        -AppliesTo Identity -Tag ExternalCollaboration `
        -Status $passed -Result $testResultMarkdown
}
