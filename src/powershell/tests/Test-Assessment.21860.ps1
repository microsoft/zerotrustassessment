
<#
.SYNOPSIS
    Tests if all Entra Logs are configured with Diagnostic Settings.

.DESCRIPTION
    This test validates that all required Microsoft Entra log categories have at least
    one diagnostic setting configured with that category enabled.

.NOTES
    Test ID: 21860
    Category: Monitoring
    Pillar: Identity
    Required API: ARM REST - providers/microsoft.aadiam/diagnosticsettings
#>

function Test-Assessment-21860 {
    [ZtTest(
        Category = 'Monitoring',
        ImplementationCost = 'Medium',
        Pillar = 'Identity',
        RiskLevel = 'High',
        Service = ('Azure'),
        SfiPillar = 'Monitor and detect cyberthreats',
        TenantType = ('Workforce', 'External'),
        TestId = 21860,
        Title = 'Diagnostic settings are configured for all Microsoft Entra logs',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking Microsoft Entra diagnostic settings configuration'

    # Only applicable to Global environment
    if ((Get-MgContext).Environment -ne 'Global') {
        Write-PSFMessage 'This test is only applicable to the Global environment.' -Tag Test -Level VeryVerbose
        Add-ZtTestResultDetail -SkippedBecause NotSupported
        return
    }

    # Check if connected to Azure
    Write-ZtProgress -Activity $activity -Status 'Checking Azure connection'

    $azContext = Get-AzContext -ErrorAction SilentlyContinue
    if (-not $azContext) {
        Write-PSFMessage 'Not connected to Azure.' -Level Warning
        Add-ZtTestResultDetail -SkippedBecause NotConnectedAzure
        return
    }

    Write-ZtProgress -Activity $activity -Status 'Querying Entra diagnostic settings'

    # Use ARM REST API for tenant-level Entra diagnostic settings.
    # Azure Resource Graph does not index microsoft.aadiam resources, so Invoke-ZtAzureRequest is used.
    $diagnosticSettings = @()
    try {
        $response = Invoke-ZtAzureRequest -Path '/providers/microsoft.aadiam/diagnosticsettings?api-version=2017-04-01-preview' -FullResponse
        if ($response.StatusCode -eq 403) {
            Write-PSFMessage 'The signed-in user does not have access to Entra diagnostic settings.' -Level Verbose
            Add-ZtTestResultDetail -SkippedBecause NoAzureAccess
            return
        }
        $diagnosticSettings = @(($response.Content | ConvertFrom-Json).value)
        Write-PSFMessage "Found $($diagnosticSettings.Count) diagnostic setting(s)" -Tag Test -Level VeryVerbose
    }
    catch {
        Write-PSFMessage "Entra diagnostic settings query failed: $($_.Exception.Message)" -Tag Test -Level Warning
        Add-ZtTestResultDetail -SkippedBecause NotSupported
        return
    }
    #endregion Data Collection

    #region Assessment Logic
    $logsToCheck = @(
        'AuditLogs',
        'SignInLogs',
        'NonInteractiveUserSignInLogs',
        'ServicePrincipalSignInLogs',
        'ManagedIdentitySignInLogs',
        'ProvisioningLogs',
        'ADFSSignInLogs',
        'RiskyUsers',
        'UserRiskEvents',
        'NetworkAccessTrafficLogs',
        'RiskyServicePrincipals',
        'ServicePrincipalRiskEvents',
        'EnrichedOffice365AuditLogs',
        'MicrosoftGraphActivityLogs',
        'RemoteNetworkHealthLogs'
    )

    # Collect all log categories that are enabled in at least one diagnostic setting
    $enabledLogs = @(
        $diagnosticSettings |
            ForEach-Object { $_.properties.logs } |
            Where-Object { $_.enabled -eq $true } |
            Select-Object -ExpandProperty category -Unique
    )

    $missingLogs = @($logsToCheck | Where-Object { $_ -notin $enabledLogs })
    $passed = $missingLogs.Count -eq 0

    if ($passed) {
        $testResultMarkdown = "✅ All Entra Logs are configured with Diagnostic Settings.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "❌ Some Entra Logs are not configured with Diagnostic settings.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    $mdInfo = ''

    $reportTitle = 'Microsoft Entra Log Archiving'
    $portalLink = 'https://portal.azure.com/#view/Microsoft_AAD_IAM/DiagnosticSettingsMenuBlade'

    $tableRows = ''
    foreach ($log in $logsToCheck | Sort-Object) {
        if ($log -in $enabledLogs) {
            $settingNames = @(
                $diagnosticSettings | Where-Object {
                    $_.properties.logs | Where-Object { $_.category -eq $log -and $_.enabled -eq $true }
                } | ForEach-Object { Get-SafeMarkdown $_.name }
            )
            $tableRows += "| $log | $($settingNames -join ', ') |`n"
        }
        else {
            $tableRows += "| $log | none |`n"
        }
    }

    $formatTemplate = @'


## [{0}]({1})

| Log name | Diagnostic settings |
| :--- | :--- |
{2}

'@

    $mdInfo = $formatTemplate -f $reportTitle, $portalLink, $tableRows

    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '21860'
        Title  = 'Diagnostic settings are configured for all Microsoft Entra logs'
        Status = $passed
        Result = $testResultMarkdown
    }
    Add-ZtTestResultDetail @params
}
