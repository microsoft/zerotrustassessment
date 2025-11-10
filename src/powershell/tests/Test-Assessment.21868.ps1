<#
.SYNOPSIS

#>

function Test-Assessment-21868 {
    [ZtTest(
    	Category = 'External collaboration',
    	ImplementationCost = 'Medium',
    	MinimumLicense = ('Free'),
    	Pillar = 'Identity',
    	RiskLevel = 'Medium',
    	SfiPillar = 'Protect tenants and isolate production systems',
    	TenantType = ('Workforce','External'),
    	TestId = 21868,
    	Title = 'Guests do not own apps in the tenant',
    	UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param(
        $Database
    )

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "Checking Guests don't own apps in the tenant"
    Write-ZtProgress -Activity $activity -Status "Getting applications and service principals"

    $sqlApp = @'
    select distinct ON (id) id, appId, displayName
    from Application
    order by displayName DESC
'@

    $sqlSP = @'
    select distinct ON (id) id, appId, displayName
    from ServicePrincipal
    order by displayName DESC
'@

    $allApp = Invoke-DatabaseQuery -Database $Database -Sql $sqlApp
    $allSP = Invoke-DatabaseQuery -Database $Database -Sql $sqlSP

    $queryParameters = '$select=id,displayName,userPrincipalName'

    # Initialize lists for guest owners only
    $guestAppOwners = [System.Collections.Generic.List[object]]::new()
    $guestSpOwners = [System.Collections.Generic.List[object]]::new()

    # Get all guest users first (more efficient than repeated queries)
    $sqlGuests = @"
SELECT id, userPrincipalName, displayName
FROM User
WHERE userType = 'Guest'
"@
    $guestUsers = Invoke-DatabaseQuery -Database $Database -Sql $sqlGuests

    # Create a HashSet for fast lookups
    $guestUserIds = [System.Collections.Generic.HashSet[string]]::new()
    foreach ($guest in $guestUsers) {
        [void]$guestUserIds.Add($guest.id)
    }

    # Filter owners to only include guests
    foreach ($app in $allApp) {
        $owners = Invoke-ZtGraphRequest -RelativeUri "applications/$($app.id)/owners/microsoft.graph.user?$queryParameters" -ApiVersion 'v1.0'
        if ($owners) {
            foreach ($owner in $owners) {
                $owner | Add-Member -MemberType NoteProperty -Name 'appDisplayName' -Value $app.displayName -Force -PassThru |
                    Add-Member -MemberType NoteProperty -Name 'appObjectId' -Value $app.id -Force -PassThru |
                        Add-Member -MemberType NoteProperty -Name 'appId' -Value $app.appId -Force
                if ($guestUserIds.Contains($owner.id)) {
                    $guestAppOwners.Add($owner)
                }
            }
        }
    }

    foreach ($sp in $allSP) {
        $owners = Invoke-ZtGraphRequest -RelativeUri "servicePrincipals/$($sp.id)/owners/microsoft.graph.user?$queryParameters" -ApiVersion 'v1.0'
        if ($owners) {
            foreach ($owner in $owners) {
                $owner | Add-Member -MemberType NoteProperty -Name 'spDisplayName' -Value $sp.displayName -Force -PassThru |
                    Add-Member -MemberType NoteProperty -Name 'spObjectId' -Value $sp.id -Force -PassThru |
                        Add-Member -MemberType NoteProperty -Name 'spAppId' -Value $sp.appId -Force
                if ($guestUserIds.Contains($owner.id)) {
                    $guestSpOwners.Add($owner)
                }
            }
        }
    }

    $hasGuestAppOwners = $guestAppOwners.Count -gt 0
    $hasGuestSpOwners = $guestSpOwners.Count -gt 0

    if ($hasGuestAppOwners -or $hasGuestSpOwners) {
        $passed = $false
        $testResultMarkdown = "Guest users own applications or service principals.`n`n%TestResult%"
    }
    else {
        $passed = $true
        $testResultMarkdown = "No guest users own any applications or service principals in the tenant."
    }

    # Build the detailed sections of the markdown

    # Create a here-string with format placeholders {0}, {1}, etc.

    if ($hasGuestAppOwners -and $hasGuestSpOwners) {
        $formatTemplate = @"
##  Guest users own both applications and service principals in your tenant

### Applications owned by guest users
| User Display Name | User Principal Name | Application |
| :---------------- | :------------------ | :---------- |
{0}

### Service principals owned by guest users
| User Display Name | User Principal Name | Service Principal |
| :---------------- | :------------------ | :---------------- |
{1}

"@
        $appPortalLink = 'https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Owners/appId/{0}/isMSAApp~/false'
        $spPortalLink = 'https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Owners/objectId/{0}/appId/{1}/preferredSingleSignOnMode~/null/servicePrincipalType/Application/fromNav/'

        $appTable = ($guestAppOwners | ForEach-Object { "| $($_.displayName) | $($_.userPrincipalName) | [$(Get-SafeMarkdown($_.appDisplayName))]($($appPortalLink -f $($_.appId))) |" }) -join "`n"
        $spTable = ($guestSpOwners | ForEach-Object { "| $($_.displayName) | $($_.userPrincipalName) | [$(Get-SafeMarkdown($_.spDisplayName))]($($spPortalLink -f $($_.spObjectId), $($_.spAppId))) |" }) -join "`n"

        $mdInfo = $formatTemplate -f $appTable, $spTable
    }
    elseif ($hasGuestAppOwners) {
        $formatTemplate = @"
## Guest users own applications in your tenant

### Applications owned by guest users
| User Display Name | User Principal Name | Application |
| :---------------- | :------------------ | :---------- |
{0}

"@
        $appPortalLink = 'https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Owners/appId/{0}/isMSAApp~/false'

        $appTable = ($guestAppOwners | ForEach-Object { "| $($_.displayName) | $($_.userPrincipalName) | [$(Get-SafeMarkdown($_.appDisplayName))]($($appPortalLink -f $($_.appId))) |" }) -join "`n"

        $mdInfo = $formatTemplate -f $appTable
    }
    elseif ($hasGuestSpOwners) {
        $formatTemplate = @"
## Guest users own service principals in your tenant

### Service principals owned by guest users
| User Display Name | User Principal Name | Service Principal |
| :---------------- | :------------------ | :---------------- |
{0}

"@
        $spPortalLink = 'https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Owners/objectId/{0}/appId/{1}/preferredSingleSignOnMode~/null/servicePrincipalType/Application/fromNav/'

        $spTable = ($guestSpOwners | ForEach-Object { "| $($_.displayName) | $($_.userPrincipalName) | [$(Get-SafeMarkdown($_.spDisplayName))]($($spPortalLink -f $($_.spObjectId), $($_.spAppId))) |" }) -join "`n"

        $mdInfo = $formatTemplate -f $spTable
    }

    # Replace the placeholder with the detailed information
    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo

    $params = @{
        TestId             = '21868'
        Title              = "Guests don't own apps in the tenant"
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
