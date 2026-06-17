<#
.SYNOPSIS
Tests if all guest users have assigned sponsors in the tenant.
#>

function Test-Assessment-21877 {
    [ZtTest(
    	Category = 'Application management',
    	ImplementationCost = 'Medium',
    	MinimumLicense = ('Free'),
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

    # Collect the IDs of guests with a confirmed sponsor. Anything not confirmed (a failed or empty
    # lookup) falls through to "without sponsor" by deriving that list from the original guest set.
    $sponsoredIds = [System.Collections.Generic.HashSet[string]]::new()

    $sponsorResults = Invoke-ZtGraphBatchRequest -Path "users/{0}?`$expand=sponsors" -ArgumentList $guestUsers.id -Matched -ErrorAction SilentlyContinue

    foreach ($result in $sponsorResults) {
        if (-not $result.Success) { continue }
        $guestUserWithSponsors = $result.Result | Select-Object -First 1
        if ($guestUserWithSponsors.sponsors.Count -gt 0) {
            [void]$sponsoredIds.Add($guestUserWithSponsors.id)
        }
    }

    $guestsWithSponsorsCount = $sponsoredIds.Count
    $guestsWithoutSponsors = @($guestUsers | Where-Object { -not $sponsoredIds.Contains($_.id) })
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
