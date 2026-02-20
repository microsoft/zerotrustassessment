<#
.SYNOPSIS
    Email label policies inherit sensitivity from attachments

.DESCRIPTION
    This test checks if sensitivity label policies have the attachmentaction setting enabled
    to automatically inherit labels from file attachments to email messages, and verifies
    that labels are properly scoped to both files and emails to participate in inheritance.

.NOTES
    Test ID: 35014
    Category: Label Policy Configuration
    Pillar: Data
    Risk Level: Medium
#>

function Test-Assessment-35014 {
    [ZtTest(
        Category = 'Label Policy Configuration',
        ImplementationCost = 'Low',
        MinimumLicense = ('Microsoft 365 E3'),
        Pillar = 'Data',
        RiskLevel = 'Medium',
        SfiPillar = 'Protect tenants and production systems',
        TenantType = ('Workforce'),
        TestId = 35014,
        Title = 'Email label policies inherit sensitivity from attachments',
        UserImpact = 'High'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking email label inheritance configuration'
    Write-ZtProgress -Activity $activity -Status 'Getting enabled label policies'

    $errorMsg = $null
    $enabledPolicies = @()
    $allLabels = @()

    try {
        # Q1: Retrieve all enabled sensitivity label policies to check attachmentaction setting
        $enabledPolicies = Get-LabelPolicy -ErrorAction Stop | Where-Object { $_.Enabled -eq $true }

        # Q2: Retrieve all labels to check for Files & Emails scope
        Write-ZtProgress -Activity $activity -Status 'Getting sensitivity labels'
        $allLabels = Get-Label -ErrorAction Stop
    }
    catch {
        $errorMsg = $_
        Write-PSFMessage "Error querying label policies or labels: $_" -Level Error
    }
    #endregion Data Collection

    #region Assessment Logic
    $policiesWithInheritance = @()
    $dualScopedLabels = @()
    $xmlParseErrors = @()
    $passed = $false
    $customStatus = $null

    if ($errorMsg) {
        $testResultMarkdown = "⚠️ Unable to query label policies or sensitivity labels, so the ``attachmentaction`` setting could not be evaluated. Check label policy settings in the Purview portal to confirm inheritance is explicitly enabled, and verify PowerShell access to label policies and labels. Captured error: $($errorMsg)`n`n%TestResult%"
        $customStatus = 'Investigate'
    }
    else {
        try {
            # Step 1: Check policies for attachmentaction setting
            foreach ($policy in $enabledPolicies) {
                # Use common function to parse PolicySettingsBlob XML
                $parsedSettings = Get-LabelPolicySettings -PolicySettingsBlob $policy.PolicySettingsBlob -PolicyName $policy.Name

                # Track XML parsing errors
                if ($parsedSettings.ParseError) {
                    $xmlParseErrors += [PSCustomObject]@{
                        PolicyName = $policy.Name
                        Error      = $parsedSettings.ParseError
                    }
                }

                # Check if attachmentaction is set to 'automatic' or 'recommended'
                $hasInheritance = $parsedSettings.AttachmentAction -in @('automatic', 'recommended')

                if ($hasInheritance) {
                    $policiesWithInheritance += [PSCustomObject]@{
                        PolicyName       = $policy.Name
                        AttachmentAction = $parsedSettings.AttachmentAction
                    }
                }
            }

            # Step 2: Check labels for Files & Emails scope
            # ContentType contains comma-separated values like 'File, Email' or 'File, Email, Site, UnifiedGroup'
            foreach ($label in $allLabels) {
                $contentType = $label.ContentType
                $hasFileScope = $contentType -like '*File*'
                $hasEmailScope = $contentType -like '*Email*'

                if ($hasFileScope -and $hasEmailScope) {
                    $dualScopedLabels += [PSCustomObject]@{
                        DisplayName = $label.DisplayName
                        Name        = $label.Name
                        ContentType = 'Files & Emails'
                        Priority    = $label.Priority
                    }
                }
            }
        }
        catch {
            Write-PSFMessage "Error parsing label policy settings: $_" -Level Error
            $testResultMarkdown = "⚠️ Unable to determine email label inheritance status due to unexpected policy settings structure: $_`n`n%TestResult%"
            $customStatus = 'Investigate'
        }

        # Step 3: Determine pass/fail status and message (only if no error occurred)
        if ($null -eq $customStatus){
            if ($policiesWithInheritance.Count -gt 0 -and $dualScopedLabels.Count -gt 0) {
                $passed = $true
                $testResultMarkdown = "✅ Email label inheritance from attachments is configured. At least one label policy has the ``attachmentaction`` setting enabled, and labels with Files & Emails scope are available to inherit from attachments to email messages.`n`n%TestResult%"
            }
            else {
                $passed = $false
                $testResultMarkdown = "❌ Email label inheritance is not configured. No label policies have the ``attachmentaction`` setting enabled, or no labels are scoped to both files and emails to participate in inheritance.`n`n%TestResult%"
            }
        }
    }
    #endregion Assessment Logic

    #region Report Generation
    $mdInfo = ''

    # Portal Links
    $labelPoliciesLink = 'https://purview.microsoft.com/informationprotection/labelpolicies'
    $labelsLink = 'https://purview.microsoft.com/informationprotection/informationprotectionlabels/sensitivitylabels'

    # Build policy table rows
    $policyTableRows = ''
    if ($policiesWithInheritance.Count -gt 0) {
        foreach ($policy in $policiesWithInheritance) {
            $policyTableRows += "| $($policy.PolicyName) | $($policy.AttachmentAction) |`n"
        }
    }

    # Build label table rows
    $labelTableRows = ''
    if ($dualScopedLabels.Count -gt 0) {
        # Sort by priority (lower number = higher priority)
        $sortedLabels = $dualScopedLabels | Sort-Object -Property Priority
        foreach ($label in $sortedLabels) {
            $labelTableRows += "| $($label.DisplayName) | $($label.ContentType) | $($label.Priority) |`n"
        }
    }

    # Build XML parsing error rows
    $errorTableRows = ''
    if ($xmlParseErrors.Count -gt 0) {
        foreach ($parseError in $xmlParseErrors) {
            $errorTableRows += "| $($parseError.PolicyName) | $($parseError.Error) |`n"
        }
    }

    $inheritanceSetting = if($passed) {'True'} elseif ($customStatus -eq 'Investigate') {'Unknown'} else {'False'}

    # Build report using format template
    $formatTemplate = @'
{0}{1}
**Summary:**

- Policies with attachmentaction enabled: {2}
- Labels with Files & Emails scope: {3}
- Inheritance setting found: {4}
{5}
'@

    # Build policies section
    $policiesSection = ''
    if ($policiesWithInheritance.Count -gt 0) {
        $policiesSection = @"

### [Policies with attachmentaction setting]($labelPoliciesLink)

| Policy name | Inherit label from attachments |
| :---------- | :----------------------------- |
$policyTableRows
"@
    }

    # Build labels section
    $labelsSection = ''
    if ($dualScopedLabels.Count -gt 0) {
        $labelsSection = @"

### [Dual-scoped labels (ready for inheritance)]($labelsLink)

| Label name | Content type | Priority |
| :--------- | :----------- | :------- |
$labelTableRows
"@
    }

    # Build error section
    $errorSection = ''
    if ($xmlParseErrors.Count -gt 0) {
        $errorSection = @"

### ⚠️ XML Parsing Errors

The following policies could not be parsed and were excluded from analysis:

| Policy Name | Error |
| :---------- | :---- |
$errorTableRows

**Note**: These policies were treated as having no ``attachmentaction`` configured.
"@
    }

    $mdInfo = $formatTemplate -f $policiesSection, $labelsSection, $policiesWithInheritance.Count, $dualScopedLabels.Count, $inheritanceSetting, $errorSection

    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '35014'
        Title  = 'Email label inheritance from attachments configured'
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
