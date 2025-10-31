<#
.SYNOPSIS
Tests if all guest users have assigned sponsors in the tenant.
#>

function Test-Assessment-21877 {
    [ZtTest(
    	Category = 'Application management',
    	ImplementationCost = 'Medium',
    	Pillar = 'Identity',
    	RiskLevel = 'Medium',
    	SfiPillar = 'Protect tenants and isolate production systems',
    	TenantType = ('Workforce','External'),
    	TestId = 21877,
    	Title = 'All guests have a sponsor',
    	UserImpact = 'Medium'
    )]
    [CmdletBinding()]
    param(
        $Database
    )

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose
    if ((Get-MgContext).Environment -ne 'Global') {
        Write-PSFMessage "This test is only applicable to the Global environment." -Tag Test -Level VeryVerbose
        return
    }

    $activity = "Checking All guests have a sponsor"
    Write-ZtProgress -Activity $activity -Status "Getting guest users"

    # Get all guest users
    $sqlGuests = @"
SELECT id, userPrincipalName, displayName, userType
FROM User
WHERE userType = 'Guest'
"@
    $guestUsers = Invoke-DatabaseQuery -Database $Database -Sql $sqlGuests
    $totalGuestCount = $guestUsers.Count

    # Early return if no guests exist
    if ($totalGuestCount -eq 0) {
        $testParams = @{
            TestId             = '21877'
            Title              = 'All guests have a sponsor'
            UserImpact         = 'Medium'
            Risk               = 'Medium'
            ImplementationCost = 'Medium'
            AppliesTo          = 'Identity'
            Tag                = 'Identity'
            Status             = $true
            Result             = "✅ No guest accounts found in the tenant."
        }
        Add-ZtTestResultDetail @testParams
        return
    }

    Write-ZtProgress -Activity $activity -Status "Checking sponsors for $totalGuestCount guest users"

    # Process guests and check sponsors efficiently
    $guestsWithoutSponsors = [System.Collections.Generic.List[object]]::new()
    $guestsWithSponsorsCount = 0

    foreach ($guest in $guestUsers) {
        try {
            # Get the sponsors for the guest user
            $guestUserWithSponsors = Invoke-ZtGraphRequest -RelativeUri "users/$($guest.id)?`$expand=sponsors" -ApiVersion 'v1.0'

            # Check if guest has sponsors
            if ($guestUserWithSponsors.sponsors -and $guestUserWithSponsors.sponsors.Count -gt 0) {
                $guestsWithSponsorsCount++
            }
            else {
                $guestsWithoutSponsors.Add($guestUserWithSponsors)
            }
        }
        catch {
            Write-PSFMessage "Failed to get sponsors for guest $($guest.userPrincipalName): $($_.Exception.Message)" -Level Verbose
            # Treat as guest without sponsor if API call fails
            $guestsWithoutSponsors.Add($guest)
        }
    }

    $guestsWithoutSponsorsCount = $guestsWithoutSponsors.Count
    $passed = $guestsWithoutSponsorsCount -eq 0

    # Build result markdown
    if ($passed) {
        $testResultMarkdown = "✅ All guest accounts in the tenant have an assigned sponsor."
    }
    else {
        # Build table rows efficiently using StringBuilder
        $tableRowsBuilder = [System.Text.StringBuilder]::new()

        foreach ($guest in $guestsWithoutSponsors) {
            $portalLink = 'https://entra.microsoft.com/#view/Microsoft_AAD_UsersAndTenants/UserProfileMenuBlade/~/overview/userId/{0}/hidePreviewBanner~/true' -f $guest.id
            $displayName = Get-SafeMarkdown $guest.displayName
            [void]$tableRowsBuilder.AppendLine("| [$displayName]($portalLink) | $($guest.userPrincipalName) |")
        }

        $detailedReport = @"
## Guest users without sponsors

- Total count of guests in the tenant: $totalGuestCount
- Total count of guests with sponsors: $guestsWithSponsorsCount
- Total count of guests without sponsors: $guestsWithoutSponsorsCount

| User Display Name | User Principal Name |
| :---------------- | :------------------ |
$($tableRowsBuilder.ToString())
"@

        $testResultMarkdown = "❌ One or more guest accounts have no sponsor recorded.`n`n$detailedReport"
    }

    $testParams = @{
        TestId             = '21877'
        Title              = 'All guests have a sponsor'
        UserImpact         = 'Medium'
        Risk               = 'Medium'
        ImplementationCost = 'Medium'
        AppliesTo          = 'Identity'
        Tag                = 'Identity'
        Status             = $passed
        Result             = $testResultMarkdown
    }
    Add-ZtTestResultDetail @testParams
}
