<#
.SYNOPSIS

#>

function Test-Assessment-21858 {
    [ZtTest(
    	Category = 'External collaboration',
    	ImplementationCost = 'Medium',
    	Pillar = 'Identity',
    	RiskLevel = 'Medium',
    	SfiPillar = 'Protect tenants and isolate production systems',
    	TenantType = ('Workforce','External'),
    	TestId = 21858,
    	Title = 'Inactive guest identities are disabled or removed from the tenant',
    	UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param(
        $Database
    )

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose
    if( -not (Get-ZtLicense EntraIDP1) ) {
        Add-ZtTestResultDetail -SkippedBecause NotLicensedEntraIDP1
        return
    }

    $activity = "Checking Inactive guest identities are removed from the tenant"
    Write-ZtProgress -Activity $activity -Status "Querying enabled guest users"

    $sql = @"
    SELECT id, displayName, userPrincipalName, accountEnabled, createdDateTime, externalUserState, signInActivity
    FROM User
    WHERE UserType = 'Guest' AND AccountEnabled = true
"@

    $enabledGuestUsers = Invoke-DatabaseQuery -Database $Database -Sql $sql

    if ($enabledGuestUsers) {
        $currentDate = Get-Date
        $inactiveGuests = @()

        foreach ($guest in $enabledGuestUsers) {
            $inactivityThresholdDays = 90
            $daysSinceLastActivity = $null
            $lastActivityDate = $null
            $activitySource = ""

            # Check if signInActivity property exists
            if ($guest.signInActivity.lastSignInDateTime -and $null -ne $guest.signInActivity.lastSignInDateTime) {
                # Use lastSignInDateTime from signInActivity
                $lastActivityDate = [DateTime]::Parse($guest.signInActivity.lastSignInDateTime)
                $daysSinceLastActivity = ($currentDate - $lastActivityDate).Days
                $activitySource = "last sign-in"
            }
            elseif ($guest.signInActivity.lastSuccessfulSignInDateTime -and $null -ne $guest.signInActivity.lastSuccessfulSignInDateTime) {
                # Evaluate lastSuccessfulSignInDateTime if lastSignInDateTime is not available
                $lastActivityDate = [DateTime]::Parse($guest.signInActivity.lastSuccessfulSignInDateTime)
                $daysSinceLastActivity = ($currentDate - $lastActivityDate).Days
                $activitySource = "last successful sign-in"
            }
            else {
                # signInActivity is null, calculate days since creation using createdDateTime
                $lastActivityDate = [DateTime]::Parse($guest.createdDateTime)
                $daysSinceLastActivity = ($currentDate - $lastActivityDate).Days
                $activitySource = "creation date (no sign-in activity)"
            }

            # if guests exist with no sign-in activity in the last $inactivityThresholdDays days add them to the list
            if ($daysSinceLastActivity -gt $inactivityThresholdDays) {
                $inactiveGuests += [PSCustomObject]@{
                    Guest                 = $guest
                    DaysSinceLastActivity = $daysSinceLastActivity
                    LastActivityDate      = $lastActivityDate
                    ActivitySource        = $activitySource
                }
            }
        }
        # Mark as FAIL if inactive guests exist
        if ($inactiveGuests.Count -gt 0) {
            $passed = $false
            $testResultMarkdown = "❌ **FAIL**: Found $($inactiveGuests.Count) inactive guest user(s) with no sign-in activity in the last $inactivityThresholdDays days:`n`n%TestResult%"
        }
        else {
            $passed = $true
            $testResultMarkdown = "✅ **PASS**: All enabled guest user(s) have been active within the last $inactivityThresholdDays days."
        }
    }
    else {
        $passed = $true   # Test passes if no enabled guests
        $testResultMarkdown = "✅ No guest users found in the tenant."
    }

    # Build the detailed sections of the markdown

    # Define variables to insert into the format string
    $reportTitle = "Inactive guest accounts in the tenant"
    $tableRows = ""

    if ($inactiveGuests.Count -gt 0) {
        # Create a here-string with format placeholders {0}, {1}, etc.
        $formatTemplate = @'

## {0}


| Display Name | User Principal Name | Last Sign-in Date | Created Date |
| :----------- | :------------------ | :---------------- | :----------- |
{1}

'@

        foreach ($inactiveGuest in $inactiveGuests) {
            $portalLink = 'https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/overview/userId/{0}/hidePreviewBanner~/true' -f $inactiveGuest.guest.id
            $displayName = Get-SafeMarkdown $inactiveGuest.guest.displayName
            $userPrincipalName = $inactiveGuest.guest.userPrincipalName
            $lastSignInDateTime = Get-FormattedDate $inactiveGuest.guest.signInActivity.lastSignInDateTime
            $createdDateTime = Get-FormattedDate $inactiveGuest.guest.createdDateTime
            $tableRows += @"
| [$displayName]($portalLink) | $userPrincipalName | $lastSignInDateTime | $createdDateTime |`n
"@
        }

        # Format the template by replacing placeholders with values
        $mdInfo = $formatTemplate -f $reportTitle, $tableRows
    }

    # Replace the placeholder with the detailed information
    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo

    $params = @{
        TestId             = '21858'
        Title              = 'Inactive guest identities are removed from the tenant'
        UserImpact         = 'Low'
        Risk               = 'Medium'
        ImplementationCost = 'Medium'
        AppliesTo          = 'Identity'
        Tag                = 'Identity'
        Status             = $passed
        Result             = $testResultMarkdown
    }
    Add-ZtTestResultDetail @params
}
