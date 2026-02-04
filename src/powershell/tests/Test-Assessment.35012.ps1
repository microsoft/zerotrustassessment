<#
.SYNOPSIS
    Validates that container labels are configured for Teams, Groups, and Sites.

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
        Title = 'Container labels are configured for Teams, Groups, and Sites',
        UserImpact = 'High'
    )]
    [CmdletBinding()]
    param()

    #region Helper Functions

    function Get-ContainerLabelSummary {
        <#
        .SYNOPSIS
            Extracts container protection settings from a sensitivity label's LabelActions JSON.
        .OUTPUTS
            PSCustomObject with container protection details.
        #>
        param(
            [object]$Label,
            [object]$ProtectGroupAction,
            [object]$ProtectSiteAction
        )

        # Extract content types from label
        $contentType = if ($Label.ContentType) { $Label.ContentType -join ', ' } else { 'Not specified' }

        # Extract Group Privacy Setting from protectgroup action
        $groupPrivacy = 'Not configured'
        if ($ProtectGroupAction -and $ProtectGroupAction.Settings) {
            $privacySetting = $ProtectGroupAction.Settings | Where-Object { $_.Key -eq 'privacy' }
            if ($privacySetting) {
                $groupPrivacy = switch ($privacySetting.Value) {
                    '1' { 'Public' }
                    '2' { 'Private' }
                    default { $privacySetting.Value }
                }
            }
        }

        # Extract Site External Sharing from protectsite action
        $siteExternalSharing = 'Not configured'
        $siteGuestAccess = 'Not configured'
        if ($ProtectSiteAction -and $ProtectSiteAction.Settings) {
            # External sharing setting
            $sharingSetting = $ProtectSiteAction.Settings | Where-Object { $_.Key -eq 'externalsharingcontrol' }
            if ($sharingSetting) {
                $siteExternalSharing = switch ($sharingSetting.Value) {
                    '0' { 'Full Access' }
                    '1' { 'Limited Access' }
                    '2' { 'Block Access' }
                    default { $sharingSetting.Value }
                }
            }

            # Guest access setting
            $guestSetting = $ProtectSiteAction.Settings | Where-Object { $_.Key -eq 'allowaccesstoguestusers' }
            if ($guestSetting) {
                $siteGuestAccess = switch ($guestSetting.Value) {
                    'true' { 'Allowed' }
                    'false' { 'Blocked' }
                    default { $guestSetting.Value }
                }
            }
        }

        return [PSCustomObject]@{
            LabelName           = $Label.DisplayName
            LabelId             = $Label.Guid
            ContentType         = $contentType
            GroupPrivacySetting = $groupPrivacy
            SiteExternalSharing = $siteExternalSharing
            SiteGuestAccess     = $siteGuestAccess
        }
    }

    function Test-ContainerLabel {
        <#
        .SYNOPSIS
            Tests if a label has both protectgroup and protectsite actions in LabelActions.
        .OUTPUTS
            Hashtable with IsContainer boolean and parsed actions, or $null if parsing fails.
        #>
        param([object]$Label)

        try {
            if ([string]::IsNullOrWhiteSpace($Label.LabelActions)) {
                return @{ IsContainer = $false; ProtectGroup = $null; ProtectSite = $null }
            }

            $actions = $Label.LabelActions | ConvertFrom-Json -ErrorAction Stop
            $protectGroup = $actions | Where-Object { $_.Type -eq 'protectgroup' }
            $protectSite = $actions | Where-Object { $_.Type -eq 'protectsite' }

            return @{
                IsContainer  = ($null -ne $protectGroup -and $null -ne $protectSite)
                ProtectGroup = $protectGroup
                ProtectSite  = $protectSite
            }
        }
        catch {
            # Emit verbose message to aid troubleshooting JSON parsing failures
            $labelIdentifier = $null
            if ($null -ne $Label) {
                if ($Label.PSObject.Properties.Match('DisplayName').Count -gt 0 -and
                    -not [string]::IsNullOrWhiteSpace($Label.DisplayName)) {
                    $labelIdentifier = $Label.DisplayName
                }
                elseif ($Label.PSObject.Properties.Match('Name').Count -gt 0 -and
                    -not [string]::IsNullOrWhiteSpace($Label.Name)) {
                    $labelIdentifier = $Label.Name
                }
                elseif ($Label.PSObject.Properties.Match('Id').Count -gt 0 -and
                    -not [string]::IsNullOrWhiteSpace($Label.Id)) {
                    $labelIdentifier = $Label.Id
                }
            }

            if (-not $labelIdentifier) {
                $labelIdentifier = '<unknown label>'
            }

            $errorMessage = $_.Exception.Message
            Write-PSFMessage -Level Verbose -Tag Test -Message ("Failed to parse LabelActions JSON for label '{0}': {1}" -f $labelIdentifier, $errorMessage)

            # Return null to indicate parsing failure
            return $null
        }
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

    # Query Q2: Filter for container-enabled labels (both protectgroup and protectsite actions)
    $parseError = $false
    $containerLabelData = @()

    if ($null -ne $allLabels -and $allLabels.Count -gt 0) {

        Write-ZtProgress -Activity $activity -Status 'Filtering container-enabled labels'

        foreach ($label in $allLabels) {
            $result = Test-ContainerLabel -Label $label
            if ($null -eq $result) {
                # JSON parsing failed for at least one label
                $parseError = $true
            }
            elseif ($result.IsContainer) {
                $containerLabelData += @{
                    Label        = $label
                    ProtectGroup = $result.ProtectGroup
                    ProtectSite  = $result.ProtectSite
                }
            }
        }

        $containerLabels = $containerLabelData
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
            "⚠️ Query fails or LabelActions JSON cannot be parsed due to permissions issues or service connection failure. Ensure the Security & Compliance PowerShell module is connected and the account has appropriate permissions to retrieve label properties.`n`n%TestResult%"

    }
    # Step 2: Check if container labels exist (count >= 1) - Pass (even if some labels had parse errors)
    elseif ($containerLabels.Count -ge 1) {

        # Container labels are configured - Pass
        $passed = $true
        $testResultMarkdown =
            "✅ Container labels are configured for Teams, Groups, and SharePoint sites.`n`n%TestResult%"

        # Build label results for reporting
        foreach ($data in $containerLabels) {
            $labelResults += Get-ContainerLabelSummary -Label $data.Label -ProtectGroupAction $data.ProtectGroup -ProtectSiteAction $data.ProtectSite
        }

    }
    # Step 3: Check if LabelActions JSON parsing failed for any label (only Investigate when no container labels found)
    elseif ($parseError) {

        $customStatus = 'Investigate'
        $testResultMarkdown =
            "⚠️ Query fails or LabelActions JSON cannot be parsed due to permissions issues or service connection failure. Some labels could not be evaluated.`n`n%TestResult%"

    }
    # Step 4: Count = 0 - Fail
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
    $mdInfo += "| Metric | Value |`n|---|---|`n"
    $mdInfo += "| Total sensitivity labels | $(if ($allLabels) { $allLabels.Count } else { 0 }) |`n"
    $mdInfo += "| Container-protected labels | $($containerLabels.Count) |`n`n"

    if ($labelResults.Count -gt 0) {
        $tableRows = ""
        $formatTemplate = @'
## [Container label details](https://purview.microsoft.com/informationprotection/informationprotectionlabels/sensitivitylabels)

| Label name | Content type | Group privacy setting | Site external sharing | Site guest access |
|---|---|---|---|---|
{0}
'@
        foreach ($r in $labelResults) {
            $labelLink = "https://purview.microsoft.com/informationprotection/informationprotectionlabels/sensitivitylabels"
            $linkedLabelName = "[{0}]({1})" -f (Get-SafeMarkdown $r.LabelName), $labelLink

            $tableRows += "| $linkedLabelName | $($r.ContentType) | $($r.GroupPrivacySetting) | $($r.SiteExternalSharing) | $($r.SiteGuestAccess) |`n"
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
