<#
.SYNOPSIS
    Threat hunting against Email and Collaboration tables in Microsoft 365 Defender Advanced Hunting is operational.

.NOTES
    Test ID: 41116
    Workshop Task: SECOPS-116
    Pillar: SecOps
    Category: Email and collaboration security
    Required permission: ThreatHunting.Read.All
#>

function Test-Assessment-41116 {
    [ZtTest(
        Category           = 'Email and collaboration security',
        CompatibleLicense  = ('THREAT_INTELLIGENCE'),
        ImplementationCost = 'Medium',
        Pillar             = 'SecOps',
        RiskLevel          = 'Medium',
        Service            = ('Graph'),
        SfiPillar          = 'Monitor and detect cyberthreats',
        TenantType         = ('Workforce'),
        TestId             = 41116,
        Title              = 'Threat hunting against Email and Collaboration tables in Microsoft 365 Defender Advanced Hunting is operational',
        UserImpact         = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity  = 'Checking Microsoft Defender XDR EmailEvents hunting availability'
    $testTitle = 'Threat hunting against Email and Collaboration tables in Microsoft 365 Defender Advanced Hunting is operational'
    $kqlQuery  = 'EmailEvents | where Timestamp > ago(1d) | summarize Count=count()'
    $endpoint  = '/beta/security/runHuntingQuery'
    $results   = @()
    $queryError = $null

    Write-ZtProgress -Activity $activity -Status 'Running EmailEvents probe query'
    try {
        $requestBody = @{ query = $kqlQuery; timespan = 'P1D' } | ConvertTo-Json -Compress
        $rawResult = Invoke-ZtGraphRequest -RelativeUri 'security/runHuntingQuery' -ApiVersion beta `
            -Method POST -Body $requestBody -ErrorAction Stop
        $results = @()
        if ($null -ne $rawResult -and $null -ne $rawResult.results) {
            $results = @($rawResult.results)
        }
    }
    catch {
        $queryError = $_
        Write-PSFMessage "Advanced hunting query failed: $_" -Tag Test -Level Warning
    }
    #endregion Data Collection

    #region Assessment Logic
    $passed           = $false
    $customStatus     = $null
    $skippedBecause   = $null
    $httpStatus       = '200'
    $errorCode        = '—'
    $errorMessage     = '—'
    $emailEventsCount = '—'
    $resultStatus     = 'Investigate'

    if ($queryError) {
        $httpStatus = Get-ZtHttpStatusCode -ErrorRecord $queryError
        $errorMessage = $queryError.Exception.Message

        if ($queryError.ErrorDetails -and $queryError.ErrorDetails.Message) {
            try {
                $errorBody = $queryError.ErrorDetails.Message | ConvertFrom-Json -ErrorAction Stop
                $errorCode = if ($errorBody.error.code) { $errorBody.error.code } else { '—' }
                $errorMessage = if ($errorBody.error.message) { $errorBody.error.message } else { $errorMessage }
            }
            catch {
                Write-PSFMessage "Failed to parse the error response body: $_" -Tag Test -Level VeryVerbose
            }
        }


        if ($httpStatus -eq 403 -and $errorMessage -match '(?i)(not licensed|license|plan 2|defender for office 365)') {
            $skippedBecause = 'NotApplicable'
            $resultStatus = 'Skipped'
            $testResultMarkdown = "⚠️ The tenant does not have the required Microsoft Defender for Office 365 Plan 2 Advanced Hunting capability.`n`n%TestResult%"
        }
        elseif ($httpStatus -eq 400 -and $errorMessage -match '(?i)(unknown table|unknown schema|failed to resolve (table|column).*EmailEvents|EmailEvents.*(not found|unavailable))') {
            $resultStatus = 'Fail'
            $testResultMarkdown = "❌ The Microsoft Defender XDR Advanced Hunting API is reachable, but the EmailEvents table or Email and Collaboration schema is unavailable in this tenant.`n`n%TestResult%"
        }
        elseif ($httpStatus -eq 403) {
            $customStatus = 'Investigate'
            $testResultMarkdown = "⚠️ **ThreatHunting.Read.All** permission is required to run advanced hunting queries. Verify the permission is consented and the assessment identity has a supported role: Global Reader, Security Reader, Security Operator, Security Administrator, or a Defender XDR Unified RBAC role with advanced hunting access, then re-run.`n`n%TestResult%"
        }
        elseif ($httpStatus -eq 429) {
            $customStatus = 'Investigate'
            $testResultMarkdown = "⚠️ The advanced hunting quota was exceeded. Retry when the quota window resets (typically a few minutes).`n`n%TestResult%"
        }
        else {
            $customStatus = 'Investigate'
            $testResultMarkdown = "⚠️ Microsoft Graph returned an unexpected error while running the advanced hunting query. Re-run after 5–10 minutes; file a support ticket if this persists.`n`n%TestResult%"
        }
    }
    elseif ($results.Count -eq 0) {
        $customStatus = 'Investigate'
        $testResultMarkdown = "⚠️ No results were returned by the EmailEvents advanced hunting query. Verify that email is flowing through Microsoft 365 and that the Advanced Hunting data pipeline is active, then re-run.`n`n%TestResult%"
    }
    else {
        foreach ($column in @('Count', 'count_', 'count')) {
            if ($results[0].PSObject.Properties.Name -contains $column -and $null -ne $results[0].$column) {
                try {
                    $emailEventsCount = [long]$results[0].$column
                }
                catch {
                    Write-PSFMessage "EmailEvents count could not be parsed: $($results[0].$column)" -Tag Test -Level Warning
                }
                break
            }
        }

        if ($emailEventsCount -eq '—') {
            $customStatus = 'Investigate'
            $testResultMarkdown = "⚠️ The Microsoft Defender XDR Advanced Hunting API returned a response, but the EmailEvents probe result could not be parsed.`n`n%TestResult%"
        }
        elseif ($emailEventsCount -gt 0) {
            $passed = $true
            $resultStatus = 'Pass'
            $testResultMarkdown = "✅ The Microsoft Defender XDR Advanced Hunting API is reachable and Email and Collaboration data is queryable from automation.`n`n%TestResult%"
        }
        else {
            $customStatus = 'Investigate'
            $testResultMarkdown = "⚠️ The Microsoft Defender XDR Advanced Hunting API is reachable, but the probe returned zero recent EmailEvents. Verify that email is flowing through Microsoft 365 and that the Advanced Hunting data pipeline is active.`n`n%TestResult%"
        }
    }
    #endregion Assessment Logic

    #region Report Generation
    $formatTemplate = @'

| Endpoint | HTTP Status | Error Code | Error Message | EmailEvents Count (24h) | Result |
| :------- | ----------: | :--------- | :------------ | ----------------------: | :----- |
| {0} | {1} | {2} | {3} | {4} | {5} |
'@
    $mdInfo = $formatTemplate -f (Get-SafeMarkdown -Text $endpoint), $httpStatus, (Get-SafeMarkdown -Text $errorCode), (Get-SafeMarkdown -Text $errorMessage), $emailEventsCount, $resultStatus
    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '41116'
        Title  = $testTitle
        Status = $passed
        Result = $testResultMarkdown
    }
    if ($customStatus) {
        $params.CustomStatus = $customStatus
    }
    if ($skippedBecause) {
        $params.SkippedBecause = $skippedBecause
    }
    Add-ZtTestResultDetail @params
}
