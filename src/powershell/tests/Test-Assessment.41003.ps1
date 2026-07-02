<#
.SYNOPSIS
    Checks that Microsoft Defender for Identity sensors are installed and healthy on AD FS, AD CS, and Microsoft Entra Connect servers.
#>

function Test-Assessment-41003 {

    [ZtTest(
        Category = 'Identity threat protection',
        CompatibleLicense = ('ATA'),
        ImplementationCost = 'Medium',
        Pillar = 'SecOps',
        RiskLevel = 'High',
        Service = ('Graph'),
        SfiPillar = 'Monitor and detect cyberthreats',
        TenantType = ('Workforce'),
        TestId = 41003,
        Title = 'Microsoft Defender for Identity sensors are installed and healthy on AD FS, AD CS, and Microsoft Entra Connect servers',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose
    $activity = 'Checking Microsoft Defender for Identity sensors on AD FS, AD CS, and Microsoft Entra Connect servers'
    Write-ZtProgress -Activity $activity -Status 'Querying MDI sensor inventory'

    # Q1: List all MDI sensors registered in the workspace.
    $allSensors = $null
    try {
        $allSensors = Invoke-ZtGraphRequest -RelativeUri 'security/identities/sensors' -ApiVersion beta -ErrorAction Stop
    }
    catch {
        $httpStatus = Get-ZtHttpStatusCode -ErrorRecord $_
        if ($httpStatus -in @(401, 403)) {
            $params = @{
                TestId       = '41003'
                Title        = 'Microsoft Defender for Identity sensors are installed and healthy on AD FS, AD CS, and Microsoft Entra Connect servers'
                Status       = $false
                Result       = '⚠️ Insufficient Graph permission for SecurityIdentitiesSensors.Read.All; the assessment runtime cannot read the MDI sensor inventory.'
                CustomStatus = 'Investigate'
            }
            Add-ZtTestResultDetail @params
            return
        }
        # Transient 5xx or unexpected response shape.
        $params = @{
            TestId       = '41003'
            Title        = 'Microsoft Defender for Identity sensors are installed and healthy on AD FS, AD CS, and Microsoft Entra Connect servers'
            Status       = $false
            Result       = '⚠️ Transient Microsoft Graph error or unexpected response shape; re-run after 5-10 minutes, file a support ticket if persistent.'
            CustomStatus = 'Investigate'
        }
        Add-ZtTestResultDetail @params
        return
    }
    #endregion Data Collection

    #region Assessment Logic
    $roleSpecificTypes = @('adfsIntegrated', 'adcsIntegrated', 'adConnectIntegrated')

    # Empty sensor list: MDI not onboarded or inventory not yet propagated.
    if ($null -eq $allSensors -or @($allSensors).Count -eq 0) {
        $params = @{
            TestId       = '41003'
            Title        = 'Microsoft Defender for Identity sensors are installed and healthy on AD FS, AD CS, and Microsoft Entra Connect servers'
            Status       = $false
            Result       = '⚠️ Microsoft Defender for Identity is not onboarded in this tenant, or the sensor inventory has not yet propagated to Microsoft Graph.'
            CustomStatus = 'Investigate'
        }
        Add-ZtTestResultDetail @params
        return
    }

    # Filter to AD FS, AD CS, and Entra Connect sensor types only.
    $roleSpecificSensors = @($allSensors | Where-Object { $_.sensorType -in $roleSpecificTypes })

    # MDI is onboarded but none of the three target role types are registered.
    # The Graph API does not expose the customer's on-prem server inventory, so the
    # assessment cannot distinguish "customer does not operate these roles" from "roles
    # exist but sensors were not deployed" — return Investigate in both cases.
    if ($roleSpecificSensors.Count -eq 0) {
        $params = @{
            TestId       = '41003'
            Title        = 'Microsoft Defender for Identity sensors are installed and healthy on AD FS, AD CS, and Microsoft Entra Connect servers'
            Status       = $false
            Result       = '⚠️ Microsoft Defender for Identity is onboarded but no AD FS, AD CS, or Microsoft Entra Connect sensors are registered. The assessment cannot distinguish "customer does not operate those server roles" from "those server roles exist but no sensor is installed". Confirm out-of-band whether the customer operates any of these roles; if they do, install the corresponding MDI sensor.'
            CustomStatus = 'Investigate'
        }
        Add-ZtTestResultDetail @params
        return
    }

    $failDeployStatuses      = @('updateFailed', 'startFailure', 'unreachable', 'disconnected', 'notConfigured', 'outdated')
    $investigateDeployStatuses = @('updating', 'syncing', 'unknownFutureValue')
    $investigateSvcStatuses    = @('starting', 'onboarding', 'unknown', 'unknownFutureValue', 'disabled')

    foreach ($sensor in $roleSpecificSensors) {
        # deploymentStatus classification
        if ($sensor.deploymentStatus -eq 'upToDate') {
            $deployVerdict = 'Pass'
        } elseif ($sensor.deploymentStatus -in $investigateDeployStatuses) {
            $deployVerdict = 'Investigate'
        } elseif ($sensor.deploymentStatus -in $failDeployStatuses) {
            $deployVerdict = 'Fail'
        } else {
            # Unrecognised value — treat as Investigate (evolvable-enum sentinel pattern).
            $deployVerdict = 'Investigate'
        }

        # healthStatus: healthy → Pass; unknownFutureValue → Investigate; all others → Fail.
        if ($sensor.healthStatus -eq 'healthy') {
            $healthVerdict = 'Pass'
        } elseif ($sensor.healthStatus -eq 'unknownFutureValue') {
            $healthVerdict = 'Investigate'
        } else {
            $healthVerdict = 'Fail'
        }

        # serviceStatus classification
        if ($sensor.serviceStatus -eq 'running') {
            $svcVerdict = 'Pass'
        } elseif ($sensor.serviceStatus -in $investigateSvcStatuses) {
            $svcVerdict = 'Investigate'
        } else {
            #stopped -> fail
            $svcVerdict = 'Fail'
        }

        # openHealthIssuesCount
        $issuesVerdict = if ($sensor.openHealthIssuesCount -gt 0) { 'Fail' } else { 'Pass' }

        # Per-sensor verdict: Fail > Investigate > Pass across all four fields.
        $fieldVerdicts = @($deployVerdict, $healthVerdict, $svcVerdict, $issuesVerdict)
        if ($fieldVerdicts -contains 'Fail') {
            $sensorVerdict = 'Fail'
        } elseif ($fieldVerdicts -contains 'Investigate') {
            $sensorVerdict = 'Investigate'
        } else {
            $sensorVerdict = 'Pass'
        }

        $sensor | Add-Member -NotePropertyName 'sensorStatus'         -NotePropertyValue $sensorVerdict  -Force
        $sensor | Add-Member -NotePropertyName 'deployStatusVerdict'  -NotePropertyValue $deployVerdict  -Force
        $sensor | Add-Member -NotePropertyName 'healthStatusVerdict'  -NotePropertyValue $healthVerdict  -Force
        $sensor | Add-Member -NotePropertyName 'svcStatusVerdict'     -NotePropertyValue $svcVerdict     -Force
        $sensor | Add-Member -NotePropertyName 'issuesVerdict'        -NotePropertyValue $issuesVerdict  -Force
    }

    # Aggregate verdict across sensors: Fail > Investigate > Pass.
    $allVerdicts = @($roleSpecificSensors | Select-Object -ExpandProperty 'sensorStatus')
    $passed      = $true
    $customStatus = $null
    if ($allVerdicts -contains 'Fail') {
        $passed = $false
        $testResultMarkdown = "❌ One or more Microsoft Defender for Identity sensors on AD FS, AD CS, or Microsoft Entra Connect servers are unhealthy, outdated, or not running.`n`n%TestResult%"
    } elseif ($allVerdicts -contains 'Investigate') {
        $passed      = $false
        $customStatus = 'Investigate'
        $testResultMarkdown = "⚠️ No Microsoft Defender for Identity sensors on AD FS, AD CS, or Microsoft Entra Connect servers are in a terminal failure state, but one or more sensors are in a transient or indeterminate state and require investigation.`n`n%TestResult%"
    } else {
        $testResultMarkdown = "✅ All Microsoft Defender for Identity sensors on AD FS, AD CS, and Microsoft Entra Connect servers are installed, healthy, up-to-date, and running.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    $sensorPortalUrl = 'https://security.microsoft.com/securitysettings/identities'

    $sensorTypeDisplayNames = @{
        'adfsIntegrated'      = 'AD FS'
        'adcsIntegrated'      = 'AD CS'
        'adConnectIntegrated' = 'Microsoft Entra Connect'
    }

    # When Fail: show all Fail and Investigate sensors.
    # When Investigate: show only Investigate sensors.
    # When Pass: show all sensors.
    if (-not $passed -and $null -eq $customStatus) {
        $displaySensors = @($roleSpecificSensors | Where-Object { $_.sensorStatus -in @('Fail', 'Investigate') })
    } elseif ($customStatus -eq 'Investigate') {
        $displaySensors = @($roleSpecificSensors | Where-Object { $_.sensorStatus -eq 'Investigate' })
    } else {
        $displaySensors = @($roleSpecificSensors)
    }

    # Sort by sensorType for grouping, then by displayName within each type.
    $sortedSensors = @($displaySensors | Sort-Object -Property sensorType, displayName)
    $totalCount    = $sortedSensors.Count
    $displayRows   = @($sortedSensors | Select-Object -First 10)
    $isTruncated   = $totalCount -gt 10

    $anyNonPass    = @($roleSpecificSensors | Where-Object { $_.sensorStatus -ne 'Pass' })
    $showPortalLink = $isTruncated -or $anyNonPass.Count -gt 0

    $preTableLines = ''
    if ($isTruncated) {
        $preTableLines += "Total sensors of these types: $totalCount (showing first 10)`n`n"
    }
    if ($showPortalLink) {
        $preTableLines += "[Defender XDR > Settings > Identities > Sensors]($sensorPortalUrl)`n`n"
    }

    # Emoji lookup is invariant across rows; build it once. For every status field the
    # verdict label equals the verdict name, so a single hashtable drives all columns.
    $verdictEmoji = @{ Pass = '✅'; Investigate = '⚠️'; Fail = '❌' }

    $tableRows = ''
    foreach ($sensor in $displayRows) {
        $sensorDisplayName = Get-SafeMarkdown -Text $sensor.displayName
        $typeDisplay       = if ($sensorTypeDisplayNames.ContainsKey($sensor.sensorType)) { $sensorTypeDisplayNames[$sensor.sensorType] } else { $sensor.sensorType }
        $deployStatus      = "$($verdictEmoji[$sensor.deployStatusVerdict]) $($sensor.deploymentStatus)"
        $healthStatus      = "$($verdictEmoji[$sensor.healthStatusVerdict]) $($sensor.healthStatus)"
        $serviceStatus     = "$($verdictEmoji[$sensor.svcStatusVerdict]) $($sensor.serviceStatus)"
        $openIssues        = "$($verdictEmoji[$sensor.issuesVerdict]) $([int]$sensor.openHealthIssuesCount)"
        $rowStatus         = "$($verdictEmoji[$sensor.sensorStatus]) $($sensor.sensorStatus)"

        $tableRows += "| $sensorDisplayName | $($sensor.domainName) | $typeDisplay | $($sensor.version) | $deployStatus | $healthStatus | $serviceStatus | $openIssues | $rowStatus |`n"
    }

    if ($isTruncated) {
        $tableRows += "| ... | ... | ... | ... | ... | ... | ... | ... | ... |`n"
    }

    $mdInfo = @"
$preTableLines

| Sensor display name | Domain | Sensor type | Version | Deployment status | Health status | Service status | Open health issues | Status |
| :------------------ | :----- | :---------- | :------ | :---------------- | :------------ | :------------- | :----------------- | :----- |
$tableRows
"@

    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '41003'
        Title  = 'Microsoft Defender for Identity sensors are installed and healthy on AD FS, AD CS, and Microsoft Entra Connect servers'
        Status = $passed
        Result = $testResultMarkdown
    }
    if ($customStatus) {
        $params.CustomStatus = $customStatus
    }
    Add-ZtTestResultDetail @params
}
