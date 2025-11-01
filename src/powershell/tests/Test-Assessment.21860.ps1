
<#
.SYNOPSIS
    Tests if all Entra Logs are configured with Diagnostic Settings.
#>

function Test-Assessment-21860 {
    [ZtTest(
    	Category = 'Monitoring',
    	ImplementationCost = 'Medium',
    	Pillar = 'Identity',
    	RiskLevel = 'High',
    	SfiPillar = 'Monitor and detect cyberthreats',
    	TenantType = ('Workforce','External'),
    	TestId = 21860,
    	Title = 'Diagnostic settings are configured for all Microsoft Entra logs',
    	UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    if((Get-MgContext).Environment -ne 'Global')
    {
        Write-PSFMessage "This test is only applicable to the Global environment." -Tag Test -Level VeryVerbose
        return
    }


    $skipped = $null
    try {
        $accessToken = Get-AzAccessToken -AsSecureString -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
    }
    catch [Management.Automation.CommandNotFoundException] {
        Write-PSFMessage $_.Exception.Message -Tag Test -Level Error
    }

    $passed = $false

    if (!$accessToken) {
        Write-PSFMessage "Azure authentication token not found." -Level Warning
        Add-ZtTestResultDetail -SkippedBecause NotConnectedAzure
        return
    }
    else {
        $azAccessToken = ($accessToken.Token)

        $resourceManagementUrl = (Get-AzContext).Environment.ResourceManagerUrl
        $azDiagUri = $resourceManagementUrl + 'providers/Microsoft.Authorization/roleAssignments?$filter=atScope()&api-version=2022-04-01'

        try {
            $result = Invoke-WebRequest -Uri $azDiagUri -Authentication Bearer -Token $azAccessToken -ErrorAction Stop
        }
        catch {
            if ($_.Exception.Response.StatusCode -eq 403 -or $_.Exception.Message -like "*403*" -or $_.Exception.Message -like "*Forbidden*") {
                Write-PSFMessage "The signed in user does not have access to the Azure subscription to check for log archiving." -Level Verbose
                Add-ZtTestResultDetail -SkippedBecause NoAzureAccess
                return
            }
            else {
                throw
            }
        }

        $diagnosticSettings = $result.Content | ConvertFrom-Json
        $enabledLogs = $diagnosticSettings.value.properties.logs | Where-Object { $_.enabled } | Select-Object -ExpandProperty category -Unique

        $logsToCheck = @(
            "AuditLogs",
            "SignInLogs",
            "NonInteractiveUserSignInLogs",
            "ServicePrincipalSignInLogs",
            "ManagedIdentitySignInLogs",
            "ProvisioningLogs",
            "ADFSSignInLogs",
            "RiskyUsers",
            "UserRiskEvents",
            "NetworkAccessTrafficLogs",
            "RiskyServicePrincipals",
            "ServicePrincipalRiskEvents",
            "EnrichedOffice365AuditLogs",
            "MicrosoftGraphActivityLogs",
            "RemoteNetworkHealthLogs"
        )

        $missingLogs = $logsToCheck | Where-Object { $_ -notin $enabledLogs }


        $passed = $null -eq $missingLogs

        if ($passed) {
            $testResultMarkdown += "All Entra Logs are configured with Diagnostic Settings.`n`n%TestResult%"
        }
        else {
            $testResultMarkdown += "Some Entra Logs are not configured with Diagnostic settings.`n`n%TestResult%"
        }

        $mdInfo = "## Log archiving`n`n"

        $mdInfo += "Log | Archiving enabled |`n"
        $mdInfo += "| :--- | :---: |`n"

        foreach ($item in $missingLogs | Sort-Object) {
            $mdInfo += "|$item | ❌ |`n"
        }

        foreach ($item in $enabledLogs | Sort-Object) {
            $mdInfo += "|$item | ✅ |`n"
        }

        $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo
    }

    Add-ZtTestResultDetail -TestId '21860' -Title 'Diagnostic settings are configured for all Microsoft Entra logs' `
        -UserImpact Low -Risk High -ImplementationCost Medium `
        -AppliesTo Identity -Tag Application `
        -Status $passed -Result $testResultMarkdown
}
