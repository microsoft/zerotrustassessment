<#
.SYNOPSIS
    Checks for excessive Double Key Encryption (DKE) label proliferation
.DESCRIPTION
    Verifies that organizations maintain appropriate limits on DKE labels (5 or fewer) to avoid operational complexity,
    user confusion, and management overhead. DKE should be reserved for truly critical data requiring stringent regulatory protection.

.NOTES
    Test ID: 35010
    Category: Encryption
    Required Module: ExchangeOnlineManagement v3.5.1+
    Required Connection: Connect-IPPSSession
#>

function Test-Assessment-35010 {
    [ZtTest(
        Category = 'Encryption',
        ImplementationCost = 'Medium',
        MinimumLicense = ('Microsoft 365 E5'),
        Pillar = 'Data',
        RiskLevel = 'Low',
        TenantType = ('Workforce'),
        TestId = 35010,
        Title = 'Double Key Encryption (DKE) Labels',
        UserImpact = 'High'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose
    $activity = 'Checking Double Key Encryption (DKE) label configuration'
    Write-ZtProgress -Activity $activity -Status 'Querying sensitivity labels'

    $allLabels = @()
    $errorMsg = $null
    $dkeLabelsCount = 0
    $totalLabelsCount = 0

    try {
        # Query Q1: Retrieve all sensitivity labels
        $labels = Get-Label -ErrorAction Stop | Select-Object -Property Name, Disabled, Capabilities, LabelActions

        # Extract and normalize data
        foreach ($label in $labels) {
            $isDkeEnabled = $label.Capabilities -contains "DoubleKeyEncryption"
            $dkeEndpointUrl = 'N/A'

            if ($isDkeEnabled) {
                # Extract DKE endpoint URL from LabelActions
                $labelActions = $label.LabelActions | ConvertFrom-Json
                $encryptLabelAction = $labelActions | Where-Object { $_.Type -eq "encrypt" }
                $dkeEndpointUrl = $encryptLabelAction.Settings | Where-Object { $_.Key -eq "doublekeyencryptionurl" } | Select-Object -ExpandProperty Value

                if ($null -eq $dkeEndpointUrl) {
                    $dkeEndpointUrl = 'N/A'
                }
            }

            $allLabels += [PSCustomObject]@{
                Name           = $label.Name
                Disabled       = $label.Disabled
                DkeEnabled     = $isDkeEnabled
                DkeEndpointUrl = $dkeEndpointUrl
            }
        }

        # Calculate counts
        $totalLabelsCount = @($allLabels).Count
        $dkeLabelsCount = @($allLabels | Where-Object { $_.DkeEnabled }).Count
    }
    catch {
        $errorMsg = $_
        Write-PSFMessage "Error querying Sensitivity Labels: $_" -Level Error
    }
    #endregion Data Collection

    #region Assessment Logic
    $passed = $false
    $investigateFlag = $false
    $testResultMarkdown = ''

    if ($errorMsg) {
        # Investigate scenario - Query failed
        $investigateFlag = $true
        $testResultMarkdown = "⚠️ Unable to determine DKE label configuration due to query failure, connection issues, or insufficient permissions.`n`n%TestResult%"
    }
    elseif ($dkeLabelsCount -eq 0) {
        # Fail scenario - No DKE labels
        $passed = $false
        $testResultMarkdown = "❌ No DKE labels found - organization should evaluate deployment for mission-critical or highly regulated data.`n`n%TestResult%"
    }
    elseif ($dkeLabelsCount -ge 1 -and $dkeLabelsCount -le 3) {
        # Pass scenario - 1-3 DKE labels
        $passed = $true
        $testResultMarkdown = "✅ DKE labels appropriately deployed (1-3 labels for mission-critical and regulated data).`n`n%TestResult%"
    }
    else {
        # Investigate scenario - 4+ DKE labels (excessive)
        $investigateFlag = $true
        $testResultMarkdown = "⚠️ 4 or more DKE labels detected - review each label's business justification to confirm appropriate use; excessive DKE beyond critical data indicates potential misuse.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    $mdInfo = ''

    if ($totalLabelsCount -gt 0) {
        $title = 'Sensitivity Label Details'
        $portalLink = 'https://purview.microsoft.com/informationprotection/informationprotectionlabels/sensitivitylabels'

        $formatTemplate = @'

### Summary

- Total Sensitivity Labels: {0}
- DKE Enabled Labels: {1}

### [{2}]({3})

| Label name | Disabled | DKE enabled | DKE endpoint url |
|:-----------|:---------|:------------|:-----------------|
{4}

'@

        $tableRows = ''
        foreach ($label in $allLabels | Sort-Object -Property DkeEnabled -Descending) {
            $tableRows += "| $($label.Name) | $($label.Disabled) | $($label.DkeEnabled) | $($label.DkeEndpointUrl) |`n"
        }

        $mdInfo = $formatTemplate -f $totalLabelsCount, $dkeLabelsCount, $title, $portalLink, $tableRows.TrimEnd("`n")
    }

    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '35010'
        Title  = 'Double Key Encryption (DKE) Labels'
        Status = $passed
        Result = $testResultMarkdown
    }

    # Add CustomStatus if status is 'Investigate'
    if ($investigateFlag) {
        $params.CustomStatus = 'Investigate'
    }

    # Add test result details
    Add-ZtTestResultDetail @params
}
