<#
.SYNOPSIS
    Validates that Private Access Sensors are deployed on domain controllers and enforcing strong authentication policies.

.DESCRIPTION
    This test checks if Microsoft Entra Private Access Sensors are deployed to domain controllers
    and configured to enforce strong authentication policies (status active and not in audit mode).

.NOTES
    Test ID: 25403
    Category: Private Access
    Required API: onPremisesPublishingProfiles/privateAccess/sensors (beta)
#>

function Test-Assessment-25403 {
    [ZtTest(
        Category = 'Private Access',
        ImplementationCost = 'Medium',
        MinimumLicense = ('Entra_Suite', 'Entra_Premium_Private_Access'),
        Pillar = 'Network',
        RiskLevel = 'High',
        SfiPillar = 'Protect networks',
        TenantType = ('Workforce'),
        TestId = 25403,
        Title = 'DC Agent is deployed and enforcing strong authentication policies',
        UserImpact = 'Medium'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking Private Access Sensors on domain controllers'
    Write-ZtProgress -Activity $activity -Status 'Getting Private Access Sensors'

    # Query all Private Access Sensors
    $sensors = Invoke-ZtGraphRequest -RelativeUri 'onPremisesPublishingProfiles/privateAccess/sensors' -ApiVersion beta
    #endregion Data Collection

    #region Assessment Logic
    # Initialize test variables
    $testResultMarkdown = ''
    $passed = $false

    if ($null -eq $sensors -or $sensors.Count -eq 0) {
        # No sensors found - fail
        $passed = $false
        $testResultMarkdown = "❌ Microsoft Entra Private Access Sensors for domain controllers is not deployed.`n`n%TestResult%"
    }
    else {
        # Identify sensors that are active and enforcing (not in audit mode)
        $enforcingSensors = $sensors | Where-Object { $_.status -eq 'active' -and $_.isAuditMode -eq $false }
        $nonEnforcingSensors = $sensors | Where-Object { $_.status -ne 'active' -or $_.isAuditMode -eq $true }

        # Determine pass/fail status
        if ($enforcingSensors.Count -gt 0 -and $nonEnforcingSensors.Count -eq 0) {
            # All sensors are active and enforcing - pass
            $passed = $true
            $testResultMarkdown = "✅ Microsoft Entra Private Access for domain controllers is deployed and enforcing strong authentication policies.`n`n%TestResult%"
        }
        elseif ($enforcingSensors.Count -eq 0) {
            # No sensors are enforcing - fail
            $passed = $false
            $testResultMarkdown = "❌ Microsoft Entra Private Access Sensors are deployed but strong authentication policies are not configured.`n`n%TestResult%"
        }
        else {
            # Some sensors enforcing, some not - partial deployment warning (fail)
            $passed = $false
            $testResultMarkdown = "⚠️ Microsoft Entra Private Access Sensors are partially configured. Some domain controllers are not enforcing strong authentication policies.`n`n%TestResult%"
        }
    }
    #endregion Assessment Logic

    #region Report Generation
    # Build detailed markdown information
    $mdInfo = ''

    if ($sensors -and $sensors.Count -gt 0) {
        $reportTitle = "Private Access Sensors"

        $mdInfo += "`n## $reportTitle`n`n"
        $mdInfo += "[Open Private Access in Entra Portal](https://entra.microsoft.com/#view/Microsoft_Azure_Network_Access/PrivateAccessOverview.ReactView)`n`n"

        # Summary statistics
        $mdInfo += "- **Total sensors**: $($sensors.Count)`n"
        $mdInfo += "- **Active and enforcing**: $($enforcingSensors.Count)`n"
        $mdInfo += "- **Not enforcing**: $($nonEnforcingSensors.Count)`n`n"

        # Show warning for sensors not enforcing
        if ($nonEnforcingSensors.Count -gt 0) {
            $mdInfo += "**⚠️ Sensors not enforcing policies:** $($nonEnforcingSensors.Count)`n`n"
        }

        # Build table rows - show problematic sensors first
        $allSensors = @()
        $allSensors += $nonEnforcingSensors | ForEach-Object { $_ | Add-Member -NotePropertyName 'Priority' -NotePropertyValue 1 -PassThru -Force }
        $allSensors += $enforcingSensors | ForEach-Object { $_ | Add-Member -NotePropertyName 'Priority' -NotePropertyValue 2 -PassThru -Force }

        $tableRows = $allSensors | Sort-Object -Property Priority, machineName | ForEach-Object {
            $statusIcon = if ($_.status -eq 'active') { '✅' } else { '❌' }
            $auditModeIcon = if ($_.isAuditMode) { '⚠️ Yes' } else { '✅ No' }
            $machineName = Get-SafeMarkdown $_.machineName
            $version = Get-SafeMarkdown $_.version
            $externalIp = Get-SafeMarkdown $_.externalIp

            "| $machineName | $statusIcon $($_.status) | $auditModeIcon | $version | $externalIp |"
        }

        $mdInfo += @'
| Machine name | Status | Audit mode | Version | External IP |
| :----------- | :----- | :--------- | :------ | :---------- |
{0}

'@ -f ($tableRows -join "`n")
    }

    # Replace the placeholder with detailed information
    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '25403'
        Title  = 'DC Agent is deployed and enforcing strong authentication policies'
        Status = $passed
        Result = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
