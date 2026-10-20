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
    TenantType = ('Workforce', 'External'),
    TestId = 21868,
    Title = 'Guests don''t own apps in the tenant',
    UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param(
        $Database
    )

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "Checking Guests don't own apps in the tenant"
    Write-ZtProgress -Activity $activity -Status "Getting applications and service principals"

    $sqlAppOwners = @'
with applicationOwners as (
    select
        id as appObjectId,
        appId,
        displayName as appDisplayName,
        unnest(from_json(
            case
                when json_type(owners) = 'ARRAY' then owners
                else json_array(owners)
            end,
            '[{"id":"VARCHAR"}]'
        )).id as ownerId
    from Application
    where owners is not null
)
select
    users.id,
    users.displayName,
    users.userPrincipalName,
    applicationOwners.appDisplayName,
    applicationOwners.appObjectId,
    applicationOwners.appId
from applicationOwners
inner join User users on users.id = applicationOwners.ownerId
where users.userType = 'Guest'
'@

    $sqlSpOwners = @'
with servicePrincipalOwners as (
    select
        id as spObjectId,
        appId as spAppId,
        displayName as spDisplayName,
        unnest(from_json(
            case
                when json_type(owners) = 'ARRAY' then owners
                else json_array(owners)
            end,
            '[{"id":"VARCHAR"}]'
        )).id as ownerId
    from ServicePrincipal
    where owners is not null
)
select
    users.id,
    users.displayName,
    users.userPrincipalName,
    servicePrincipalOwners.spDisplayName,
    servicePrincipalOwners.spObjectId,
    servicePrincipalOwners.spAppId
from servicePrincipalOwners
inner join User users on users.id = servicePrincipalOwners.ownerId
where users.userType = 'Guest'
'@

    $guestAppOwners = @(Invoke-DatabaseQuery -Database $Database -Sql $sqlAppOwners)
    $guestSpOwners = @(Invoke-DatabaseQuery -Database $Database -Sql $sqlSpOwners)
    #endregion Data Collection

    #region Assessment Logic
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
    #endregion Assessment Logic

    #region Report Generation
    if (-not $passed) {
        $appPortalLink = 'https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Owners/appId/{0}/isMSAApp~/false'
        $spPortalLink = 'https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Owners/objectId/{0}/appId/{1}/preferredSingleSignOnMode~/null/servicePrincipalType/Application/fromNav/'
        $reportSections = [System.Collections.Generic.List[string]]::new()

        if ($hasGuestAppOwners) {
            $appRows = ($guestAppOwners | ForEach-Object {
                $ownerDisplayName = Get-SafeMarkdown $_.displayName
                $ownerUpn = Get-SafeMarkdown $_.userPrincipalName
                $applicationName = Get-SafeMarkdown $_.appDisplayName
                $applicationLink = $appPortalLink -f $_.appId

                "| $ownerDisplayName | $ownerUpn | [$applicationName]($applicationLink) |"
            }) -join "`n"
            $reportSections.Add(@"
### Applications owned by guest users
| User Display Name | User Principal Name | Application |
| :---------------- | :------------------ | :---------- |
$appRows
"@)
        }

        if ($hasGuestSpOwners) {
            $spRows = ($guestSpOwners | ForEach-Object {
                $ownerDisplayName = Get-SafeMarkdown $_.displayName
                $ownerUpn = Get-SafeMarkdown $_.userPrincipalName
                $servicePrincipalName = Get-SafeMarkdown $_.spDisplayName
                $servicePrincipalLink = $spPortalLink -f $_.spObjectId, $_.spAppId

                "| $ownerDisplayName | $ownerUpn | [$servicePrincipalName]($servicePrincipalLink) |"
            }) -join "`n"
            $reportSections.Add(@"
### Service principals owned by guest users
| User Display Name | User Principal Name | Service Principal |
| :---------------- | :------------------ | :---------------- |
$spRows
"@)
        }

        $reportTitle = if ($hasGuestAppOwners -and $hasGuestSpOwners) {
            'Guest users own both applications and service principals in your tenant'
        }
        elseif ($hasGuestAppOwners) {
            'Guest users own applications in your tenant'
        }
        else {
            'Guest users own service principals in your tenant'
        }

        $mdInfo = "## $reportTitle`n`n$($reportSections -join "`n")"
        $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    }
    #endregion Report Generation

    $params = @{
        TestId = '21868'
        Title  = "Guests don't own apps in the tenant"
        Status = $passed
        Result = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
