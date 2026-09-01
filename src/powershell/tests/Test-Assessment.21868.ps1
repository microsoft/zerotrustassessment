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
    	Title = 'Guests don''t own apps in the tenant',
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

    Write-ZtProgress -Activity $activity -Status "Getting application owners"
    $guestAppOwners = @(Get-GuestResourceOwner -Resources $allApp -ResourceType 'applications' -GuestUserIds $guestUserIds `
            -DisplayNameProperty 'appDisplayName' -ObjectIdProperty 'appObjectId' -AppIdProperty 'appId')

    Write-ZtProgress -Activity $activity -Status "Getting service principal owners"
    $guestSpOwners = @(Get-GuestResourceOwner -Resources $allSP -ResourceType 'servicePrincipals' -GuestUserIds $guestUserIds `
            -DisplayNameProperty 'spDisplayName' -ObjectIdProperty 'spObjectId' -AppIdProperty 'spAppId')

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

function Get-GuestResourceOwner {
    [CmdletBinding()]
    param (
        [object[]] $Resources,

        [string] $ResourceType,

        [System.Collections.Generic.HashSet[string]] $GuestUserIds,

        [string] $DisplayNameProperty,

        [string] $ObjectIdProperty,

        [string] $AppIdProperty
    )

    $guestOwners = [System.Collections.Generic.List[object]]::new()
    if (-not $Resources) { return $guestOwners }

    $resourceById = @{}
    foreach ($resource in $Resources) { $resourceById[$resource.id] = $resource }

    $ownerPath = "$ResourceType/{0}/owners/microsoft.graph.user?`$select=id,displayName,userPrincipalName"
    $ownerResults = Invoke-ZtGraphBatchRequest -Path $ownerPath -ArgumentList $Resources.id -Matched -ErrorAction SilentlyContinue

    foreach ($result in $ownerResults) {
        if (-not $result.Success) { continue }
        $resource = $resourceById[$result.Argument]
        foreach ($owner in $result.Result) {
            if (-not $GuestUserIds.Contains($owner.id)) { continue }
            $owner | Add-Member -NotePropertyName $DisplayNameProperty -NotePropertyValue $resource.displayName -Force
            $owner | Add-Member -NotePropertyName $ObjectIdProperty -NotePropertyValue $resource.id -Force
            $owner | Add-Member -NotePropertyName $AppIdProperty -NotePropertyValue $resource.appId -Force
            $guestOwners.Add($owner)
        }
    }

    return $guestOwners
}
