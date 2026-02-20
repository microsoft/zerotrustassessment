<#
.SYNOPSIS
    Sensitivity labels with encryption are configured

.DESCRIPTION
    This test checks if encryption-enabled sensitivity labels exist by:
    1. Retrieving all sensitivity labels with LabelActions
    2. Parsing LabelActions JSON to identify encrypt actions
    3. Analyzing encryption settings (type, permissions, co-authoring)

.NOTES
    Test ID: 35013
    Category: Sensitivity Labels Configuration
    Required Module: ExchangeOnlineManagement v3.5.1+
    Required Connection: Connect-IPPSSession
#>

function Test-Assessment-35013 {
    [ZtTest(
        Category = 'Sensitivity Labels Configuration',
        ImplementationCost = 'Medium',
        MinimumLicense = 'Microsoft 365 E3',
        Pillar = 'Data',
        RiskLevel = 'High',
        SfiPillar = 'Protect tenants and production systems',
        TenantType = ('Workforce', 'External'),
        TestId = 35013,
        Title = 'Sensitivity labels with encryption are configured',
        UserImpact = 'High'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose
    $activity = 'Checking encryption-enabled sensitivity labels'
    Write-ZtProgress -Activity $activity -Status 'Querying sensitivity labels'

    $getCmdletFailed = $false
    $parsingFailed = $false
    $allLabels = $null
    $encryptedLabels = @()

    # Query: Get all sensitivity labels
    try {
        $allLabels = Get-Label -ErrorAction Stop

        # Parse LabelActions to extract encryption details
        foreach ($label in $allLabels) {
            try {
                $labelActions = $label.LabelActions | ConvertFrom-Json
                $encryptAction = $labelActions | Where-Object { $_.Type -eq 'encrypt' }

                if ($null -ne $encryptAction) {
                    # Check if encryption is disabled
                    $disabledSetting = $encryptAction.Settings | Where-Object { $_.Key -eq 'disabled' }
                    if ($disabledSetting -and $disabledSetting.Value -eq 'true') {
                        continue  # Skip this label as encryption is disabled
                    }

                    # Check if DKE using Capabilities property (more reliable than LabelActions)
                    $isDKE = $label.Capabilities -contains 'DoubleKeyEncryption'

                    # Extract encryption details from Settings array (Key-Value pairs)
                    $protectionTypeSetting = $encryptAction.Settings | Where-Object { $_.Key -eq 'protectiontype' }

                    # Determine encryption type
                    if ($isDKE) {
                        $encryptionType = 'dke'
                    }
                    elseif ($protectionTypeSetting) {
                        $encryptionType = $protectionTypeSetting.Value
                    }
                    else {
                        $encryptionType = 'template'
                    }

                    $rightsDefSetting = $encryptAction.Settings | Where-Object { $_.Key -eq 'rightsdefinitions' }
                    $rightsDef = if ($rightsDefSetting) { $rightsDefSetting.Value } else { 'Not specified' }

                    $contentExpirySetting = $encryptAction.Settings | Where-Object { $_.Key -eq 'contentexpiredondateindaysornever' }
                    $contentExpiry = if ($contentExpirySetting) { $contentExpirySetting.Value } else { 'Never' }

                    # Determine if co-authoring is blocked
                    $coAuthoringBlocked = ($encryptionType -eq 'dke') -or ($contentExpiry -ne 'Never')

                    $encryptedLabels += [PSCustomObject]@{
                        Name                  = $label.DisplayName
                        EncryptionType        = $encryptionType
                        RightsDefinitions     = $rightsDef
                        CoAuthoringBlocked    = if ($coAuthoringBlocked) { 'Yes' } else { 'No' }
                    }
                }
            }
            catch {
                Write-PSFMessage "Failed to parse LabelActions for label '$($label.DisplayName)': $_" -Tag Test -Level Warning
                $parsingFailed = $true
            }
        }
    }
    catch {
        $getCmdletFailed = $true
        Write-PSFMessage "Failed to retrieve sensitivity labels: $_" -Tag Test -Level Warning
    }
    #endregion Data Collection

    #region Assessment Logic
    $testResultMarkdown = ''
    $passed = $false
    $customStatus = $null

    # Check if Get-Label cmdlet failed
    if ($getCmdletFailed) {
        $testResultMarkdown = "⚠️ Unable to determine encryption-enabled label configuration due to query failure, connection issues, or insufficient permissions.`n`n%TestResult%"
        $passed = $false
        $customStatus = 'Investigate'
    }
    # Check if labels were retrieved but parsing failed
    elseif ($parsingFailed) {
        $testResultMarkdown = "⚠️ Labels exist but encryption configuration cannot be determined for some labels.`n`n%TestResult%"
        $passed = $false
        $customStatus = 'Investigate'
    }
    # Check encrypted label count
    elseif ($encryptedLabels.Count -eq 0) {
        $testResultMarkdown = "❌ No encryption-enabled labels exist; all labels provide classification only.`n`n%TestResult%"
        $passed = $false
    }
    else {
        $testResultMarkdown = "✅ At least one encryption-enabled sensitivity label is configured.`n`n%TestResult%"
        $passed = $true
    }
    #endregion Assessment Logic

    #region Report Generation
    $mdInfo = ''

    if ($encryptedLabels.Count -gt 0) {
        $formatTemplate = @'

## [{0}]({1})

| Label name | Encryption type | Default permissions identities | Co-Authoring blocked |
| :--------- | :-------------- | :----------------------------- | :------------------: |
{2}

'@

        $reportTitle = 'Encryption Label Details'
        $portalLink = 'https://purview.microsoft.com/informationprotection/informationprotectionlabels/sensitivitylabels'

        # Build table rows
        $labelDetails = ''
        foreach ($encLabel in $encryptedLabels) {
            $name = if ($encLabel.Name) { Get-SafeMarkdown -Text $encLabel.Name } else { 'N/A' }
            $encType = switch ($encLabel.EncryptionType) {
                'template' { 'Standard RMS' }
                'dke' { 'Double Key Encryption (DKE)' }
                'userdefined' { 'User-Defined' }
                default { $encLabel.EncryptionType }
            }

            # Format rights definitions - show first 5 identities (users, groups, or domains)
            $rights = 'Not specified'
            if ($encLabel.RightsDefinitions -and $encLabel.RightsDefinitions -ne 'Not specified') {
                try {
                    # Parse the JSON string containing rights definitions
                    $rightsArray = $encLabel.RightsDefinitions | ConvertFrom-Json
                    if ($rightsArray) {
                        $identities = @($rightsArray | Where-Object { $_.Identity } | ForEach-Object { Get-SafeMarkdown -Text $_.Identity })
                        if ($identities.Count -gt 5) {
                            $rights = ($identities[0..4] -join ', ') + ', ...'
                        }
                        else {
                            $rights = $identities -join ', '
                        }
                    }
                }
                catch {
                    # If parsing fails, show fallback message
                    $rights = 'Unable to parse permissions'
                }
            }

            $coAuthBlocked = $encLabel.CoAuthoringBlocked

            $labelDetails += "| $name | $encType | $rights | $coAuthBlocked |`n"
        }

        $labelDetails += "`n**Summary:**`n"
        $labelDetails += "* Total Encryption-Enabled Labels: $($encryptedLabels.Count)`n"

        # Count by encryption type
        $standardRMS = @($encryptedLabels | Where-Object { $_.EncryptionType -eq 'template' }).Count
        $userDefined = @($encryptedLabels | Where-Object { $_.EncryptionType -eq 'userdefined' }).Count
        $dkeLabels = @($encryptedLabels | Where-Object { $_.EncryptionType -eq 'dke' }).Count

        $labelDetails += "* Standard RMS: $standardRMS`n"
        $labelDetails += "* User-Defined: $userDefined`n"
        $labelDetails += "* Double Key Encryption (DKE): $dkeLabels"

        $mdInfo = $formatTemplate -f $reportTitle, $portalLink, $labelDetails
    }

    # Replace the placeholder with detailed information
    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '35013'
        Title  = 'Encryption-Enabled Labels'
        Status = $passed
        Result = $testResultMarkdown
    }

    if ($null -ne $customStatus) {
        $params.CustomStatus = $customStatus
    }

    # Add test result details
    Add-ZtTestResultDetail @params
}
