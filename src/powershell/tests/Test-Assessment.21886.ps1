<#
.SYNOPSIS

#>

function Test-Assessment-21886 {
    [ZtTest(
    	Category = 'Applications management',
    	ImplementationCost = 'Medium',
    	MinimumLicense = ('P1'),
    	Pillar = 'Identity',
    	RiskLevel = 'Medium',
    	SfiPillar = 'Protect identities and secrets',
    	TenantType = ('Workforce','External'),
    	TestId = 21886,
    	Title = 'Applications are configured for automatic user provisioning',
    	UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param(
        $Database
    )

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "Checking Applications that use Microsoft Entra for authentication and support provisioning are configured"
    Write-ZtProgress -Activity $activity -Status "Getting all service principals that have SSO configured"

    $sql = @"
SELECT
    id,
    appId,
    displayName,
    preferredSingleSignOnMode,
    accountEnabled
FROM ServicePrincipal
WHERE preferredSingleSignOnMode IS NOT NULL AND preferredSingleSignOnMode IN ('password', 'saml', 'oidc')
    AND accountEnabled = true
ORDER BY LOWER(displayName) ASC
"@

    $matchedServicePrincipals = Invoke-DatabaseQuery -Database $Database -Sql $sql

    $apps = @()
    foreach ($servicePrincipal in $matchedServicePrincipals) {
        $app = [PSCustomObject]@{
            Id                    = $servicePrincipal.id
            AppId                 = $servicePrincipal.appId
            DisplayName           = Get-SafeMarkdown $servicePrincipal.displayName
            PreferredSingleSignOn = $servicePrincipal.preferredSingleSignOnMode
            AccountEnabled        = $servicePrincipal.accountEnabled
            Templates             = Invoke-ZtGraphRequest -RelativeUri "servicePrincipals/$($servicePrincipal.id)/synchronization/templates" -ApiVersion 'v1.0'
            Jobs                  = Invoke-ZtGraphRequest -RelativeUri "servicePrincipals/$($servicePrincipal.id)/synchronization/jobs" -ApiVersion 'v1.0'
        }
        $apps += $app
    }

    $unconfiguredApps = @()
    $configuredApps = @()
    foreach ($app in $apps) {
        if (($app.Templates | Measure-Object).Count -gt 0 -and ($app.Jobs.value | Measure-Object).Count -eq 0) {
            $unconfiguredApps += $app
        }
    else {
        $configuredApps += $app
    }
}

    if ($unconfiguredApps.Count -eq 0) {
        $passed = $true
        $testResultMarkdown = "Applications that are configured for SSO and support provisioning are also configured for provisioning."
    }
    else {
        $passed = $false
        $testResultMarkdown = "Applications that are configured for SSO and support provisioning are NOT configured for provisioning.`n`n%TestResult%"
    }

    # Build the detailed sections of the markdown

    # Define variables to insert into the format string
    $reportTitle = "Applications that are NOT configured for provisioning"
    $tableRows = ""

    if ($unconfiguredApps.Count -gt 0) {
        # Create a here-string with format placeholders {0}, {1}, etc.
        $formatTemplate = @'

## {0}


| Application Name | Object ID | Application ID |
| :--------------- | :-------- | :------------- |
{1}

'@

        foreach ($app in $unconfiguredApps) {
            $portalLink = "https://entra.microsoft.com/#view/Microsoft_AAD_IAM/ManagedAppMenuBlade/~/Overview/objectId/{0}/appId/{1}/preferredSingleSignOnMode/{2}/servicePrincipalType/Application/fromNav/" -f $app.Id, $app.AppId, $app.PreferredSingleSignOn
            $tableRows += @"
| [$($app.displayName)]($portalLink) | $($app.Id) | $($app.AppId) |`n
"@
        }

        # Format the template by replacing placeholders with values
        $mdInfo = $formatTemplate -f $reportTitle, $tableRows

        # Replace the placeholder with the detailed information
        $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo
    }

    $params = @{
        TestId             = '21886'
        Title              = 'Applications that use Microsoft Entra for authentication and support provisioning are configured'
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
