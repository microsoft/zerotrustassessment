<#
.SYNOPSIS
    TLS inspection failure rate remains below 1% to ensure consistent traffic visibility.
.DESCRIPTION
    Queries a Log Analytics workspace for NetworkAccessTraffic logs over the last 7 days and
    calculates the TLS inspection failure rate for intercepted traffic. A failure rate of 1% or
    higher indicates systemic issues that are creating blind spots in encrypted-traffic visibility.

.NOTES
    Test ID: 27003
    Category: Global Secure Access
    Required APIs:
        - Microsoft Graph beta: networkAccess/tlsInspectionPolicies (prerequisite check)
        - Azure Monitor diagnostic settings: providers/microsoft.aadiam/diagnosticsettings
        - Log Analytics query: {workspaceResourceId}/query
#>

function Test-Assessment-27003 {
    [ZtTest(
        Category = 'Global Secure Access',
        ImplementationCost = 'Medium',
        MinimumLicense = ('Entra_Premium_Internet_Access'),
        Pillar = 'Network',
        RiskLevel = 'High',
        SfiPillar = 'Protect networks',
        TenantType = ('Workforce'),
        TestId = 27003,
        Title = 'TLS inspection failure rate remains below 1% to ensure consistent traffic visibility',
        UserImpact = 'Medium'
    )]
    [CmdletBinding()]
    param()

    #region Helper Functions

    function Invoke-LogAnalyticsQuery {
        param(
            [Parameter(Mandatory)]
            [string] $Path,
            [Parameter(Mandatory)]
            [string] $Query
        )

        $body = @{ query = $Query } | ConvertTo-Json
        $response = Invoke-ZtAzureRequest -Path $Path -Method POST -Payload $body -FullResponse

        if ($response.StatusCode -ge 400) {
            try {
                $errorBody = $response.Content | ConvertFrom-Json -ErrorAction Stop
                $errorMsg = if ($errorBody.error) { $errorBody.error.message } else { "HTTP $($response.StatusCode)" }
            }
            catch {
                $errorMsg = "HTTP $($response.StatusCode)"
            }
            throw "Log Analytics query failed: $errorMsg"
        }

        $parsed = $response.Content | ConvertFrom-Json -ErrorAction Stop
        $table = $parsed.Tables[0]

        # Convert columnar response to PSCustomObjects
        $results = @()
        foreach ($row in $table.Rows) {
            $obj = [ordered]@{}
            for ($i = 0; $i -lt $table.Columns.Count; $i++) {
                $obj[$table.Columns[$i].Name] = $row[$i]
            }
            $results += [PSCustomObject]$obj
        }
        return $results
    }

    #endregion Helper Functions

    #region Data Collection
    Write-PSFMessage '🟦 Start TLS inspection failure rate evaluation' -Tag Test -Level VeryVerbose

    $activity = 'Checking TLS inspection failure rate'
    Write-ZtProgress -Activity $activity -Status 'Checking connections'

    # Check Azure connection and cloud environment first to avoid unnecessary API calls
    # in sovereign clouds (this test is only applicable to the Global/AzureCloud environment)
    Write-ZtProgress -Activity $activity -Status 'Checking Azure connection'

    $azContext = Get-AzContext -ErrorAction SilentlyContinue
    if (-not $azContext) {
        Write-PSFMessage 'Not connected to Azure.' -Tag Test -Level Warning
        Add-ZtTestResultDetail -SkippedBecause NotConnectedAzure
        return
    }

    if ($azContext.Environment.Name -ne 'AzureCloud') {
        Write-PSFMessage 'This test is only applicable to the AzureCloud environment.' -Tag Test -Level VeryVerbose
        Add-ZtTestResultDetail -SkippedBecause NotSupported
        return
    }

    # Prerequisite: TLS inspection must be configured
    Write-ZtProgress -Activity $activity -Status 'Checking TLS inspection policies'

    try {
        $tlsInspectionPolicies = Invoke-ZtGraphRequest -RelativeUri 'networkAccess/tlsInspectionPolicies' -ApiVersion beta
    }
    catch {
        if ($_.Exception.Message -match '403|Forbidden') {
            Write-PSFMessage 'Access denied to networkAccess/tlsInspectionPolicies. The tenant may not be licensed for Global Secure Access or the app is missing required permissions.' -Tag Test -Level Warning
            Add-ZtTestResultDetail -SkippedBecause NotSupported
            return
        }
        throw
    }

    if (-not $tlsInspectionPolicies -or $tlsInspectionPolicies.Count -eq 0) {
        Write-PSFMessage 'No TLS inspection policies configured.' -Tag Test -Level VeryVerbose
        Add-ZtTestResultDetail -SkippedBecause NotSupported -Result "TLS inspection is not configured in this tenant. This check is not applicable until a TLS inspection policy is created."
        return
    }

    Write-PSFMessage "Found $($tlsInspectionPolicies.Count) TLS inspection policy/policies." -Tag Test -Level VeryVerbose

    # Find Log Analytics workspace from Entra diagnostic settings
    Write-ZtProgress -Activity $activity -Status 'Querying diagnostic settings for Log Analytics workspace'

    try {
        $diagResult = Invoke-ZtAzureRequest -Path '/providers/microsoft.aadiam/diagnosticsettings?api-version=2017-04-01-preview' -FullResponse

        if ($diagResult.StatusCode -eq 403) {
            Write-PSFMessage 'The signed-in user does not have access to check diagnostic settings.' -Tag Test -Level Verbose
            Add-ZtTestResultDetail -SkippedBecause NoAzureAccess
            return
        }

        if ($diagResult.StatusCode -ge 400) {
            throw "Diagnostic settings request failed with status code $($diagResult.StatusCode)"
        }
    }
    catch {
        throw
    }

    $diagnosticSettings = ($diagResult.Content | ConvertFrom-Json -ErrorAction Stop).value

    # Find a workspace that has NetworkAccessTrafficLogs enabled
    $workspaceResourceId = $null
    $matchedSettingName = $null

    foreach ($setting in $diagnosticSettings) {
        $wsId = $setting.properties.workspaceId
        if (-not [string]::IsNullOrEmpty($wsId)) {
            $enabledLogs = $setting.properties.logs | Where-Object { $_.enabled -eq $true } | Select-Object -ExpandProperty category
            if ($enabledLogs -contains 'NetworkAccessTrafficLogs') {
                $workspaceResourceId = $wsId
                $matchedSettingName = $setting.name
                break
            }
        }
    }

    if (-not $workspaceResourceId) {
        Write-PSFMessage 'No diagnostic setting exports NetworkAccessTrafficLogs to a Log Analytics workspace.' -Tag Test -Level Warning
        Add-ZtTestResultDetail -SkippedBecause NotSupported -Result "No diagnostic setting is configured to export NetworkAccessTrafficLogs to a Log Analytics workspace. Configure diagnostic settings to enable this check."
        return
    }

    Write-PSFMessage "Using workspace from diagnostic setting '$matchedSettingName': $workspaceResourceId" -Tag Test -Level VeryVerbose

    $logAnalyticsQueryUri = "$workspaceResourceId/query?api-version=2017-10-01"

    # Q1: Calculate TLS inspection failure rate over the last 7 days
    Write-ZtProgress -Activity $activity -Status 'Querying TLS inspection failure rate (last 7 days)'

    $q1Kql = @"
NetworkAccessTraffic
| where TimeGenerated >= ago(7d)
| where TlsAction == "Intercepted"
| summarize
    TotalIntercepted = count(),
    FailureCount = countif(TlsStatus == "Failure"),
    SuccessCount = countif(TlsStatus == "Success")
| extend FailureRate = round(todouble(FailureCount) / todouble(TotalIntercepted) * 100, 2)
| project TotalIntercepted, SuccessCount, FailureCount, FailureRate
"@

    try {
        $q1Results = @(Invoke-LogAnalyticsQuery -Path $logAnalyticsQueryUri -Query $q1Kql)
    }
    catch {
        Write-PSFMessage "Failed to query Log Analytics: $_" -Tag Test -Level Warning
        Add-ZtTestResultDetail -SkippedBecause NotSupported -Result "Unable to query Log Analytics workspace. Ensure the signed-in user has Log Analytics Reader access. Error: $_"
        return
    }

    # Extract Q1 metrics
    $totalIntercepted = 0
    $successCount = 0
    $failureCount = 0
    $failureRate = 0.0

    if ($q1Results.Count -gt 0) {
        $totalIntercepted = [long]$q1Results[0].TotalIntercepted
        $successCount = [long]$q1Results[0].SuccessCount
        $failureCount = [long]$q1Results[0].FailureCount

        # Handle NaN (when TotalIntercepted is 0, KQL returns NaN)
        $rawRate = $q1Results[0].FailureRate
        if ($rawRate -is [string] -and $rawRate -eq 'NaN') {
            $failureRate = 0.0
        }
        elseif ($null -ne $rawRate) {
            $failureRate = [double]$rawRate
        }
    }

    Write-PSFMessage "Q1 results: Total=$totalIntercepted, Success=$successCount, Failure=$failureCount, Rate=$failureRate%" -Tag Test -Level VeryVerbose

    # Q2: Top failure destinations (only query if there are failures)
    $q2Results = @()
    if ($failureCount -gt 0) {
        Write-ZtProgress -Activity $activity -Status 'Querying top failure destinations'

        $q2Kql = @"
NetworkAccessTraffic
| where TimeGenerated >= ago(7d)
| where TlsAction == "Intercepted" and TlsStatus == "Failure"
| summarize FailureCount = count() by DestinationFqdn
| top 20 by FailureCount desc
| project DestinationFqdn, FailureCount
"@

        try {
            $q2Results = @(Invoke-LogAnalyticsQuery -Path $logAnalyticsQueryUri -Query $q2Kql)
        }
        catch {
            Write-PSFMessage "Failed to query top failure destinations: $_" -Tag Test -Level Warning
        }
    }

    # Q3: Daily trend analysis
    $q3Results = @()
    if ($totalIntercepted -gt 0) {
        Write-ZtProgress -Activity $activity -Status 'Querying daily failure rate trend'

        $q3Kql = @"
NetworkAccessTraffic
| where TimeGenerated >= ago(7d)
| where TlsAction == "Intercepted"
| summarize
    TotalIntercepted = count(),
    FailureCount = countif(TlsStatus == "Failure")
    by bin(TimeGenerated, 1d)
| extend FailureRate = round(todouble(FailureCount) / todouble(TotalIntercepted) * 100, 2)
| project Date = format_datetime(TimeGenerated, 'yyyy-MM-dd'), TotalIntercepted, FailureCount, FailureRate
| order by Date asc
"@

        try {
            $q3Results = @(Invoke-LogAnalyticsQuery -Path $logAnalyticsQueryUri -Query $q3Kql)
        }
        catch {
            Write-PSFMessage "Failed to query daily trend: $_" -Tag Test -Level Warning
        }
    }

    #endregion Data Collection

    #region Assessment Logic

    $passed = $false
    $testResultMarkdown = ''

    if ($totalIntercepted -eq 0) {
        # No intercepted traffic — TLS inspection not actively in use
        $passed = $true
        $testResultMarkdown = "✅ No TLS-intercepted traffic was found in the last 7 days. TLS inspection policies exist but no traffic was intercepted during the evaluation period.`n`n%TestResult%"
    }
    elseif ($failureRate -ge 1) {
        # Fail: failure rate is 1% or higher
        $testResultMarkdown = "❌ TLS inspection failure rate exceeds 1% threshold ($failureRate%). Investigate failing destinations and consider adding bypass rules for incompatible applications or resolving certificate trust issues.`n`n%TestResult%"
    }
    else {
        # Pass: failure rate below 1%
        $passed = $true
        $testResultMarkdown = "✅ TLS inspection failure rate is below 1% ($failureRate%) over the last 7 days, indicating healthy encrypted traffic visibility.`n`n%TestResult%"
    }

    #endregion Assessment Logic

    #region Report Generation

    $tlsInspectionLink = 'https://entra.microsoft.com/#view/Microsoft_Azure_Network_Access/TLSInspectionPolicy.ReactView'
    $workspaceName = ($workspaceResourceId -split '/')[-1]
    $workspacePortalLink = "https://portal.azure.com/#resource${workspaceResourceId}/overview"

    # Build health summary section
    $statusText = if ($passed) { 'Pass' } else { 'Fail' }

    $mdInfo = @"

## [TLS inspection health summary]($tlsInspectionLink)

| Metric | Value |
| :--- | :--- |
| Evaluation period | Last 7 days |
| Log Analytics workspace | [$(Get-SafeMarkdown $workspaceName)]($workspacePortalLink) |
| Total intercepted transactions | $totalIntercepted |
| Successful inspections | $successCount |
| Failed inspections | $failureCount |
| Failure rate | $failureRate% |
| Status | $statusText |

"@

    # Top failing destinations (only if failures exist)
    if ($q2Results.Count -gt 0) {
        $destRows = ''
        foreach ($dest in $q2Results) {
            $destRows += "| $(Get-SafeMarkdown $dest.DestinationFqdn) | $($dest.FailureCount) |`n"
        }

        $mdInfo += @"

## Top failing destinations

| Destination FQDN | Failure count |
| :--- | :--- |
$destRows
"@
    }

    # Daily trend (only if there was intercepted traffic)
    if ($q3Results.Count -gt 0) {
        $trendRows = ''
        foreach ($day in $q3Results) {
            $dayRate = $day.FailureRate
            if ($dayRate -is [string] -and $dayRate -eq 'NaN') { $dayRate = '0' }
            $trendRows += "| $($day.Date) | $($day.TotalIntercepted) | $($day.FailureCount) | $dayRate% |`n"
        }

        $mdInfo += @"

## Daily trend

| Date | Total intercepted | Failures | Failure rate |
| :--- | :--- | :--- | :--- |
$trendRows
"@
    }

    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo

    #endregion Report Generation

    $params = @{
        TestId = '27003'
        Title  = 'TLS inspection failure rate remains below 1% to ensure consistent traffic visibility'
        Status = $passed
        Result = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
