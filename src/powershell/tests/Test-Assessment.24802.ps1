<#
.SYNOPSIS

#>

function Test-Assessment-24802 {
    [ZtTest(
    	Category = 'Tenant',
    	ImplementationCost = 'Low',
    	Pillar = 'Devices',
    	RiskLevel = 'Low',
    	SfiPillar = 'Protect tenants and isolate production',
    	TenantType = ('Workforce'),
    	TestId = 24802,
    	Title = 'Device cleanup rules maintain tenant hygiene by hiding inactive devices',
    	UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    if( -not (Get-ZtLicense Intune) ) {
        Add-ZtTestResultDetail -SkippedBecause NotLicensedIntune
        return
    }

    $activity = "Checking Device Clean-up Rule is Created"
    Write-ZtProgress -Activity $activity -Status "Getting rules"

    # Retrieve all device clean-up rules configured in Intune
    $cleanupRulesUri = 'deviceManagement/managedDeviceCleanupRules'
    $cleanupRules = Invoke-ZtGraphRequest -RelativeUri $cleanupRulesUri -ApiVersion 'beta'

    #endregion Data Collection

    #region Assessment Logic
    $passed = $false
    $testResultMarkdown = ""

    # Check if at least one device clean-up rule exists
    $passed = $cleanupRules -and $cleanupRules.Count -gt 0

    if ($passed) {
        $testResultMarkdown = "At least one device clean-up rule exists.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "No device clean-up rule exists.`n`n%TestResult%"
    }

    #endregion Assessment Logic

    #region Report Generation
    # Build the detailed sections of the markdown

    # Define variables to insert into the format string
    $reportTitle = "Device clean-up rules"
    $tableRows = ""


    if ($cleanupRules -and $cleanupRules.Count -gt 0) {
        # Create a here-string with format placeholders {0}, {1}, etc.
        $formatTemplate = @'

## {0}

| Rule Name | Platform or OS |
| :-------- | :------------- |
{1}

'@

        foreach ($cleanupRule in $cleanupRules) {
            $portalLink = 'https://intune.microsoft.com/#view/Microsoft_Intune_DeviceSettings/DevicesMenu/~/deviceCleanUp'

            $ruleName = Get-SafeMarkdown -Text $cleanupRule.displayName

            $platformType = $cleanupRule.deviceCleanupRulePlatformType

            $tableRows += @"
| [$ruleName]($portalLink) | $platformType |`n
"@
        }

        # Format the template by replacing placeholders with values
        $mdInfo = $formatTemplate -f $reportTitle, $tableRows
    }

    # Replace the placeholder with the detailed information
    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '24802'
        Title  = 'Device Clean-up Rule is Created'
        Status = $passed
        Result = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
