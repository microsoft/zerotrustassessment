<#
.SYNOPSIS
    Test to check if App Instance Property Lock is configured for all multitenant applications.
#>

function Test-Assessment-21777 {
    [ZtTest(
    	Category = 'Access control',
    	ImplementationCost = 'Low',
    	MinimumLicense = ('Free'),
    	Pillar = 'Identity',
    	RiskLevel = 'High',
    	SfiPillar = 'Protect tenants and isolate production systems',
    	TenantType = ('Workforce','External'),
    	TestId = 21777,
    	Title = 'App instance property lock is configured for all multitenant applications',
    	UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param(
        $Database
    )

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "Checking App Instance Property Lock is configured for all multitenant applications"
    Write-ZtProgress -Activity $activity -Status "Getting applications"

    $sqlCount = "SELECT COUNT(*) ItemCount FROM Application WHERE ID IS NOT NULL"
    $resultCount = Invoke-DatabaseQuery -Database $Database -Sql $sqlCount
    $hasData = $resultCount.ItemCount -gt 0

    if($hasData){
        # SQL query to find multitenant applications and check their servicePrincipalLockConfiguration
        $sqlApp = @"
        SELECT
            appId,
            displayName,
            signInAudience,
            servicePrincipalLockConfiguration,
            CASE
                WHEN servicePrincipalLockConfiguration IS NULL THEN false
                WHEN servicePrincipalLockConfiguration->>'isEnabled' = 'false' THEN false
                ELSE true
            END AS isLockConfigured
        FROM Application
        WHERE signInAudience = 'AzureADMultipleOrgs' OR signInAudience = 'AzureADandPersonalMicrosoftAccount'
        ORDER BY displayName
"@

        $resultsApp = Invoke-DatabaseQuery -Database $Database -Sql $sqlApp
    }

    # Initialize variables
    $passed = $true
    $testResultMarkdown = ""

    # Check if any application in the results has isLockConfigured set to false
    if ($hasData -and $resultsApp.Count -gt 0) {
        foreach ($app in $resultsApp) {
            if ($app.isLockConfigured -eq $false) {
                $passed = $false
                break
            }
        }
    }

    $noMultiTenantApps = -not $hasData -or $resultsApp.Count -eq 0
    if ($noMultiTenantApps) {
        $testResultMarkdown = "No multi-tenant apps were found in this tenant."
    }
    elseif ($passed) {
        $testResultMarkdown = "All multi-tenant apps have app instance property lock configured."
    }
    else {
        $testResultMarkdown = "Found multi-tenant apps without app instance property lock configured.`n`n%TestResult%"
    }

    # Build the detailed sections of the markdown

    # Define variables to insert into the format string
    $reportTitle = "Multi-tenant applications and their App Instance Property Lock setting"
    $tableRows = ""

    if ($resultsApp.Count -gt 0) {
        # Create a here-string with format placeholders {0}, {1}, etc.
        $formatTemplate = @'

## {0}


| Application | Application ID | App Instance Property Lock configured |
| :---------- | :------------- | :------------------------------------ |
{1}

'@

        foreach ($app in $resultsApp) {
            $portalLink = 'https://entra.microsoft.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Authentication/appId/{0}/isMSAApp~/false' -f $app.appId
            $tableRows += @"
| [$(Get-SafeMarkdown($app.displayName))]($portalLink) | $($app.appId) | $($app.isLockConfigured) |`n
"@
        }

        # Format the template by replacing placeholders with values
        $mdInfo = $formatTemplate -f $reportTitle, $tableRows
    }

    # Replace the placeholder with the detailed information
    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo

    $params = @{
        TestId             = '21777'
        Title              = "App Instance Property Lock is configured for all multitenant applications"
        UserImpact         = 'Low'
        Risk               = 'High'
        ImplementationCost = 'Low'
        AppliesTo          = 'Identity'
        Tag                = 'Identity'
        Status             = $passed
        Result             = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
