<#
.SYNOPSIS
    Container labels are configured for Teams, groups, and sites

.DESCRIPTION
    This test evaluates sensitivity label configuration to ensure container labels
    are enabled for Microsoft Teams, Microsoft 365 Groups, and SharePoint sites.
    Container labels enforce consistent security policies at the workspace level,
    controlling external sharing, guest access, and device restrictions.

.NOTES
    Test ID: 35012
    Category: Sensitivity Labels Configuration
    Required APIs: Get-Label (Exchange PowerShell)
#>

function Test-Assessment-35012 {

    [ZtTest(
        Category = 'Sensitivity Labels Configuration',
        ImplementationCost = 'Medium',
        MinimumLicense = ('Microsoft 365 E5'),
        Pillar = 'Data',
        RiskLevel = 'Medium',
        SfiPillar = 'Protect tenants and production systems',
        TenantType = 'Workforce',
        TestId = 35012,
        Title = 'Container labels are configured for Teams, groups, and sites',
        UserImpact = 'High'
    )]
    [CmdletBinding()]
    param()

    #region Helper Functions

    function Get-ContainerLabelSummary {
        <#
        .SYNOPSIS
            Extracts container label details from a sensitivity label.
        .OUTPUTS
            PSCustomObject with container label details per spec.
        #>
        param(
            [object]$Label
        )

        # Extract content types from label
        $contentType = if ($Label.ContentType) { $Label.ContentType } else { 'Not specified' }

        # Use null-coalescing to provide default values for potentially missing properties
        $labelName = if ($null -ne $Label.Name) { $Label.Name } else { 'Unknown' }
        $displayName = if ($null -ne $Label.DisplayName) { $Label.DisplayName } else { 'Not specified' }
        $isParent = if ($null -ne $Label.IsParent) { $Label.IsParent } else { $false }
        $priority = if ($null -ne $Label.Priority) { $Label.Priority } else { 'N/A' }

        return [PSCustomObject]@{
            LabelName   = $labelName
            ContentType = $contentType
            DisplayName = $displayName
            IsParent    = $isParent
            Priority    = $priority
        }
    }

    function Test-ContainerLabel {
        <#
        .SYNOPSIS
            Tests if a label has both Site and UnifiedGroup scopes in ContentType.
        .OUTPUTS
            Boolean indicating whether the label is a container label.
        #>
        param([object]$Label)

        if ($null -eq $Label.ContentType -or
            ([string]::IsNullOrWhiteSpace($Label.ContentType) -and $Label.ContentType -isnot [array])) {
            return $false
        }

        # Handle ContentType as both array and string
        # Get-Label may return ContentType as an array or a comma-separated string
        $types = if ($Label.ContentType -is [array]) {
            $Label.ContentType
        } else {
            $Label.ContentType -split ',\s*'
        }

        $hasSite = @($types | Where-Object { $_ -eq 'Site' }).Count -gt 0
        $hasUnifiedGroup = @($types | Where-Object { $_ -eq 'UnifiedGroup' }).Count -gt 0

        return ($hasSite -and $hasUnifiedGroup)
    }

    #endregion Helper Functions

    #region Data Collection

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose
    $activity = 'Evaluating container label configuration'
    Write-ZtProgress -Activity $activity -Status 'Retrieving sensitivity labels'

    # Query Q1: Retrieve all sensitivity labels
    $allLabels = $null
    $containerLabels = @()
    $queryError = $false

    try {
        $allLabels = Get-Label -ErrorAction Stop
    }
    catch {
        Write-PSFMessage -Level Warning -Message "Failed to retrieve sensitivity labels: $_"
        $queryError = $true
    }

    # Query Q2: Filter for container-enabled labels (both Site and UnifiedGroup scopes in ContentType)
    if ($null -ne $allLabels -and $allLabels.Count -gt 0) {

        Write-ZtProgress -Activity $activity -Status 'Filtering container-enabled labels'

        foreach ($label in $allLabels) {
            $isContainer = Test-ContainerLabel -Label $label
            if ($isContainer) {
                $containerLabels += $label
            }
        }
    }

    #endregion Data Collection

    #region Assessment Logic

    # Initialize evaluation containers
    $passed             = $false
    $customStatus       = $null
    $testResultMarkdown = ''
    $labelResults       = @()

    # Step 1: Check if query execution failed
    if ($queryError) {

        $customStatus = 'Investigate'
        $testResultMarkdown =
            "⚠️ Query fails or unable to retrieve label scope information due to permissions issues or service connection failure. Ensure the Security & Compliance PowerShell module is connected and the account has appropriate permissions to retrieve label properties."

    }
    # Step 2: Check if container labels exist (count >= 1) - Pass (even if some labels had parse errors)
    elseif ($containerLabels.Count -ge 1) {

        # Container labels are configured - Pass
        $passed = $true
        $testResultMarkdown =
            "✅ Container labels are configured for Teams, Groups, and SharePoint sites.`n`n%TestResult%"

        # Build label results for reporting
        foreach ($label in $containerLabels) {
            $labelResults += Get-ContainerLabelSummary -Label $label
        }

    }
    # Step 3: Count = 0 - Fail
    else {

        # No container labels configured
        # Per spec: "Fail: No container labels are configured (acceptable if Teams/Groups not used; may be a gap if collaboration workspaces exist)"
        $passed = $false
        $testResultMarkdown =
            "❌ No container labels are configured (acceptable if Teams/Groups not used; may be a gap if collaboration workspaces exist).`n`n%TestResult%"

    }

    #endregion Assessment Logic

    #region Report Generation

    $mdInfo  = "`n## Summary`n`n"
    $mdInfo += "| Metric | Value |`n|:---|:---|`n"
    $mdInfo += "| Total sensitivity labels | $(if ($allLabels) { $allLabels.Count } else { 0 }) |`n"
    $mdInfo += "| Container-protected labels | $($containerLabels.Count) |`n`n"

    if ($labelResults.Count -gt 0) {
        $tableRows = ""
        $formatTemplate = @'
## [Container label details](https://purview.microsoft.com/informationprotection/informationprotectionlabels/sensitivitylabels)

| Label name | Content type | Display name | Is parent | Priority |
|:---|:---|:---|:---|:---|
{0}
'@
        foreach ($r in $labelResults) {
            $labelLink = "https://purview.microsoft.com/informationprotection/informationprotectionlabels/sensitivitylabels"
            $linkedLabelName = "[{0}]({1})" -f (Get-SafeMarkdown $r.LabelName), $labelLink

            $tableRows += "| $linkedLabelName | $(Get-SafeMarkdown $r.ContentType) | $(Get-SafeMarkdown $r.DisplayName) | $($r.IsParent) | $($r.Priority) |`n"
        }
        $mdInfo += $formatTemplate -f $tableRows
    }

    # Replace the placeholder with detailed information
    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo

    #endregion Report Generation

    $params = @{
        TestId = '35012'
        Title  = 'Container labels are configured for Teams, Groups, and Sites'
        Status = $passed
        Result = $testResultMarkdown
    }

    # Add CustomStatus if status is 'Investigate'
    if ($null -ne $customStatus) {
        $params.CustomStatus = $customStatus
    }

    # Add test result details
    Add-ZtTestResultDetail @params
}
