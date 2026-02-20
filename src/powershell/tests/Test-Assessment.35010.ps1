<#
.SYNOPSIS
    Double Key Encryption labels are configured

.DESCRIPTION
    Double Key Encryption (DKE) provides an additional layer of protection for highly sensitive data by requiring two keys to decrypt content:
    one managed by Microsoft and one managed by the customer. This "hold your own key" approach ensures Microsoft cannot decrypt customer
    content even with legal compulsion, meeting stringent regulatory requirements for data sovereignty and control.

    However, DKE introduces significant operational complexity including dedicated key service infrastructure, reduced feature compatibility,
    and increased support burden. Organizations that deploy DKE should maintain 1-3 labels reserved for truly mission-critical or heavily
    regulated data. Excessive DKE label proliferation (4 or more labels) indicates potential misuse and creates management overhead, user
    confusion about when to apply DKE versus standard encryption, and reduces collaboration capabilities.

    DKE should never be broadly deployed across general business content. Overuse of DKE creates operational risk where key service
    unavailability prevents access to business-critical documents.

.NOTES
    Test ID: 35010
    Pillar: Data
    Risk Level: Low
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
        Title = 'Double Key Encryption labels are configured',
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
        $totalLabelsCount = $allLabels.Count
        $dkeLabelsCount = ($allLabels | Where-Object { $_.DkeEnabled }).Count
    }
    catch {
        $errorMsg = $_
        Write-PSFMessage "Error querying Sensitivity Labels: $_" -Level Error
    }
    #endregion Data Collection

    #region Assessment Logic
    $passed = $false
    $customStatus  = $null
    $testResultMarkdown = ''

    if ($errorMsg) {
        # Investigate scenario - Query failed
        $customStatus = 'Investigate'
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
        $customStatus = 'Investigate'
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
    if ($customStatus) {
        $params.CustomStatus = $customStatus
    }

    # Add test result details
    Add-ZtTestResultDetail @params
}
