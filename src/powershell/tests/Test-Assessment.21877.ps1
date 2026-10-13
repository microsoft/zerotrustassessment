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
    $guestUsers = @(Invoke-DatabaseQuery -Database $Database -Sql $sqlGuests)
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

    $guestsWithoutSponsors = [System.Collections.Generic.List[object]]::new()
    $sponsorlessLimit = 20

    for ($offset = 0; $offset -lt $totalGuestCount -and $guestsWithoutSponsors.Count -lt $sponsorlessLimit; $offset += 100) {
        $lastIndex = [Math]::Min($offset + 99, $totalGuestCount - 1)
        $batchGuests = @($guestUsers[$offset..$lastIndex])
        $batchResults = Invoke-ZtGraphBatchRequest -Path 'users/{0}?$select=id,displayName,userPrincipalName,userType&$expand=sponsors($select=id)' -ArgumentList $batchGuests -Properties id -ApiVersion 'v1.0' -Matched -ErrorAction Stop

        foreach ($batchResult in $batchResults) {
            if (-not $batchResult.Success) {
                throw "Failed to get sponsors for guest $($batchResult.Argument.id): $($batchResult.Status)"
            }

            $guestUserWithSponsors = $batchResult.Result | Select-Object -First 1
            if (-not $guestUserWithSponsors.sponsors -or $guestUserWithSponsors.sponsors.Count -eq 0) {
                $guestsWithoutSponsors.Add($guestUserWithSponsors)
                if ($guestsWithoutSponsors.Count -ge $sponsorlessLimit) {
                    break
                }
            }
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
- $(if ($guestsWithoutSponsorsCount -eq $sponsorlessLimit) { 'Found at least 20 without sponsors' } else { "Found $guestsWithoutSponsorsCount without sponsors" })

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
