<#
.SYNOPSIS
    Removable storage and device control policies are enforced via Intune.

.DESCRIPTION
    Checks whether an Intune configuration policy contains device control or removable
    storage settings and is assigned to at least one inclusive target.

.NOTES
    Test ID: 41051
    Workshop Task ID: SECOPS-051
    Category: Endpoint threat protection
    Pillar: SecOps
    Required Permission: DeviceManagementConfiguration.Read.All
#>

function Test-Assessment-41051 {
    [ZtTest(
        Category = 'Endpoint threat protection',
        CompatibleLicense = ('INTUNE_A&WINDEFATP'),
        ImplementationCost = 'Medium',
        Pillar = 'SecOps',
        RiskLevel = 'Medium',
        Service = ('Graph'),
        SfiPillar = 'Monitor and detect cyberthreats',
        TenantType = ('Workforce'),
        TestId = 41051,
        Title = 'Removable storage and device control policies are enforced via Intune',
        UserImpact = 'Medium'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking Intune device control and removable storage policies'
    $queryError = $null
    $policySnapshots = @()

    # Q1: Enumerate every beta Settings Catalog policy with assignments; the Graph helper follows @odata.nextLink.
    Write-ZtProgress -Activity $activity -Status 'Getting Intune configuration policies'
    try {
        $policies = @(Invoke-ZtGraphRequest -RelativeUri 'deviceManagement/configurationPolicies?$expand=assignments' -ApiVersion beta -ErrorAction Stop)
    }
    catch {
        $queryError = $_
        Write-PSFMessage "Failed to retrieve Intune configuration policies: $_" -Tag Test -Level Warning
    }

    if (-not $queryError) {
        foreach ($policy in $policies) {
            $snapshot = [PSCustomObject]@{
                Policy = $policy
                Settings = @()
                Assignments = @($policy.assignments)
                MatchingSettingCount = 0
                CollectionError = $null
            }
            try {
                # Retrieve the policy's settings; a matching setting may be nested as a child of a group setting.
                Write-ZtProgress -Activity $activity -Status "Getting settings for policy $($policy.name)"
                $snapshot.Settings = @(Invoke-ZtGraphRequest -RelativeUri "deviceManagement/configurationPolicies('$($policy.id)')/settings" -ApiVersion beta -ErrorAction Stop)
            }
            catch {
                $snapshot.CollectionError = $_
                Write-PSFMessage "Failed to retrieve settings for Intune policy '$($policy.name)': $_" -Tag Test -Level Warning
                $policySnapshots += $snapshot
                continue
            }

            # Settings Catalog group and choice values can nest arbitrarily; queue every child instance before matching roots.
            $settingInstances = [System.Collections.Generic.List[object]]::new()
            $pendingInstances = [System.Collections.Queue]::new()
            foreach ($setting in @($snapshot.Settings)) {
                if ($null -ne $setting.settingInstance) {
                    $pendingInstances.Enqueue($setting.settingInstance)
                }
            }

            while ($pendingInstances.Count -gt 0) {
                $instance = $pendingInstances.Dequeue()
                if ($null -eq $instance) { continue }
                [void]$settingInstances.Add($instance)

                $nestedInstances = @($instance.choiceSettingValue.children) + @($instance.groupSettingValue.children)
                foreach ($collectionValue in @($instance.groupSettingCollectionValue) + @($instance.simpleSettingCollectionValue) + @($instance.choiceSettingCollectionValue)) {
                    if ($null -ne $collectionValue) {
                        $nestedInstances += @($collectionValue.children)
                    }
                }

                foreach ($child in $nestedInstances) {
                    if ($null -ne $child) {
                        $pendingInstances.Enqueue($child)
                    }
                }
            }

            $matchingRoots = @(
                'device_vendor_msft_defender_configuration_devicecontrol',
                'device_vendor_msft_policy_config_admx_removablestorage_',
                'device_vendor_msft_policy_config_storage_removable'
            )
            $snapshot.MatchingSettingCount = @($settingInstances | Where-Object {
                $settingDefinitionId = [string]$_.settingDefinitionId
                $matchingRoots | Where-Object { $settingDefinitionId.StartsWith($_, [System.StringComparison]::OrdinalIgnoreCase) }
            }).Count

            $policySnapshots += $snapshot
        }
    }

    #endregion Data Collection

    #region Assessment Logic

    $passed = $false
    $customStatus = $null
    $policyResults = @()

    if ($queryError) {
        $customStatus = 'Investigate'
        $statusCode = Get-ZtHttpStatusCode -ErrorRecord $queryError
        if ($statusCode -in 401, 403, 404) {
            $testResultMarkdown = "⚠️ Microsoft Graph returned HTTP $statusCode while retrieving Intune configuration policies. Verify Intune licensing, RBAC, and DeviceManagementConfiguration.Read.All consent.`n`n%TestResult%"
        }
        else {
            $testResultMarkdown = "⚠️ Intune configuration policies could not be retrieved due to a Microsoft Graph error. Re-run the assessment after verifying Intune licensing, DeviceManagementConfiguration.Read.All consent, and Microsoft Graph access.`n`n%TestResult%"
        }
    }
    else {
        foreach ($snapshot in $policySnapshots) {
            if ($snapshot.MatchingSettingCount -eq 0 -and $null -eq $snapshot.CollectionError) {
                continue
            }

            $inclusiveAssignments = @($snapshot.Assignments | Where-Object {
                $target = $_.target
                if ($null -eq $target) { return $false }

                $targetType = [string]$target.'@odata.type'
                $targetType -in @(
                    '#microsoft.graph.groupAssignmentTarget',
                    '#microsoft.graph.allDevicesAssignmentTarget',
                    '#microsoft.graph.allLicensedUsersAssignmentTarget'
                )
            })

            $policyResults += [PSCustomObject]@{
                Name = $snapshot.Policy.name
                PolicyId = $snapshot.Policy.id
                TemplateFamily = $snapshot.Policy.templateReference.templateFamily
                MatchingSettingCount = $snapshot.MatchingSettingCount
                AssignmentCount = $inclusiveAssignments.Count
                LastModified = $snapshot.Policy.lastModifiedDateTime
                Status = if ($null -ne $snapshot.CollectionError) { 'Investigate' } elseif ($inclusiveAssignments.Count -gt 0) { 'Pass' } else { 'Fail' }
            }
        }

        # A confirmed Pass takes precedence over an unrelated policy's settings-read failure.
        if (@($policyResults | Where-Object Status -eq 'Pass').Count -gt 0) {
            $passed = $true
            $testResultMarkdown = "✅ Device control / removable storage access policy is configured and assigned in Microsoft Intune.`n`n%TestResult%"
        }
        elseif ($policyResults.Count -eq 0 -or @($policyResults | Where-Object Status -eq 'Investigate').Count -gt 0) {
            $customStatus = 'Investigate'
            $testResultMarkdown = "⚠️ No device control / removable storage policy could be found to evaluate, or the Intune configuration scope could not be read.`n`n%TestResult%"
        }
        else {
            $testResultMarkdown = "❌ A device control / removable storage policy exists but is not assigned to an inclusive target.`n`n%TestResult%"
        }
    }

    #endregion Assessment Logic

    #region Report Generation

    $portalUrl = 'https://intune.microsoft.com/#view/Microsoft_Intune_Workflows/SecurityManagementMenu/~/asr'
    if ($policyResults.Count -gt 0) {
        $displayResults = @($policyResults | Select-Object -First 10)
        $tableRows = @($displayResults | ForEach-Object {
            $policyName = (Get-SafeMarkdown -Text $_.Name) -replace '\|', '\\|'
            $lastModified = if ($_.LastModified) { Get-FormattedDate -DateString $_.LastModified } else { '—' }
            $statusDisplay = switch ($_.Status) {
                'Pass' { '✅ Pass' }
                'Investigate' { '⚠️ Investigate' }
                default { '❌ Fail' }
            }
            "| $policyName | $($_.TemplateFamily) | $($_.MatchingSettingCount) | $($_.AssignmentCount) | $lastModified | $statusDisplay |"
        })

        if ($policyResults.Count -gt 10) {
            $tableRows += "| ... | ... | ... | ... | ... | $($policyResults.Count) total policies |"
        }

        $reportTemplate = @'

## [Intune device control and removable storage policies]({0})

| Policy name | Template family | Matching setting count | Assignment count (inclusive targets) | Last modified | Status |
| :---------- | :--------------- | ---------------------: | -----------------------------------: | :------------ | :----- |
{1}
'@
        $mdInfo = $reportTemplate -f $portalUrl, ($tableRows -join "`n")
    }
    else {
        $mdInfo = ''
    }

    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    $params = @{
        TestId = '41051'
        Title  = 'Removable storage and device control policies are enforced via Intune'
        Status = $passed
        Result = $testResultMarkdown
    }
    if ($customStatus) {
        $params.CustomStatus = $customStatus
    }
    Add-ZtTestResultDetail @params

    #endregion Report Generation
}
