<#
.SYNOPSIS
    Microsoft Defender for Identity sensor is installed and healthy on every domain controller.

.DESCRIPTION
    Checks that at least one MDI domain controller sensor is registered in the tenant,
    and that every registered domain controller sensor is up-to-date, healthy, and running.

.NOTES
    Test ID: 41002
    Workshop Task: SECOPS-002
    Pillar: SecOps
    Category: Identity threat protection
    Required API: GET /v1.0/security/identities/sensors
    Required permission: SecurityIdentitiesSensors.Read.All
#>

function Test-Assessment-41002 {
    [ZtTest(
        Category = 'Identity threat protection',
        CompatibleLicense = ('ATA'),
        ImplementationCost = 'Medium',
        Pillar = 'SecOps',
        RiskLevel = 'High',
        Service = ('Graph'),
        SfiPillar = 'Monitor and detect cyberthreats',
        TenantType = ('Workforce'),
        TestId = 41002,
        Title = 'Microsoft Defender for Identity sensor is installed and healthy on every domain controller',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking Microsoft Defender for Identity sensor health'
    Write-ZtProgress -Activity $activity -Status 'Querying MDI sensor inventory'

    $sensors         = $null
    $queryError      = $null
    $httpStatusCode  = $null

    try {
        $sensors = Invoke-ZtGraphRequest -RelativeUri 'security/identities/sensors' -ApiVersion 'v1.0' -ErrorAction Stop
    }
    catch {
        $queryError     = $_
        $httpStatusCode = Get-ZtHttpStatusCode -ErrorRecord $_
        Write-PSFMessage "Failed to retrieve MDI sensors: $_" -Tag Test -Level Warning
    }
    #endregion Data Collection

    #region Assessment Logic
    $passed             = $false
    $customStatus       = $null
    $allDcSensors       = @()
    $testResultMarkdown = ''

    if ($queryError) {
        if ($httpStatusCode -in @(401, 403)) {
            $customStatus = 'Investigate'
            $testResultMarkdown = "⚠️ Insufficient Graph permission to read the MDI sensor inventory. Grant ``SecurityIdentitiesSensors.Read.All`` to the calling identity and re-run.`n`n**Error:** ``$queryError```n`n%TestResult%"
        }
        elseif ($null -ne $httpStatusCode -and $httpStatusCode -ge 500) {
            $customStatus = 'Investigate'
            $testResultMarkdown = "⚠️ Transient Microsoft Graph error querying MDI sensors (HTTP $httpStatusCode). Re-run after 5–10 minutes; file a support ticket if the error persists.`n`n%TestResult%"
        }
        else {
            $customStatus = 'Investigate'
            $testResultMarkdown = "⚠️ Unable to retrieve MDI sensor inventory due to an unexpected error. Re-run the assessment; if the issue persists verify connectivity and permissions.`n`n**Error:** ``$queryError```n`n%TestResult%"
        }
    }
    elseif (-not $sensors -or $sensors.Count -eq 0) {
        $customStatus = 'Investigate'
        $testResultMarkdown = "⚠️ No Microsoft Defender for Identity sensors are registered in this tenant. Verify whether Defender for Identity has been onboarded. If onboarding is recent (<24 h), allow the inventory to propagate and re-run.`n`n%TestResult%"
    }
    else {
        $allDcSensors = @($sensors | Where-Object { $_.sensorType -in @('domainControllerIntegrated', 'domainControllerStandalone') })

        if ($allDcSensors.Count -eq 0) {
            $passed             = $false
            $testResultMarkdown = "❌ Microsoft Defender for Identity is onboarded but no domain controller sensors are registered.`n`n%TestResult%"
        }
        else {
            # Classify each sensor field-by-field per the spec enum mapping, then compute
            # per-sensor and overall verdicts using Fail > Investigate > Pass precedence.
            foreach ($sensor in $allDcSensors) {
                $deployVerdict = switch ($sensor.deploymentStatus) {
                    'upToDate'                                                      { 'Pass' }
                    { $_ -in @('updating', 'syncing', 'unknownFutureValue') }       { 'Investigate' }
                    # 'outdated' is unadjudicated (open product call); treat as Investigate pending GA decision
                    'outdated'                                                      { 'Investigate' }
                    { $_ -in @('updateFailed', 'startFailure', 'unreachable',
                               'disconnected', 'notConfigured') }                  { 'Fail' }
                    default                                                         { 'Fail' }
                }
                $serviceVerdict = switch ($sensor.serviceStatus) {
                    'running'                                                       { 'Pass' }
                    { $_ -in @('starting', 'onboarding', 'unknown',
                               'unknownFutureValue') }                              { 'Investigate' }
                    # 'stopped' and 'disabled' are unadjudicated (open product call); treat as Investigate pending GA decision
                    { $_ -in @('stopped', 'disabled') }                            { 'Investigate' }
                    default                                                         { 'Fail' }
                }
                $healthVerdict = switch ($sensor.healthStatus) {
                    'healthy'            { 'Pass' }
                    'unknownFutureValue' { 'Investigate' }
                    default              { 'Fail' }
                }
                $issuesVerdict = if ($sensor.openHealthIssuesCount -eq 0) { 'Pass' } else { 'Fail' }

                $fieldVerdicts = @($deployVerdict, $serviceVerdict, $healthVerdict, $issuesVerdict)
                $sensorVerdict = if     ($fieldVerdicts -contains 'Fail')        { 'Fail' }
                                 elseif ($fieldVerdicts -contains 'Investigate') { 'Investigate' }
                                 else                                            { 'Pass' }
                $sensor | Add-Member -NotePropertyName SensorVerdict -NotePropertyValue $sensorVerdict -Force
            }

            $allVerdicts = @($allDcSensors | Select-Object -ExpandProperty SensorVerdict)
            if ($allVerdicts -contains 'Fail') {
                $passed             = $false
                $testResultMarkdown = "❌ One or more Microsoft Defender for Identity domain controller sensors are missing, unhealthy, outdated, or not running.`n`n%TestResult%"
            }
            elseif ($allVerdicts -contains 'Investigate') {
                $customStatus       = 'Investigate'
                $testResultMarkdown = "⚠️ One or more domain controller sensors report a transient or unrecognised status. Review sensor health in the Defender XDR portal.`n`n%TestResult%"
            }
            else {
                $passed             = $true
                $testResultMarkdown = "✅ All Microsoft Defender for Identity domain controller sensors are installed, healthy, up-to-date, and running.`n`n%TestResult%"
            }
        }
    }
    #endregion Assessment Logic

    #region Report Generation
    $mdInfo     = ''
    $portalLink = 'https://security.microsoft.com/securitysettings/identities'

    if ($allDcSensors.Count -gt 0) {
        # Per spec: on Fail show Fail+Investigate sensors; on Investigate show Investigate only; on Pass show all
        $reportSensors = if ($passed) {
            $allDcSensors
        } elseif ($customStatus -eq 'Investigate') {
            @($allDcSensors | Where-Object { $_.SensorVerdict -eq 'Investigate' })
        } else {
            @($allDcSensors | Where-Object { $_.SensorVerdict -in @('Fail', 'Investigate') })
        }

        $maxDisplay     = 10
        $totalCount     = $reportSensors.Count
        $sortedSensors  = $reportSensors | Sort-Object -Property domainName, displayName
        $displaySensors = $sortedSensors | Select-Object -First $maxDisplay
        $isTruncated    = $totalCount -gt $maxDisplay

        $hasFailures = ($reportSensors | Where-Object { $_.SensorVerdict -eq 'Fail' } | Measure-Object).Count -gt 0

        if ($isTruncated -or $hasFailures) {
            $mdInfo += "[Defender XDR > Settings > Identities > Sensors]($portalLink)`n`n"
        }

        if ($isTruncated) {
            $mdInfo += "Showing $maxDisplay of $totalCount sensors.`n`n"
        }

        $mdInfo += "| Sensor Display Name | Domain | Sensor Type | Version | Deployment Status | Health Status | Service Status | Open Health Issues | Status |`n"
        $mdInfo += "| :--- | :--- | :--- | :--- | :--- | :--- | :--- | ---: | :--- |`n"

        foreach ($sensor in $displaySensors) {
            $rowStatus  = switch ($sensor.SensorVerdict) {
                'Pass'        { '✅ Pass' }
                'Investigate' { '⚠️ Investigate' }
                default       { '❌ Fail' }
            }
            $sensorName = Get-SafeMarkdown -Text $sensor.displayName
            $mdInfo += "| $sensorName | $($sensor.domainName) | $($sensor.sensorType) | $($sensor.version) | $($sensor.deploymentStatus) | $($sensor.healthStatus) | $($sensor.serviceStatus) | $($sensor.openHealthIssuesCount) | $rowStatus |`n"
        }

        if ($isTruncated) {
            $mdInfo += "| ... | ... | ... | ... | ... | ... | ... | ... | ... |`n"
        }
    }

    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '41002'
        Status = $passed
        Result = $testResultMarkdown
    }
    if ($null -ne $customStatus) {
        $params.CustomStatus = $customStatus
    }
    Add-ZtTestResultDetail @params
}
