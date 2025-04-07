<#
.SYNOPSIS
    Checking App registrations must use safe redirect URIs
#>

function Get-ZtAppWithUnsafeRedirectUris {
    [CmdletBinding()]
    param($Database,
        # 'ServicePrincipal' or 'Application'
        $Type)

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose
    # Get current tenantid
    $currentTenantId = (Get-MgContext).TenantId

    $filter = "appOwnerOrganizationId = '$currentTenantId'"
    if ($Type -eq 'ServicePrincipal') {
        $filter = "appOwnerOrganizationId <> '$currentTenantId'"
    }

    $sql = @"
 select id, appid, displayName, replyUrls, accountEnabled, appOwnerOrganizationId from main."ServicePrincipal"
 WHERE $filter
 order by displayName
"@

    $results = Invoke-DatabaseQuery -Database $Database -Sql $sql
    $riskyApps = @()
    $resolvedDomainsCache = @{}

    $tenantsToIgnore = @(
        'f8cdef31-a31e-4b4a-93e4-5f571e91255a', # Microsoft Services
        '33e01921-4d64-4f8c-a055-5bdaffd5e33d' # AME
    )

    foreach ($item in $results) {
        $riskyUrls = @()

        if($tenantsToIgnore -contains $item.appOwnerOrganizationId) {
            continue
        }

        foreach ($url in $item.replyUrls) {
            # skip localhost and non http(s) urls
            if ($url -like "*localhost*") {
                $riskyUrls += "1️⃣ $url"
                continue
            }
            if ($url -like "http:*") { #Should use https
                $riskyUrls += "2️⃣ $url"
                continue
            }
            if ($url -like "*azurewebsites.net*") {
                $riskyUrls += "3️⃣ $url"
                continue
            }


            try {
                # skip invalid urls
                $uri = [System.Uri]::new($url)
            }
            catch {
                $riskyUrls += "4️⃣ $url"
                continue
            }

            # Skip non http(s) urls
            if ($uri.Scheme -ne 'http' -and $uri.Scheme -ne 'https') {
                continue
            }

            # Get domain from $uri
            $domain = $uri.Host

            Write-ZtProgress -Activity 'Checking redirect uri' -Status $url
            if ($resolvedDomainsCache.ContainsKey($domain)) {
                $isDnsResolved = $resolvedDomainsCache[$domain]
            }
            else {
                # Cache domain resolution results to avoid multiple DNS queries
                $isDnsResolved = Test-DomainResolves -Domain $domain
                $resolvedDomainsCache[$domain] = $isDnsResolved
            }

            if (!$isDnsResolved) {
                $riskyUrls += "5️⃣ $url"
            }

            # # Check if the url redirects to a different domain :
            # NOTE: This has been taken out of the spec for now.
            # $safeRedirect = Test-UriRedirectsToSameDomain -Url $url
            # if (!$safeRedirect) {
            #     $riskyUrls += "6️⃣ $url"
            # }

        }

        if ($riskyUrls.Count -gt 0) {
            $riskyApps += $item
        }

        # Add the risky URLs as a property to the item
        $item | Add-Member -MemberType NoteProperty -Name "riskyUrls" -Value $riskyUrls
    }

    $passed = $riskyApps.Count -eq 0

    if ($passed) {
        $testResultMarkdown += "No unsafe redirect URIs found"
    }
    else {
        $testResultMarkdown += "Unsafe redirect URIs found`n`n"
        $testResultMarkdown += "1️⃣ → Use of localhost, 2️⃣ → Use of http(s) instead of https, 3️⃣ → Use of *.azurewebsites.net, 4️⃣ → Invalid URL, 5️⃣ → Domain not resolved`n`n"
        $testResultMarkdown += Get-RiskyAppList -Apps $riskyApps -Type $Type
    }

    # create and return a pscustomobject with testResultMarkdown and passed
    $result = [PSCustomObject]@{
        TestResultMarkdown = $testResultMarkdown
        Passed = $passed
    }
    return $result
}

function Get-RiskyAppList($Apps, $Type) {
    $mdInfo = ""
    $mdInfo += "| | Name | Unsafe Redirect URIs |"
    # Only add the app owner tenant column for ServicePrincipal
    if($Type -eq 'ServicePrincipal') { $mdInfo += "App owner tenant |`n" }
    else { $mdInfo += "`n" }

    $mdInfo += "| :--- | :--- | :--- |"
    if($Type -eq 'ServicePrincipal') { $mdInfo += " :--- |`n" }
    else { $mdInfo += "`n" }

    foreach ($item in $Apps) {
        if($Type -eq 'ServicePrincipal') {
            $tenantName = Get-ZtTenantName -tenantId $item.appOwnerOrganizationId
            $tenantName = Get-SafeMarkdown $tenantName
            $portalLink = "https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/$($item.id)/appId/$($item.appId)"
        }
        else {
            $portalLink = "https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/SignOn/objectId/$($item.id)/appId/$($item.appId)/preferredSingleSignOnMode/saml/servicePrincipalType/Application/fromNav/"
        }

        $riskyReplyUrls = $item.riskyUrls | ForEach-Object { '`' + $_ + '`' }
        $riskyReplyUrls = $riskyReplyUrls -join ', '

        $mdInfo += "| $($Icon) | [$(Get-SafeMarkdown($item.displayName))]($portalLink) | $riskyReplyUrls | $tenantName |`n"
    }

    return $mdInfo
}
