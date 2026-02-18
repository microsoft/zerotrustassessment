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
    $appProxyAppIds = @()

    # Query 1: Retrieve the list of Application Proxy-enabled application IDs
    try {
        $appProxyAppIds = Invoke-ZtGraphRequest `
            -RelativeUri 'applications' `
            -Filter 'onPremisesPublishing/isOnPremPublishingEnabled eq true' `
            -Select 'id','displayName' `
            -ApiVersion beta
    }
    catch {
        $appProxyAppsFailed = $true
        Write-PSFMessage "Failed to retrieve Application Proxy applications: $_" -Tag Test -Level Warning
    }
    #endregion Data Collection

    #region Assessment Logic
    $testResultMarkdown = ''
    $passed = $false

    # No Application Proxy applications found
    if ($null -eq $appProxyAppIds -or $appProxyAppIds.Count -eq 0) {
        Write-PSFMessage 'No Application Proxy applications found in this tenant.' -Tag Test -Level Verbose
        Add-ZtTestResultDetail -SkippedBecause NotApplicable -Result 'No Application Proxy applications are configured in this tenant.'
        return
    }

    Write-ZtProgress -Activity $activity -Status 'Analyzing pre-authentication settings'

    $allApplications = [System.Collections.Generic.List[object]]::new()

    # Query 2: For each application, retrieve detailed configuration
    foreach ($appId in $appProxyAppIds) {
        try {
            $appDetail = Invoke-ZtGraphRequest `
                -RelativeUri "applications/$($appId.id)" `
                -Select 'id','appId','displayName','onPremisesPublishing' `
                -ApiVersion beta

            if ($null -eq $appDetail -or $null -eq $appDetail.onPremisesPublishing) {
                continue
            }

            $authType = $appDetail.onPremisesPublishing.externalAuthenticationType
            $isCompliant = $authType -eq 'aadPreAuthentication'

            # Query database to get service principal ID using appId
            $servicePrincipalId = $null
            if ($appDetail.appId) {
                try {
                    $spQuery = "SELECT id FROM ServicePrincipal WHERE appId = '$($appDetail.appId)'"
                    $spResult = @(Invoke-DatabaseQuery -Database $Database -Sql $spQuery -AsCustomObject)
                    if ($spResult -and $spResult.Count -gt 0) {
                        $servicePrincipalId = $spResult[0].id
                    }
                }
                catch {
                    Write-PSFMessage "Failed to retrieve service principal ID for appId $($appDetail.appId): $_" -Tag Test -Level Warning
                }
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
        catch {
            Write-PSFMessage "Failed to retrieve details for application $($appId.id): $_" -Tag Test -Level Warning
        }
    }

    # Evaluate test result
    $passthroughCount = ($allApplications | Where-Object { $_.ExternalAuthenticationType -eq 'passthru' }).Count

    if ($passthroughCount -eq 0) {
        # All applications use pre-authentication - pass
        $passed = $true
        $testResultMarkdown = "✅ All Application Proxy applications are configured with Microsoft Entra pre-authentication, ensuring users must authenticate before accessing on-premises resources.`n`n%TestResult%"
    }
    else {
        # One or more applications use passthrough - fail
        $passed = $false
        $testResultMarkdown = "❌ One or more Application Proxy applications are configured with passthrough authentication, allowing unauthenticated access to on-premises resources.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    $mdInfo = ''

    if ($allApplications.Count -gt 0) {
        $reportTitle = 'Application Proxy Pre-Authentication Configuration'

        $formatTemplate = @'


## {0}

| Application name | Pre-authentication type | Compliant |
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
    Add-ZtTestResultDetail @params
}
