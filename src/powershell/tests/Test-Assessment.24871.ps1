<#
.SYNOPSIS

#>

function Test-Assessment-24871 {
    [ZtTest(
    	Category = 'Devices',
    	ImplementationCost = 'Low',
    	Pillar = 'Devices',
    	RiskLevel = 'High',
    	SfiPillar = '',
    	TenantType = ('Workforce'),
    	TestId = 24871,
    	Title = 'Automatic enrollment to Defender is enabled on Android to support threat protection',
    	UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "Checking Automatic Enrollment to Defender is enabled for Android Devices"
    Write-ZtProgress -Activity $activity -Status "Getting policy"

    # Retrieve details of the Mobile Threat Defense Connector
    $mobileThreatDefenseUri = 'deviceManagement/mobileThreatDefenseConnectors'
    $mobileThreatDefenseConnectors = Invoke-ZtGraphRequest -RelativeUri $mobileThreatDefenseUri -ApiVersion 'beta'

    if ($mobileThreatDefenseConnectors -and $null -ne $mobileThreatDefenseConnectors) {
        $defender = $mobileThreatDefenseConnectors | Where-Object { $_.id -eq 'fc780465-2017-40d4-a0c5-307022471b92' }
    }
    else {
        $defender = $null
    }

    #endregion Data Collection

    #region Assessment Logic
    $passed = $false
    $testResultMarkdown = ""

    if ($null -ne $defender) {
        if ($defender.partnerState -eq 'enabled' -and
            $defender.androidEnabled -eq $true) {
            $passed = $true
            $testResultMarkdown = "Mobile Threat Defense Connector is enabled and Android enrollment is active.`n`n%TestResult%"
        }
        else {
            $passed = $false
            $testResultMarkdown = "Mobile Threat Defense Connector is disabled or Android enrollment is not enabled.`n`n%TestResult%"
        }
    }
    else {
        $passed = $false
        $testResultMarkdown = "No Microsoft Defender for Endpoint Connector found in the tenant.`n`n%TestResult%"
    }

    #endregion Assessment Logic

    #region Report Generation
    # Build the detailed sections of the markdown

    # Define variables to insert into the format string
    $reportTitle = "Microsoft Defender for Endpoint Enrollment for Android Devices"
    $tableRows = ""

    if ($null -ne $defender) {
        # Create a here-string with format placeholders {0}, {1}, etc.
        $formatTemplate = @'

## [{0}]({1})

| Status | Android Enrollment |
| :----- | :----------------- |
{2}

'@

        $portalLink = 'https://intune.microsoft.com/#view/Microsoft_Intune_Workflows/SecurityManagementMenu/~/atp'

        $status = Get-SafeMarkdown -Text (Get-Culture).TextInfo.ToTitleCase($defender.partnerState.ToLower())
        $enrollment = Get-SafeMarkdown -Text $defender.androidEnabled

        $tableRows += @"
| $status | $enrollment |`n
"@

        # Format the template by replacing placeholders with values
        $mdInfo = $formatTemplate -f $reportTitle, $portalLink, $tableRows
    }

    # Replace the placeholder with the detailed information
    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '24871'
        Title  = 'Automatic Enrollment to Defender is enabled for Android Devices'
        Status = $passed
        Result = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
