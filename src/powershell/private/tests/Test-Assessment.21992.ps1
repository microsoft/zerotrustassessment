<#
.SYNOPSIS

#>

function Test-Assessment-21992{
    [CmdletBinding()]
    param(
        $Database
    )
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose
    $sqlApp = @"
    select distinct ON (id) * from
        (select id, appId, displayName, signInAudience,
        try_cast(unnest(keyCredentials).startDateTime as date) as keyStartDateTime,
        current_date - interval 180 day minStartDate
        from Application)
    where keyStartDateTime < minStartDate
    order by displayName, keyStartDateTime DESC
"@
    $sqlSP = @"
    select distinct ON (id) * from
        (select id, appId, displayName, appOwnerOrganizationId, signInAudience,
        try_cast(unnest(keyCredentials).startDateTime as date) as keyStartDateTime,
        current_date - interval 180 day minStartDate
        from ServicePrincipal)
    where keyStartDateTime < minStartDate
    order by displayName, keyStartDateTime DESC
"@
    $resultsApp = Invoke-DatabaseQuery -Database $Database -Sql $sqlApp
    $resultsSP = Invoke-DatabaseQuery -Database $Database -Sql $sqlSP

    $passed = ($resultsApp.Count -eq 0) -and ($resultsSP.Count -eq 0)
    if ($passed) {
        $testResultMarkdown += "Certificates for applications in your tenant have been issued within 180 days."
    }
    else {
        $testResultMarkdown += "Found $($resultsApp.Count) applications and $($resultsSP.Count) service principals in your tenant with certificates that have not been rotated within 180 days.`n`n%TestResult%"
    }
    if ($resultsApp.Count -gt 0) {
        $mdInfo = "`n## Applications with certificates that have not been rotated within 180 days`n`n"
        $mdInfo += "| Application | Certificate Start Date |`n"
        $mdInfo += "| :--- | :--- |`n"
        foreach ($item in $resultsApp) {
            $portalLink = "https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/{0}" -f $item.appId
            $mdInfo += "| [$(Get-SafeMarkdown($item.displayName))]($portalLink) | $(Get-FormattedDate($item.keyStartDateTime)) |`n"
        }
    }
    if ($resultsSP.Count -gt 0) {
        $mdInfo += "`n`n## Service principals with certificates that have not been rotated within 180 days`n`n"
        $mdInfo += "| Service principal | App owner tenant | Certificate Start Date |`n"
        $mdInfo += "| :--- | :--- | :--- |`n"
        foreach ($item in $resultsSP) {
            $tenant = Get-ZtTenant -tenantId $item.appOwnerOrganizationId
            $portalLink = "https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId/$($item.id)/appId/$($item.appId)/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/"
            $mdInfo += "| [$(Get-SafeMarkdown($item.displayName))]($portalLink) | $(Get-SafeMarkdown($tenant.displayName)) | $(Get-FormattedDate($item.keyStartDateTime)) |`n"
        }
    }

    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo

    $params = @{
        TestId             = '21992'
        Title              = 'Application Certificates need to be rotated on a regular basis'
        UserImpact         = 'Low'
        Risk               = 'High'
        ImplementationCost = 'High'
        AppliesTo          = 'Identity'
        Tag                = 'Identity'
        Status             = $passed
        Result             = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
