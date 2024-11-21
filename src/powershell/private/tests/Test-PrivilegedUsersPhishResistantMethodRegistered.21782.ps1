
<#
.SYNOPSIS

#>

function Test-PrivilegedUsersPhishResistantMethodRegistered {
    [CmdletBinding()]
    param(
        $Database
    )


    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "Checking phishing resistant authentication for privileged roles"
    Write-ZtProgress -Activity $activity -Status "Getting authentication methods"

    $sql = @"
select distinct id, userDisplayName, roleDisplayName, methodsRegistered, list_has_any(['passKeyDeviceBound', 'passKeyDeviceBoundAuthenticator', 'windowsHelloForBusiness'], methodsRegistered) as phishResistantAuthMethod
from UserRegistrationDetails u
    inner join vwRole r on u.id = r.principalId
"@
    $results = Invoke-DatabaseQuery -Database $Database -Sql $sql

    $totalUserCount = $results.Length
    $phishResistantPrivUsers = $results | Where-Object { $_.phishResistantAuthMethod }
    $phishablePrivUsers = $results | Where-Object { !$_.phishResistantAuthMethod }

    $phishablePrivUserCount = $phishablePrivUsers.Length
    $phishResistantPrivUserCount = $phishResistantPrivUsers.Length

    $passed = $totalUserCount -eq $phishResistantPrivUserCount

    if ($passed) {
        $testResultMarkdown += "Validated that all privileged users have registered phishing resistant authentication methods.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown += "Found privileged users that have not yet registered phishing resistant authentication methods`n`n%TestResult%"
    }

    $mdInfo = "## Privileged users`n`n"

    if ($passed) {
        $mdInfo += "All privileged registered phishing resistant authentication methods.`n`n"
    }
    else{
        $mdInfo += "Found $phishablePrivUserCount privileged users that have not registered phishing resistant authentication methods.`n`n"
    }

    $mdInfo += "User | Role Name | Phishing resistant method registered |`n"
    $mdInfo += "| :--- | :--- | :---: |`n"

    $userLinkFormat = "https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/{0}/hidePreviewBanner~/true"


    foreach ($user in $phishablePrivUsers | Sort-Object displayName) {
        $userLink = $userLinkFormat -f $user.id
        $mdInfo += "|[$($user.userDisplayName)]($userLink)| $($user.roleDisplayName) | ❌ |`n"
    }

    foreach ($user in $phishResistantPrivUsers | Sort-Object displayName) {
        $userLink = $userLinkFormat -f $user.id
        $mdInfo += "|[$($user.userDisplayName)]($userLink)| $($user.roleDisplayName) | ✅ |`n"
    }

    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo

    Add-ZtTestResultDetail -TestId '21781' -Title 'Privileged accounts have phishing-resistant methods registered' `
        -UserImpact Low -Risk High -ImplementationCost Medium `
        -AppliesTo Identity -Tag Credential `
        -Status $passed -Result $testResultMarkdown
}
