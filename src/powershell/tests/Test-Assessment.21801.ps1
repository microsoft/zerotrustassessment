
<#
.SYNOPSIS
    Gets the authentication methods registered by all users.
#>

function Test-Assessment-21801 {
    [CmdletBinding()]
    param(
        $Database
    )

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "Checking phishing resistant authentication for user"
    Write-ZtProgress -Activity $activity -Status "Getting authentication methods"

    $EntraIDPlan = Get-ZtLicenseInformation -Product EntraID
    if ($EntraIDPlan -eq "Free") {
        Write-PSFMessage '🟦 Skipping: Requires Premium License' -Tag Test -Level VeryVerbose
        return
    }

    $sql = @"
select distinct u.id, u.displayName, list_has_any(['passKeyDeviceBound', 'passKeyDeviceBoundAuthenticator', 'windowsHelloForBusiness'], methodsRegistered) as phishResistantAuthMethod,
    u.signInActivity.lastSuccessfulSignInDateTime
from User u
    inner join UserRegistrationDetails ur on u.id = ur.id
where u.accountEnabled
"@
    $results = Invoke-DatabaseQuery -Database $Database -Sql $sql

    $totalUserCount = $results.Length
    $phishResistantUsers = $results | Where-Object { $_.phishResistantAuthMethod }
    $phishableUsers = $results | Where-Object { !$_.phishResistantAuthMethod }

    $phishResistantUserCount = $phishResistantPrivUsers.Length

    $passed = $totalUserCount -eq $phishResistantUserCount

    if ($passed) {
        $testResultMarkdown += "Validated that all users have registered phishing resistant authentication methods.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown += "Found users that have not yet registered phishing resistant authentication methods`n`n%TestResult%"
    }

    $mdInfo = "## Users strong authentication methods`n`n"

    if ($passed) {
        $mdInfo += "All users have registered phishing resistant authentication methods.`n`n"
    }
    else{
        $mdInfo += "Found users that have not registered phishing resistant authentication methods.`n`n"
    }


    $mdInfo += "User | Last sign in | Phishing resistant method registered |`n"
    $mdInfo += "| :--- | :--- | :---: |`n"

    $userLinkFormat = "https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/{0}/hidePreviewBanner~/true"


    foreach ($user in $phishableUsers | Sort-Object displayName) {
        $userLink = $userLinkFormat -f $user.id
        $lastSignInDate = Get-FormattedDate -Date $user.lastSuccessfulSignInDateTime
        $mdInfo += "|[$($user.displayName)]($userLink)| $lastSignInDate | ❌ |`n"
    }

    foreach ($user in $phishResistantUsers | Sort-Object displayName) {
        $userLink = $userLinkFormat -f $user.id
        $lastSignInDate = Get-FormattedDate -Date $user.lastSuccessfulSignInDateTime
        $mdInfo += "|[$($user.displayName)]($userLink)| $lastSignInDate | ✅ |`n"
    }

    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo

    Add-ZtTestResultDetail -TestId '21801' -Title 'Users have strong authentication methods configured ' `
        -UserImpact Medium -Risk Medium -ImplementationCost Medium `
        -AppliesTo Identity -Tag Credential `
        -Status $passed -Result $testResultMarkdown
}
