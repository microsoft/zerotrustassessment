<#
.SYNOPSIS
Checks whether co-authoring is enabled for encrypted documents with sensitivity labels.
#>

function Test-Assessment-35009 {
    [ZtTest(
        Category = 'Sensitivity Labels',
        ImplementationCost = 'Low',
        MinimumLicense = ('Microsoft 365 E5'),
        Pillar = 'Data',
        RiskLevel = 'Low',
        SfiPillar = '',
        TenantType = ('Workforce'),
        TestId = 35009,
        Title = 'Co-Authoring Enabled for Encrypted Documents',
        UserImpact = 'High'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = "Checking co-authoring is enabled for encrypted documents"
    Write-ZtProgress -Activity $activity -Status "Getting policy configuration"

    # Q1: Retrieve policy configuration settings
    try {
        $policyConfig = Get-PolicyConfig -ErrorAction Stop
    }
    catch {
        Write-PSFMessage "Failed to retrieve policy configuration: $_" -Tag Test -Level Warning
        Add-ZtTestResultDetail -SkippedBecause NotConnectedSecurityCompliance
        return
    }

    # Q2: Check EnableLabelCoauth property value
    $enableLabelCoauth = $policyConfig.EnableLabelCoauth

    #endregion Data Collection

    #region Assessment Logic

    if ($enableLabelCoauth -eq $true) {
        $passed = $true
        $testResultMarkdown = "✅ Co-authoring is enabled for encrypted documents with sensitivity labels.`n`n%TestResult%"
    }
    elseif ($enableLabelCoauth -eq $false) {
        $passed = $false
        $testResultMarkdown = "❌ Co-authoring is disabled for encrypted documents.`n`n%TestResult%"
    }
    else {
        $passed = $false
        $customStatus = 'Investigate'
        $testResultMarkdown = "⚠️ Policy configuration exists but EnableLabelCoauth setting cannot be determined.`n`n%TestResult%"
    }

    #endregion Assessment Logic

    #region Report Generation
    $reportDetails = ""
    $reportDetails += "`n`n## Configuration Details`n`n"
    $reportDetails += "| Setting | Status |`n"
    $reportDetails += "| :------ | :----- |`n"
    $statusDisplay = if ($enableLabelCoauth -eq $true) { '✅ Enabled' } elseif ($enableLabelCoauth -eq $false) { '❌ Disabled' } else { '-' }
    $reportDetails += "| EnableLabelCoauth | $statusDisplay |`n"

    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $reportDetails

    #endregion Report Generation

    $params = @{
        TestId = '35009'
        Title  = 'Co-Authoring Enabled for Encrypted Documents'
        Status = $passed
        Result = $testResultMarkdown
    }
    if ($customStatus) {
        $params.CustomStatus = $customStatus
    }

    Add-ZtTestResultDetail @params

}
