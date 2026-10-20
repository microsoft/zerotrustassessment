
<#
.SYNOPSIS
    Gets the authentication methods registered by all users.
#>

function Test-Assessment-21801 {
    [ZtTest(
    	Category = 'Credential management',
    	ImplementationCost = 'Medium',
    	MinimumLicense = ('P1'),
    	Pillar = 'Identity',
    	RiskLevel = 'Medium',
    	SfiPillar = 'Protect identities and secrets',
    	TenantType = ('Workforce','External'),
    	TestId = 21801,
    	Title = 'Users have strong authentication methods configured',
    	UserImpact = 'Medium'
    )]
    [CmdletBinding()]
    param(
        $Database
    )

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "Checking phishing resistant authentication for user"
    Write-ZtProgress -Activity $activity -Status "Getting authentication methods"

    if( -not (Get-ZtLicense EntraIDP1) ) {
        Add-ZtTestResultDetail -SkippedBecause NotLicensedEntraIDP1
        return
    }

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
    #endregion Data Collection

    #region Assessment Logic
    $totalUserCount = @($results).Count
    $phishResistantUsers = $results | Where-Object { $_.phishResistantAuthMethod }
    $phishableUsers = $results | Where-Object { !$_.phishResistantAuthMethod }

    $phishResistantUserCount = @($phishResistantUsers).Count
    $phishableUserCount = @($phishableUsers).Count
    $passed = $totalUserCount -eq $phishResistantUserCount

    if ($passed) {
        $testResultMarkdown += "Validated that all users have registered phishing resistant authentication methods.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown += "Found users that have not yet registered phishing resistant authentication methods`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    $mdInfo = "## Users strong authentication methods`n`n"
    $mdInfo += "Total users assessed: $totalUserCount`n`n"
    $mdInfo += "Users with phishing-resistant authentication methods: $phishResistantUserCount`n`n"
    $mdInfo += "Users without phishing-resistant authentication methods: $phishableUserCount`n`n"

    $reportedPhishableUsers = @($phishableUsers | Sort-Object displayName, id | Select-Object -First 50)

    if ($reportedPhishableUsers.Count -gt 0) {
        $mdInfo += "User | Last sign in | Phishing resistant method registered |`n"
        $mdInfo += "| :--- | :--- | :---: |`n"

        $userLinkFormat = "https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/UserAuthMethods/userId/{0}/hidePreviewBanner~/true"
        foreach ($user in $reportedPhishableUsers) {
            $userLink = $userLinkFormat -f $user.id
            $lastSignInDate = Get-FormattedDate -Date $user.lastSuccessfulSignInDateTime
            $mdInfo += "|[$($user.displayName)]($userLink)| $lastSignInDate | ❌ |`n"
        }

        $omittedUserCount = $phishableUserCount - $reportedPhishableUsers.Count
        if ($omittedUserCount -gt 0) {
            $mdInfo += "`nShowing 50 of $phishableUserCount users without phishing-resistant authentication methods; $omittedUserCount more omitted.`n"
        }
    }

    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo
    #endregion Report Generation

    $params = @{
        TestId             = '21801'
        Title              = 'Users have strong authentication methods configured '
        Status             = $passed
        Result             = $testResultMarkdown
    }
    Add-ZtTestResultDetail @params
}
