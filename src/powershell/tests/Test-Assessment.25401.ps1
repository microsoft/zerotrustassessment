<#
.SYNOPSIS
    Validates that Application Proxy applications require pre-authentication to block anonymous access.

.DESCRIPTION
    This test checks whether Application Proxy applications are configured with Microsoft Entra
    pre-authentication instead of passthrough authentication. Passthrough authentication allows
    unauthenticated access to on-premises resources, exposing them to potential threat actors.

    The test verifies:
    - All Application Proxy applications use Microsoft Entra ID pre-authentication
    - No applications are configured with passthrough authentication

.NOTES
    Test ID: 25401
    Category: Application Proxy
    Pillar: Network
    Required API: applications (beta)
    Note: Two-query approach required due to bulk API returning default values
#>

function Test-Assessment-25401 {
    [ZtTest(
        Category = 'Application Proxy',
        ImplementationCost = 'Medium',
        MinimumLicense = ('AAD_PREMIUM'),
        Pillar = 'Network',
        RiskLevel = 'High',
        SfiPillar = 'Protect identities and secrets',
        TenantType = ('Workforce'),
        TestId = 25401,
        Title = 'Application Proxy applications require pre-authentication to block anonymous access to on-premises resources',
        UserImpact = 'Medium'
    )]
    [CmdletBinding()]
    param(
        $Database
    )

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking Application Proxy pre-authentication configuration'
    Write-ZtProgress -Activity $activity -Status 'Querying Application Proxy applications'

    $appProxyAppsFailed = $false
    $appProxyApps = @()

    # Query 1: Retrieve the list of Application Proxy-enabled applications
    try {
        $appProxyApps = Invoke-ZtGraphRequest `
            -RelativeUri 'applications' `
            -Filter 'onPremisesPublishing/isOnPremPublishingEnabled eq true' `
            -Select 'id','displayName' `
            -ApiVersion beta
    }
    catch {
        $appProxyAppsFailed = $true
        Write-PSFMessage "Failed to retrieve Application Proxy applications: $_" -Tag Test -Level Warning
    }

    # Query 2: Collect detailed configuration for all applications
    $appDetailsCollection = @()
    if (-not $appProxyAppsFailed -and $appProxyApps.Count -gt 0) {
        Write-ZtProgress -Activity $activity -Status 'Retrieving application details'

        foreach ($app in $appProxyApps) {
            try {
                $appDetail = Invoke-ZtGraphRequest `
                    -RelativeUri "applications/$($app.id)" `
                    -Select 'id','appId','displayName','onPremisesPublishing' `
                    -ApiVersion beta

                if ($null -eq $appDetail -or $null -eq $appDetail.onPremisesPublishing) {
                    continue
                }

                $appDetailsCollection += $appDetail
            }
            catch {
                Write-PSFMessage "Failed to retrieve details for application $($app.id): $_" -Tag Test -Level Warning
            }
        }
    }

    # Lookup service principal IDs from database for building deep links
    $spIdLookup = @{}
    if ($appDetailsCollection.Count -gt 0) {
        try {
            # Collect unique appIds
            $appIds = $appDetailsCollection | Where-Object { $_.appId } | Select-Object -ExpandProperty appId -Unique

            if ($appIds.Count -gt 0) {
                # Build IN clause for all appIds
                $appIdInClause = ($appIds | ForEach-Object { "'$($_.Replace("'", "''"))'" }) -join ','

                # Single query to get all service principal IDs
                $spQuery = "SELECT id, appId FROM ServicePrincipal WHERE appId IN ($appIdInClause)"
                $spResults = @(Invoke-DatabaseQuery -Database $Database -Sql $spQuery -AsCustomObject)

                # Build lookup hashtable: appId -> service principal id
                foreach ($sp in $spResults) {
                    if ($sp.appId -and $sp.id) {
                        $spIdLookup["$($sp.appId)"] = $sp.id
                    }
                }
            }
        }
        catch {
            Write-PSFMessage "Failed to retrieve service principal IDs from database: $_" -Tag Test -Level Warning
        }
    }
    #endregion Data Collection

    #region Assessment Logic
    $testResultMarkdown = ''
    $passed = $false
    $customStatus = $null
    $allApplications = [System.Collections.Generic.List[object]]::new()

    # Check if query failed
    if ($appProxyAppsFailed) {
        Write-PSFMessage 'Failed to query Application Proxy applications due to API/permission error.' -Tag Test -Level Warning
        $testResultMarkdown = "⚠️ Unable to determine Application Proxy pre-authentication configuration due to query failure, connection issues, or insufficient permissions.`n`n%TestResult%"
        $passed = $false
        $customStatus = 'Investigate'
    }
    # No Application Proxy applications found
    elseif ($null -eq $appProxyApps -or $appProxyApps.Count -eq 0) {
        Write-PSFMessage 'No Application Proxy applications found in this tenant.' -Tag Test -Level Verbose
        Add-ZtTestResultDetail -SkippedBecause NotApplicable -Result 'No Application Proxy applications are configured in this tenant.'
        return
    }
    else {
        Write-ZtProgress -Activity $activity -Status 'Analyzing pre-authentication settings'

        # Process application details and build final list
        foreach ($appDetail in $appDetailsCollection) {
            $authType = $appDetail.onPremisesPublishing.externalAuthenticationType
            $isCompliant = $authType -eq 'aadPreAuthentication'

            # Lookup service principal ID from hashtable
            $servicePrincipalId = $null
            if ($appDetail.appId -and $spIdLookup.ContainsKey("$($appDetail.appId)")) {
                $servicePrincipalId = $spIdLookup["$($appDetail.appId)"]
            }

            $appInfo = [PSCustomObject]@{
                Id                       = $appDetail.id
                AppId                    = $appDetail.appId
                ServicePrincipalId       = $servicePrincipalId
                DisplayName              = $appDetail.displayName
                ExternalAuthenticationType = $authType
                IsCompliant              = $isCompliant
                ComplianceStatus         = if ($isCompliant) { '✅ Yes' } else { '❌ No' }
            }

            $allApplications.Add($appInfo)
        }

        # Guard: If we couldn't retrieve details for any of the applications, treat as query failure
        if ($allApplications.Count -eq 0 -and $appProxyApps.Count -gt 0) {
            Write-PSFMessage 'Failed to retrieve details for any Application Proxy applications.' -Tag Test -Level Warning
            $testResultMarkdown = "⚠️ Unable to determine Application Proxy pre-authentication configuration due to query failure, connection issues, or insufficient permissions.`n`n%TestResult%"
            $passed = $false
            $customStatus = 'Investigate'
        }
        # Evaluate test result
        elseif ($allApplications.Count -gt 0) {
            $nonCompliantCount = ($allApplications | Where-Object { -not $_.IsCompliant }).Count

            if ($nonCompliantCount -eq 0) {
                # All applications use pre-authentication - pass
                $passed = $true
                $testResultMarkdown = "✅ All Application Proxy applications are configured with Microsoft Entra pre-authentication, ensuring users must authenticate before accessing on-premises resources.`n`n%TestResult%"
            }
            else {
                # One or more applications are not configured with Microsoft Entra pre-authentication - fail
                $passed = $false
                $testResultMarkdown = "❌ One or more Application Proxy applications are configured with passthrough authentication, allowing unauthenticated access to on-premises resources.`n`n%TestResult%"
            }
        }
    }
    #endregion Assessment Logic

    #region Report Generation
    $mdInfo = ''

    if ($allApplications.Count -gt 0) {
        $reportTitle = 'Application Proxy Pre-Authentication Configuration'

        $formatTemplate = @'


## {0}

| Application name | Pre-Authentication type | Compliant |
| :--------------- | :---------------------- | :-------- |
{1}

'@

        # Build table rows
        $tableRows = ''
        foreach ($app in $allApplications) {
            $appName = Get-SafeMarkdown -Text $app.DisplayName

            # Create deep link to Application Proxy page if we have service principal ID
            if ($app.ServicePrincipalId -and $app.AppId) {
                $appProxyUrl = "https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/AppProxy/objectId/$($app.ServicePrincipalId)/appId/$($app.AppId)/preferredSingleSignOnMode~/null/servicePrincipalType/Application/fromNav/"
                $appLink = "[$appName]($appProxyUrl)"
            }
            else {
                $appLink = $appName
            }

            $authType = Get-SafeMarkdown -Text $app.ExternalAuthenticationType
            $compliant = $app.ComplianceStatus

            $tableRows += "| $appLink | $authType | $compliant |`n"
        }

        $mdInfo = $formatTemplate -f $reportTitle, $tableRows
    }

    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '25401'
        Title  = 'Application Proxy applications require pre-authentication to block anonymous access to on-premises resources'
        Status = $passed
        Result = $testResultMarkdown
    }

    if ($null -ne $customStatus) {
        $params.CustomStatus = $customStatus
    }

    Add-ZtTestResultDetail @params
}
