<#
.SYNOPSIS

#>

function Test-Assessment-21811 {
    [CmdletBinding()]
    param(
        $Database
    )

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "Checking Password expiration is disabled"
    Write-ZtProgress -Activity $activity -Status "Getting policy"

    $domains = Invoke-ZtGraphRequest -RelativeUri "domains" -ApiVersion v1.0

    $misconfiguredDomains = $domains | Where-Object { $_.passwordValidityPeriodInDays -ne '2147483647' }

    $sql = @"
SELECT id, displayName, userPrincipalName, passwordPolicies
FROM User
"@

    $users = Invoke-DatabaseQuery -Database $database -Sql $sql

    $misconfiguredUsers = foreach ($user in $users) {
        $userDomain = $user.userPrincipalName.Split('@')[-1]
        $domainPolicy = $misconfiguredDomains | Where-Object { $_.id -eq $userDomain }
        if (
        ($user.passwordPolicies -notlike "*DisablePasswordExpiration*") -and
        ($domainPolicy)
        ) {
            $user | Add-Member -MemberType NoteProperty -Name DomainPolicy -Value $domainPolicy -PassThru
        }
    }

    if ($misconfiguredDomains -or $misconfiguredUsers) {
        $passed = $false
        $testResultMarkdown = "Found domains or users with password expiration still enabled.`n`n%TestResult%"
    }
    else {
        $passed = $true
        $testResultMarkdown = 'Password expiration is properly disabled across all domains and users.'
    }

    # Build the detailed sections of the markdown

    if ($misconfiguredDomains) {
        # Define variables to insert into the format string
        $reportTitle1 = "Domains with password expiration enabled"
        $tableRows1 = ""

        # Create a here-string with format placeholders {0}, {1}, etc.
        $formatTemplate1 = @'

## {0}

| Domain Name | Password Validity Interval |
| :---------- | :------------------------- |
{1}

'@

        foreach ($domain in $misconfiguredDomains) {
            $tableRows1 += @"
| $($domain.id) | $($domain.passwordValidityPeriodInDays) |`n
"@
        }

        # Format the template by replacing placeholders with values
        $mdInfo1 = $formatTemplate1 -f $reportTitle1, $tableRows1
    }

    if ($misconfiguredUsers) {
        # Build the detailed sections of the markdown

        # Define variables to insert into the format string
        $reportTitle2 = "Users with password expiration enabled"
        $tableRows2 = ""

        # Create a here-string with format placeholders {0}, {1}, etc.
        $formatTemplate2 = @'

## {0}

| Display Name | User Principal Name | User Password Expiration setting | Domain Password Expiration setting |
| :----------- | :------------------ | :------------------------------- | :--------------------------------- |
{1}

'@

        foreach ($misconfiguredUser in $misconfiguredUsers) {
            $portalLink = 'https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/overview/userId/{0}/hidePreviewBanner~/true' -f $misconfiguredUser.id
            $displayName = Get-SafeMarkdown $misconfiguredUser.displayName
            $userPrincipalName = $misconfiguredUser.userPrincipalName
            $userPasswordExpiration = $misconfiguredUser.passwordPolicies
            $domainPasswordExpiration = $misconfiguredUser.DomainPolicy.passwordValidityPeriodInDays
            $tableRows2 += @"
| [$displayName]($portalLink) | $userPrincipalName | $userPasswordExpiration | $domainPasswordExpiration |`n
"@
        }

        # Format the template by replacing placeholders with values
        $mdInfo2 = $formatTemplate2 -f $reportTitle2, $tableRows2
    }

    # Replace the placeholder with the detailed information
    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", ($mdInfo1 + $mdInfo2)


    $params = @{
        TestId             = '21811'
        Title              = 'Password expiration is disabled'
        UserImpact         = 'Low'
        Risk               = 'Medium'
        ImplementationCost = 'Low'
        AppliesTo          = 'Identity'
        Tag                = 'Identity'
        Status             = $passed
        Result             = $testResultMarkdown
    }
    Add-ZtTestResultDetail @params
}
