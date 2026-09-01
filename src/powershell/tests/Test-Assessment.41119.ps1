<#
.SYNOPSIS
    Local modification of Microsoft Defender Antivirus policy is blocked.

.DESCRIPTION
    Checks whether an assigned Intune Settings Catalog policy sets the Defender
    DisableLocalAdminMerge control to Yes (..._1) so that only management-defined
    Defender Antivirus settings (such as exclusions) are used in the effective policy.

.NOTES
    Test ID: 41119
    Workshop Task ID: SECOPS-119
    Category: Endpoint threat protection
    Pillar: SecOps
    Required Module: Microsoft.Graph.Authentication
    Required Connection: Microsoft Graph
    Required Permission: DeviceManagementConfiguration.Read.All
#>

function Test-Assessment-41119 {
    [ZtTest(
        Category = 'Endpoint threat protection',
        CompatibleLicense = ('INTUNE_A'),
        ImplementationCost = 'Low',
        Pillar = 'SecOps',
        RiskLevel = 'High',
        Service = ('Graph'),
        SfiPillar = 'Monitor and detect cyberthreats',
        TenantType = ('Workforce'),
        TestId = 41119,
        Title = 'Local modification of Microsoft Defender Antivirus policy is blocked',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Helper Functions

    # Recursively collects every setting instance in a policy's settings tree, including
    # instances nested inside choiceSettingValue.children, choiceSettingCollectionValue,
    # groupSettingCollectionValue.children and groupSettingValue.children paths.
    function Get-AllSettingInstances {
        param([array]$SettingInstances)
        $result = [System.Collections.Generic.List[object]]::new()
        foreach ($si in $SettingInstances) {
            if ($null -eq $si) { continue }
            $result.Add($si)
            if ($si.choiceSettingValue -and $si.choiceSettingValue.children) {
                $result.AddRange([object[]](Get-AllSettingInstances -SettingInstances @($si.choiceSettingValue.children)))
            }
            if ($si.choiceSettingCollectionValue) {
                foreach ($csv in $si.choiceSettingCollectionValue) {
                    if ($csv.children) {
                        $result.AddRange([object[]](Get-AllSettingInstances -SettingInstances @($csv.children)))
                    }
                }
            }
            if ($si.groupSettingCollectionValue) {
                foreach ($gsv in $si.groupSettingCollectionValue) {
                    if ($gsv.children) {
                        $result.AddRange([object[]](Get-AllSettingInstances -SettingInstances @($gsv.children)))
                    }
                }
            }
            if ($si.groupSettingValue -and $si.groupSettingValue.children) {
                $result.AddRange([object[]](Get-AllSettingInstances -SettingInstances @($si.groupSettingValue.children)))
            }
        }
        return $result
    }

    #endregion Helper Functions

    #region Data Collection

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking Defender local admin merge configuration'
    $title = 'Local modification of Microsoft Defender Antivirus policy is blocked'
    $controlId = 'device_vendor_msft_defender_configuration_disablelocaladminmerge'

    # Maps assignment target @odata.type to a friendly type label shown in the report.
    # Only the target type is displayed (no group name/id), so the check stays within
    # DeviceManagementConfiguration.Read.All (name resolution would need Group.Read.All).
    $assignmentTargetMap = @{
        '#microsoft.graph.allDevicesAssignmentTarget'                     = 'allDevices'
        '#microsoft.graph.allLicensedUsersAssignmentTarget'               = 'allLicensedUsers'
        '#microsoft.graph.groupAssignmentTarget'                          = 'groupAssignment'
        '#microsoft.graph.exclusionGroupAssignmentTarget'                 = 'exclusionGroupAssignment'
        '#microsoft.graph.configurationManagerCollectionAssignmentTarget' = 'configurationManagerCollection'
    }

    # Q1: List Settings Catalog configuration policies (beta), following @odata.nextLink automatically.
    # $expand=assignments brings the assignment state inline (isAssigned is not returned by default).
    $rootError = $null
    $settingsCatalogPolicies = @()
    try {
        Write-ZtProgress -Activity $activity -Status 'Getting Settings Catalog policies'
        $settingsCatalogPolicies = @(Invoke-ZtGraphRequest -RelativeUri 'deviceManagement/configurationPolicies?$expand=assignments' -ApiVersion beta -ErrorAction Stop)
        $settingsCatalogPolicies = @($settingsCatalogPolicies | Where-Object { $_.technologies -match '(?i)\bmdm\b' })
        Write-PSFMessage "Found $($settingsCatalogPolicies.Count) Settings Catalog policies" -Level Verbose
    }
    catch {
        $rootError = $_
        Write-PSFMessage "Failed to query Settings Catalog policies: $_" -Tag Test -Level Warning
    }

    # A failure of the root list query (or any of its pages) is unrecoverable: return Investigate.
    if ($rootError) {
        $httpStatus = Get-ZtHttpStatusCode -ErrorRecord $rootError
        Write-PSFMessage "Failed to query Settings Catalog policies (HTTP $httpStatus): $rootError" -Tag Test -Level Warning
        $msg = if ($httpStatus -in @(401, 403)) {
            '⚠️ **DeviceManagementConfiguration.Read.All** permission is required to read Intune configuration policies. Verify the permission is consented and the assessment identity has an Intune read role, then re-run the assessment.'
        } elseif ($httpStatus -eq 404) {
            '⚠️ The Intune configuration policies endpoint returned 404. Verify that Intune is provisioned in this tenant, then re-run the assessment.'
        } else {
            '⚠️ Microsoft Graph returned an unexpected error while querying Intune Settings Catalog configuration policies. Re-run after 5–10 minutes; file a support ticket if this persists.'
        }
        $params = @{
            TestId       = '41119'
            Title        = $title
            Status       = $false
            Result       = $msg
            CustomStatus = 'Investigate'
        }
        Add-ZtTestResultDetail @params
        return
    }

    $evaluationResults = @()
    foreach ($policy in $settingsCatalogPolicies) {
        $templateFamily = [string]$policy.templateReference.templateFamily
        if ([string]::IsNullOrWhiteSpace($templateFamily)) { $templateFamily = 'none' }

        # PolicySummaryBlade deep link requires technology, templateId and platformName segments.
        $technologies = [string]$policy.technologies
        $templateId = [string]$policy.templateReference.templateId
        $platforms = [string]$policy.platforms

        # Assignment comes from the $expand=assignments projection on the list query.
        # Classify as Assigned / Unassigned / Unknown so conflicting or absent signals surface as
        # Investigate rather than a false Pass/Fail (isAssigned is not returned by default).
        $assignmentsPresent = $null -ne $policy.PSObject.Properties['assignments']
        $assignmentCount = @($policy.assignments | Where-Object { $null -ne $_ }).Count
        $isAssigned = $null
        if ($null -ne $policy.isAssigned) { $isAssigned = [bool]$policy.isAssigned }
        if (-not $assignmentsPresent) {
            $assignmentState = 'Unknown'
        }
        elseif ($null -ne $isAssigned -and $isAssigned -ne ($assignmentCount -ge 1)) {
            # isAssigned flag conflicts with the inline assignments array.
            $assignmentState = 'Unknown'
        }
        elseif ($assignmentCount -ge 1) {
            $assignmentState = 'Assigned'
        }
        else {
            $assignmentState = 'Unassigned'
        }
        $assignedText = switch ($assignmentState) { 'Assigned' { 'Yes' } 'Unassigned' { 'No' } default { 'Unknown' } }
        # Show target type only; no groupId->name lookup (no Group.Read.All) and no ids in output.
        $assignmentTargets = @($policy.assignments | Where-Object { $null -ne $_ } | ForEach-Object {
            $targetType = [string]$_.target.'@odata.type'
            if ($assignmentTargetMap.ContainsKey($targetType)) { $assignmentTargetMap[$targetType] }
            elseif (-not [string]::IsNullOrWhiteSpace($targetType)) { ($targetType -replace '^#microsoft\.graph\.', '') -replace 'AssignmentTarget$', '' }
            else { 'unknown' }
        })
        $assignmentTargetsText = if ($assignmentTargets.Count -gt 0) { ($assignmentTargets | Select-Object -Unique) -join ', ' } else { 'None' }

        # Read the policy settings (beta, auto-paged). An unreadable settings surface classifies
        # this policy as Investigate but does not stop evaluation of the remaining policies.
        try {
            Write-ZtProgress -Activity $activity -Status "Reading Settings Catalog policy $($policy.name)"
            $settings = @(Invoke-ZtGraphRequest -RelativeUri "deviceManagement/configurationPolicies/$($policy.id)/settings" -ApiVersion beta -ErrorAction Stop)
        }
        catch {
            $statusCode = Get-ZtHttpStatusCode -ErrorRecord $_
            $statusText = if ($null -ne $statusCode) { "HTTP $statusCode" } else { 'a network or timeout error' }
            Write-PSFMessage "Failed to read settings for policy '$($policy.name)': $_" -Tag Test -Level Warning
            $evaluationResults += [PSCustomObject]@{
                PolicyName          = $policy.name
                PolicyId            = $policy.id
                TemplateFamily      = $templateFamily
                Technologies        = $technologies
                TemplateId          = $templateId
                Platforms           = $platforms
                Assigned            = $assignedText
                AssignmentTargets   = $assignmentTargetsText
                SettingDefinitionId = 'N/A'
                RawSettingValue     = 'N/A'
                NormalizedState     = 'Unknown'
                Details             = "The policy settings could not be read ($statusText)."
                Status              = 'Investigate'
            }
            continue
        }

        # Identify the control by exact, case-insensitive settingDefinitionId equality.
        # Evaluate every matching instance (Graph can nest duplicates) and roll up within the policy.
        $allInstances = @(Get-AllSettingInstances -SettingInstances @($settings.settingInstance))
        $matchingInstances = @($allInstances | Where-Object {
            [string]$_.settingDefinitionId -ieq $controlId
        })

        if ($matchingInstances.Count -eq 0) {
            # A policy without the control instance is N/A and is excluded from the roll-up.
            $evaluationResults += [PSCustomObject]@{
                PolicyName          = $policy.name
                PolicyId            = $policy.id
                TemplateFamily      = $templateFamily
                Technologies        = $technologies
                TemplateId          = $templateId
                Platforms           = $platforms
                Assigned            = $assignedText
                AssignmentTargets   = $assignmentTargetsText
                SettingDefinitionId = 'N/A'
                RawSettingValue     = 'N/A'
                NormalizedState     = 'N/A'
                Details             = 'The policy does not contain a disable local admin merge setting.'
                Status              = 'N/A'
            }
            continue
        }

        # Classify each matching instance, then roll up within the policy: Fail > Investigate > Pass.
        $rawValues = [System.Collections.Generic.List[string]]::new()
        $normalizedStates = [System.Collections.Generic.List[string]]::new()
        $instanceStatuses = [System.Collections.Generic.List[string]]::new()
        foreach ($mi in $matchingInstances) {
            $v = [string]$mi.choiceSettingValue.value
            $rawValues.Add($(if ([string]::IsNullOrWhiteSpace($v)) { 'N/A' } else { $v }))
            $ns = if ($v -match '(?i)_disablelocaladminmerge_1$') { 'Enabled' }
                elseif ($v -match '(?i)_disablelocaladminmerge_0$') { 'Disabled' }
                else { 'Unknown' }
            $normalizedStates.Add($ns)
            if ($ns -eq 'Unknown') { $instanceStatuses.Add('Investigate') }
            elseif ($ns -eq 'Disabled') { $instanceStatuses.Add('Fail') }
            elseif ($assignmentState -eq 'Unknown') { $instanceStatuses.Add('Investigate') }
            elseif ($assignmentState -eq 'Assigned') { $instanceStatuses.Add('Pass') }
            else { $instanceStatuses.Add('Fail') }
        }

        $rawValue = (@($rawValues) | Select-Object -Unique) -join ', '
        $normalizedState = (@($normalizedStates) | Select-Object -Unique) -join ', '
        $status = if ($instanceStatuses -contains 'Fail') { 'Fail' }
            elseif ($instanceStatuses -contains 'Investigate') { 'Investigate' }
            else { 'Pass' }

        $details = switch ($status) {
            'Pass' { 'Disable local admin merge is set to yes on an assigned policy.' }
            'Investigate' {
                if ($normalizedStates -contains 'Unknown') { 'A disable local admin merge value could not be interpreted.' }
                else { 'The policy assignment state could not be determined from the returned data.' }
            }
            default {
                if ($normalizedStates -contains 'Disabled') { 'Disable local admin merge is set to no.' }
                else { 'Disable local admin merge is set to yes but the policy is not assigned.' }
            }
        }

        $evaluationResults += [PSCustomObject]@{
            PolicyName          = $policy.name
            PolicyId            = $policy.id
            TemplateFamily      = $templateFamily
            Technologies        = $technologies
            TemplateId          = $templateId
            Platforms           = $platforms
            Assigned            = $assignedText
            AssignmentTargets   = $assignmentTargetsText
            SettingDefinitionId = $matchingInstances[0].settingDefinitionId
            RawSettingValue     = $rawValue
            NormalizedState     = $normalizedState
            Details             = $details
            Status              = $status
        }
    }

    #endregion Data Collection

    #region Assessment Logic

    # Only policies that actually carry the control are evaluable; N/A policies are excluded from the roll-up and from display.
    $evaluableResults = @($evaluationResults | Where-Object { $_.Status -ne 'N/A' })
    $passed = $false
    $customStatus = $null

    if ($evaluableResults.Count -eq 0) {
        # No matching control instance remained after N/A exclusions (includes legacy-only enforcement).
        $customStatus = 'Investigate'
        $testResultMarkdown = "⚠️ The **DisableLocalAdminMerge** state could not be determined on the evaluated Intune surface — no matching control was found (including legacy-only enforcement) or the evaluable set was empty. Verify **DeviceManagementConfiguration.Read.All**, Intune RBAC, and the policy in the Intune portal.`n`n%TestResult%"
    }
    else {
        # Roll-up precedence: Fail > Investigate > Pass.
        $failResults = @($evaluableResults | Where-Object { $_.Status -eq 'Fail' })
        $investigateResults = @($evaluableResults | Where-Object { $_.Status -eq 'Investigate' })

        if ($failResults.Count -gt 0) {
            $testResultMarkdown = "❌ A retrieved Intune policy sets **DisableLocalAdminMerge** to No (**..._0**), or enables it only in an unassigned policy.`n`n%TestResult%"
        }
        elseif ($investigateResults.Count -gt 0) {
            $customStatus = 'Investigate'
            $testResultMarkdown = "⚠️ The **DisableLocalAdminMerge** state could not be determined on the evaluated Intune surface — a value or assignment state was uninterpretable, or Microsoft Graph could not be read. Verify **DeviceManagementConfiguration.Read.All**, Intune RBAC, and the policy in the Intune portal.`n`n%TestResult%"
        }
        else {
            $passed = $true
            $testResultMarkdown = "✅ Local modification of Microsoft Defender Antivirus policy is blocked — an assigned Intune Settings Catalog policy sets **DisableLocalAdminMerge** to Yes.`n`n%TestResult%"
        }
    }

    #endregion Assessment Logic

    #region Report Generation

    $portalUrl = 'https://intune.microsoft.com/#view/Microsoft_Intune_DeviceSettings/DevicesMenu/~/configuration'

    # Show every evaluated policy so the report is complete, even when policies are N/A for this control.
    $statusIcon = @{
        'Pass'        = '✅ Pass'
        'Fail'        = '❌ Fail'
        'Investigate' = '⚠️ Investigate'
        'N/A'         = 'N/A'
    }
    $totalCount = $evaluationResults.Count
    $isTruncated = $totalCount -gt 10
    $tableRows = @($evaluationResults | Select-Object -First 10 | ForEach-Object {
        $policyName = (Get-SafeMarkdown -Text $_.PolicyName) -replace '\|', '\\|'
        $encodedTechnologies = ([string]$_.Technologies) -replace ',', '%2C'
        $policyLink = "https://intune.microsoft.com/#view/Microsoft_Intune_Workflows/PolicySummaryBlade/policyId/$($_.PolicyId)/technology/$encodedTechnologies/templateId/$($_.TemplateId)/platformName/$($_.Platforms)"
        $assignmentTargets = (Get-SafeMarkdown -Text $_.AssignmentTargets) -replace '\|', '\\|'
        $settingDefId = (Get-SafeMarkdown -Text $_.SettingDefinitionId) -replace '\|', '\\|'
        $rawValue = (Get-SafeMarkdown -Text $_.RawSettingValue) -replace '\|', '\\|'
        $detailsText = (Get-SafeMarkdown -Text $_.Details) -replace '\|', '\\|'
        $displayStatus = $statusIcon[$_.Status]
        if (-not $displayStatus) { $displayStatus = $_.Status }
        "| [$policyName]($policyLink) | $($_.TemplateFamily) | $($_.Assigned) | $assignmentTargets | $settingDefId | $rawValue | $($_.NormalizedState) | $detailsText | $displayStatus |"
    })

    if ($isTruncated) {
        $tableRows += "| ... $($totalCount - 10) omitted; $totalCount total ... | ... | ... | ... | ... | ... | ... | ... | ... |"
    }

    if ($tableRows.Count -gt 0) {
        $countLine = if ($isTruncated) {
            "Showing first 10 of $totalCount policies`n`n"
        } else {
            "Total policies: $totalCount`n`n"
        }
        $mdInfo = @"

## [Intune configuration profiles]($portalUrl)

$countLine| Policy name | Template family | Assigned | Assignment targets | Setting definition ID | Raw setting value | Normalized state | Details | Status |
| :---------- | :-------------- | :------- | :----------------- | :-------------------- | :---------------- | :--------------- | :------ | :----- |
$($tableRows -join "`n")
"@
        $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    }

    # Safety net: strip any unresolved placeholder so it never surfaces in the report.
    $testResultMarkdown = $testResultMarkdown -replace '\s*%TestResult%', ''

    $params = @{
        TestId = '41119'
        Title  = $title
        Status = $passed
        Result = $testResultMarkdown
    }
    if ($null -ne $customStatus) {
        $params.CustomStatus = $customStatus
    }
    Add-ZtTestResultDetail @params

    #endregion Report Generation
}
