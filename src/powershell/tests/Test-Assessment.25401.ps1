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
    param()

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

    # Handle query failure
    if ($appProxyAppsFailed) {
        Write-PSFMessage 'Failed to retrieve Application Proxy applications' -Tag Test -Level Error
        Add-ZtTestResultDetail -SkippedBecause NotApplicable -Result 'Failed to retrieve Application Proxy applications.'
        return
    }

    # No Application Proxy applications found
    if ($null -eq $appProxyAppIds -or $appProxyAppIds.Count -eq 0) {
        Write-PSFMessage 'No Application Proxy applications found in this tenant.' -Tag Test -Level Verbose
        Add-ZtTestResultDetail -SkippedBecause NotApplicable -Result 'No Application Proxy applications are configured in this tenant.'
        return
    }

    Write-ZtProgress -Activity $activity -Status 'Analyzing pre-authentication settings'

    $allApplications = [System.Collections.Generic.List[object]]::new()
    $passthroughApplications = [System.Collections.Generic.List[object]]::new()
    $compliantApplications = [System.Collections.Generic.List[object]]::new()

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

            $appInfo = [PSCustomObject]@{
                Id                       = $appDetail.id
                AppId                    = $appDetail.appId
                DisplayName              = $appDetail.displayName
                ExternalAuthenticationType = $authType
                IsCompliant              = $isCompliant
                ComplianceStatus         = if ($isCompliant) { '✅ Yes' } else { '❌ No' }
            }

            $allApplications.Add($appInfo)

            if ($authType -eq 'passthru') {
                $passthroughApplications.Add($appInfo)
            }
            else {
                $compliantApplications.Add($appInfo)
            }
        }
        catch {
            Write-PSFMessage "Failed to retrieve details for application $($appId.id): $_" -Tag Test -Level Warning
        }
    }

    # Evaluate test result
    if ($passthroughApplications.Count -eq 0) {
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
        $portalLink = 'https://entra.microsoft.com/#view/Microsoft_AAD_IAM/EnterpriseApplicationListBlade/objectType/AppProxy'

        $formatTemplate = @'

## [{0}]({1})

{2}
'@

        # Build main applications table
        $appsTable = "| Application name | Pre-authentication type | Compliant |`n"
        $appsTable += "| :--------------- | :---------------------- | :-------- |`n"

        foreach ($app in $allApplications) {
            $appName = Get-SafeMarkdown -Text $app.DisplayName
            $authType = Get-SafeMarkdown -Text $app.ExternalAuthenticationType
            $compliant = $app.ComplianceStatus

            $appsTable += "| $appName | $authType | $compliant |`n"
        }

        $mdInfo = $formatTemplate -f $reportTitle, $portalLink, $appsTable
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
