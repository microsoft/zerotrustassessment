<#
.SYNOPSIS
    Checking App registrations must not have reply URLs containing *.azurewebsites.net
#>

function Test-Assessment-21885 {
    [CmdletBinding()]
    param($Database)

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "Checking App registrations must not have reply URLs containing *.azurewebsites.net, URL shorteners, or localhost, wildcard domains"
    Write-ZtProgress -Activity $activity -Status "Getting policy"

    $sql = @"
    select id, appid, displayName, replyUrls, accountEnabled, appOwnerOrganizationId from main."ServicePrincipal"
    WHERE EXISTS (
        SELECT 1 FROM UNNEST(replyUrls) AS t(item)
        WHERE item LIKE '%azurewebsites.net%'
    )
    order by displayName
"@

    $results = Invoke-DatabaseQuery -Database $Database -Sql $sql
    $riskyAppsHigh = @()
    $riskyAppsMedium = @()
    $resolvedDomainsCache = @{}
    foreach ($item in $results) {
        $riskyUrlsHigh = @()
        $riskyUrlsMedium = @()

        foreach ($url in $item.replyUrls) {
            # skip localhost and non http(s) urls
            if ($url -like "*localhost*") {
                continue
            }
            if ($url -notlike "http*") {
                continue
            }
            try { # skip invalid urls
                $uri = [System.Uri]::new($url)
            }
            catch {
                continue
            }
            # Get domain from $uri
            $domain = $uri.Host

            if ($resolvedDomainsCache.ContainsKey($domain)) {
                $isDnsResolved = $resolvedDomainsCache[$domain]
            }
            else {
                Write-ZtProgress -Activity 'Checking domain' -Status $url
                # Cache domain resolution results to avoid multiple DNS queries
                $isDnsResolved = Test-DomainResolves -Domain $domain
                $resolvedDomainsCache[$domain] = $isDnsResolved
            }

            if ($isDnsResolved) {
                if ($url -like "*azurewebsites.net*") {
                    $riskyUrlsMedium += $url
                }
            }
            else {
                # This is a high risk URL since dns doesn't resolve
                $riskyUrlsHigh += $url
            }
        }

        if ($riskyUrlsHigh.Count -gt 0) {
            $riskyAppsHigh += $item
        }
        if ($riskyUrlsMedium.Count -gt 0) {
            # It's okay to repeat so we show the right urls based on the risk level
            $riskyAppsMedium += $item
        }

        # Add the risky URLs as a property to the item
        $item | Add-Member -MemberType NoteProperty -Name "highRiskUrls" -Value $riskyUrlsHigh
        $item | Add-Member -MemberType NoteProperty -Name "mediumRiskUrls" -Value $riskyUrlsMedium
    }

    $passed = $riskyAppsHigh.Count -eq 0 -and $riskyAppsMedium.Count -eq 0

    $riskLevel = 'Medium'
    if ($passed) {
        $testResultMarkdown += "No unsafe redirect URIs found`n`n%TestResult%"
    }
    else {
        $testResultMarkdown += "Unsafe redirect URIs found`n`n%TestResult%"
        if ($riskyAppsHigh.Count -gt 0) {
            $riskLevel = 'High'
        }
    }

    if ($riskyAppsHigh.Count -gt 0) {
        $testResultMarkdown += "`n## Apps with redirect URI domains that don't resolve `n`n"
        $testResultMarkdown += "`nThese apps can be hijacked by an attacker by registering this domain.`n`n"
        $testResultMarkdown += Get-RiskyAppList -Apps $riskyAppsHigh -Icon "❌" -ShowRiskLevel 'High'
    }

    if ($riskyAppsMedium.Count -gt 0) {
        $testResultMarkdown += "`n## Apps with unsafe redirect URIs `n`n"
        $testResultMarkdown += "`nThese apps can be hijacked by an attacker by registering this domain.`n`n"
        $testResultMarkdown += Get-RiskyAppList -Apps $riskyAppsMedium -Icon "⚠️" -ShowRiskLevel 'Medium'
    }

    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo

    Add-ZtTestResultDetail -TestId '21885' -Title "App registrations must not have reply URLs containing *.azurewebsites.net, URL shorteners, or localhost, wildcard domains" `
        -UserImpact Low -Risk $riskLevel -ImplementationCost High `
        -AppliesTo Identity -Tag Identity `
        -Status $passed -Result $testResultMarkdown
}

function Get-RiskyAppList($Apps, $Icon, $ShowRiskLevel) {
    $mdInfo = ""
    $mdInfo += "| | Name | Invalid Redirect URIs | App owner tenant |`n"
    $mdInfo += "| :--- | :--- | :--- | :--- |`n"

    foreach ($item in $Apps) {
        $tenantName = Get-ZtTenantName -tenantId $item.appOwnerOrganizationId
        $tenantName = Get-SafeMarkdown $tenantName
        $portalLink = "https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/$($item.id)/appId/$($item.appId)"

        $riskyReplyUrls = @()
        if ($ShowRiskLevel -eq 'High') {
            $riskyReplyUrls = $item.highRiskUrls
        }
        else {
            $riskyReplyUrls = $item.mediumRiskUrls
        }
        $riskyReplyUrls = $riskyReplyUrls | ForEach-Object { '`' + $_ + '`' }
        $riskyReplyUrls = $riskyReplyUrls -join ', '

        $mdInfo += "| $($Icon) | [$(Get-SafeMarkdown($item.displayName))]($portalLink) | $riskyReplyUrls | $tenantName |`n"
    }

    return $mdInfo
}
