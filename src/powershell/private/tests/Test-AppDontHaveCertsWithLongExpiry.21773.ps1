
<#
.SYNOPSIS

#>

function Test-AppDontHaveCertsWithLongExpiry {
    [CmdletBinding()]
    param(
        $Database
    )


    $sqlApp = @"
    select distinct * from
        (select id, appId, displayName, signInAudience,
        try_cast(unnest(keyCredentials).endDateTime as date) as keyEndDateTime,
        current_date + interval 180 day maxExpiryDate
        from Application)
    where keyEndDateTime > maxExpiryDate
    order by displayName
"@

    $sqlSP = @"
    select distinct * from
        (select id, appId, displayName, appOwnerOrganizationId, signInAudience,
        try_cast(unnest(keyCredentials).endDateTime as date) as keyEndDateTime,
        current_date + interval 180 day maxExpiryDate
        from ServicePrincipal)
    where keyEndDateTime > maxExpiryDate
    order by displayName
"@
    $resultsApp = Invoke-DatabaseQuery -Database $Database -Sql $sqlApp
    $resultsSP = Invoke-DatabaseQuery -Database $Database -Sql $sqlSP

    $passed = ($resultsApp.Count -eq 0) -and ($resultsSP.Count -eq 0)

    if ($passed) {
        $testResultMarkdown += "Applications in your tenant don’t have certificates valid for more than 180 days."
    }
    else {
        $testResultMarkdown += "The following applications and service principals have certificates longer than 180 days`n`n%TestResult%"
    }

    $mdInfo = "`n## Applications with long-lived credentials`n`n"
    $mdInfo += "| Application | Certificate Expiry |`n"
    $mdInfo += "| :--- | :--- |`n"
    foreach ($item in $resultsApp) {
        $portalLink = "https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/{0}" -f $item.appId
        $mdInfo += "| [$(Get-SafeMarkdown($item.displayName))]($portalLink) | $($item.keyEndDateTime) |`n"
    }

    $mdInfo += "`n`n## Service Principals with long-lived credentials`n`n"
    $mdInfo += "| Service Principal | Tenant | Certificate Expiry |`n"
    $mdInfo += "| :--- | :--- | :--- |`n"
    foreach ($item in $resultsSP) {
        $tenant = Get-ZtTenant -tenantId $item.appOwnerOrganizationId
        $portalLink = "https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId/$($item.id)/appId/$($item.appId)/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/"
        $mdInfo += "| [$(Get-SafeMarkdown($item.displayName))]($portalLink) | $(Get-SafeMarkdown($tenant.displayName)) | $($item.keyEndDateTime) |`n"
    }

    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo

    Add-ZtTestResultDetail -TestId '21773' -Title 'Applications don''t have certificates with expiration longer than 180 days' `
        -UserImpact Medium -Risk High -ImplementationCost Medium `
        -AppliesTo Entra -Tag Application `
        -Status $passed -Result $testResultMarkdown
}

function Get-SafeMarkdown($text) {
    $text = $text -replace "\[", "\["
    $text = $text -replace "\]", "\]"
    return $text
}
