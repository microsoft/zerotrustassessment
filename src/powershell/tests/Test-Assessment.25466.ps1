<#
.SYNOPSIS
    Validates that at least two Private Access Connectors are active and healthy per connector group.

.DESCRIPTION
    This test checks if each connector group has at least two active connectors to ensure
    redundant access paths and resilience against connector failure. Each connector group
    acts as the sole access path for private applications assigned to it. A single connector
    failure eliminates all Private Access routing through that group until manually restored.

.NOTES
    Test ID: 25466
    Category: Private Access
    Required API: onPremisesPublishingProfiles/applicationProxy/connectorGroups (beta), connectorGroups/{id}/members (beta)
#>

function Test-Assessment-25466 {
    [ZtTest(
        Category = 'Private Access',
        ImplementationCost = 'Low',
        MinimumLicense = ('Entra_Premium_Private_Access'),
        Pillar = 'Network',
        RiskLevel = 'High',
        SfiPillar = 'Protect networks',
        TenantType = ('Workforce'),
        TestId = 25466,
        Title = 'At least two Private Access Connectors are active and healthy per region',
        UserImpact = 'Medium'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking Private Access Connector redundancy per connector group'
    Write-ZtProgress -Activity $activity -Status 'Querying connector groups'

    # Query 1: Get all connector groups
    $connectorGroups = @()
    $query1Failed = $false
    try {
        $connectorGroups = Invoke-ZtGraphRequest `
            -RelativeUri 'onPremisesPublishingProfiles/applicationProxy/connectorGroups' `
            -ApiVersion beta
    }
    catch {
        $query1Failed = $true
        Write-PSFMessage "Failed to retrieve connector groups: $_" -Tag Test -Level Warning
    }

    # Query 2: For each connector group, get its member connectors
    $groupsWithConnectors = [System.Collections.Generic.List[object]]::new()
    $failedGroups = [System.Collections.Generic.List[object]]::new()
    $query2FailedGroups = [System.Collections.Generic.List[object]]::new()

    if ($connectorGroups -and $connectorGroups.Count -gt 0) {
        Write-ZtProgress -Activity $activity -Status 'Analyzing connector membership per group'

        # Filter for applicationProxy type groups only (API returns mixed types despite being scoped to applicationProxy profile)
        $applicationProxyGroups = @($connectorGroups | Where-Object { $_.connectorGroupType -eq 'applicationProxy' })

        if ($applicationProxyGroups.Count -eq 0 -and -not $query1Failed) {
            # No applicationProxy groups found - Private Access not configured
            # Note: If Query 1 failed, don't return NotApplicable - let it fall through to assessment logic for Investigate status
            Add-ZtTestResultDetail -TestId '25466' -Title 'At least two Private Access Connectors are active and healthy per region' -SkippedBecause NotApplicable -Result 'No Private Access connector groups are configured in the tenant. This check applies only when Microsoft Entra Private Access or Application Proxy is deployed.'
            return
        }

        foreach ($group in $applicationProxyGroups) {
            try {
                $members = Invoke-ZtGraphRequest `
                    -RelativeUri "onPremisesPublishingProfiles/applicationProxy/connectorGroups/$($group.id)/members" `
                    -ApiVersion beta

                # Normalize to array to ensure .Count works correctly with single objects
                $members = @($members)

                # Count active connectors
                $activeConnectors = @($members | Where-Object { $_.status -eq 'active' })
                $activeCount = $activeConnectors.Count
                $totalCount = $members.Count

                $regionDisplayRaw = if ($group.region) { $group.region } else { 'Default' }
                $regionDisplay = Get-SafeMarkdown -Text $regionDisplayRaw
                $groupStatus = if ($activeCount -ge 2) { 'Pass' } else { 'Fail' }

                $groupInfo = [PSCustomObject]@{
                    Name        = $group.name
                    Region      = $regionDisplay
                    ActiveCount = $activeCount
                    TotalCount  = $totalCount
                    Status      = $groupStatus
                    Members     = $members
                }

                $groupsWithConnectors.Add($groupInfo)

                if ($groupStatus -eq 'Fail') {
                    $failedGroups.Add($groupInfo)
                }
            }
            catch {
                Write-PSFMessage "Failed to retrieve connectors for group $($group.id): $_" -Tag Test -Level Warning
                $query2FailedGroups.Add($group)
            }
        }
    }
    elseif (-not $query1Failed) {
        # No connector groups found at all - Private Access / Application Proxy not configured
        # Note: If Query 1 failed, don't return NotApplicable - let it fall through to assessment logic for Investigate status
        Add-ZtTestResultDetail -TestId '25466' -Title 'At least two Private Access Connectors are active and healthy per region' -SkippedBecause NotApplicable -Result 'No Private Access connector groups are configured in the tenant. This check applies only when Microsoft Entra Private Access or Application Proxy is deployed.'
        return
    }
    #endregion Data Collection

    #region Assessment Logic
    $testResultMarkdown = ''
    $passed = $false
    $customStatus = $null

    if ($query1Failed -or $query2FailedGroups.Count -gt 0) {
        # Query failures - unable to complete assessment
        $passed = $false
        $customStatus = 'Investigate'
        $testResultMarkdown = "⚠️ Unable to determine connector redundancy due to query failure, connection issues, or insufficient permissions.`n`n%TestResult%"
    }
    elseif ($failedGroups.Count -eq 0) {
        # All groups pass
        $passed = $true
        $testResultMarkdown = "✅ All Private Access connector groups have at least two active and healthy connectors, ensuring redundant access paths per deployment region.`n`n%TestResult%"
    }
    else {
        # At least one group fails
        $passed = $false
        $testResultMarkdown = "❌ One or more Private Access connector groups have fewer than two active connectors, exposing private application access to a single point of failure.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    $mdInfo = ''

    # Show groups where Query 2 failed
    if ($query2FailedGroups.Count -gt 0) {
        $mdInfo += "`n**⚠️ Failed to query connectors for the following group(s):**`n`n"
        foreach ($failedGroup in $query2FailedGroups) {
            $groupName = Get-SafeMarkdown -Text $failedGroup.name
            $regionDisplayRaw = if ($failedGroup.region) { $failedGroup.region } else { 'Default' }
            $regionDisplay = Get-SafeMarkdown -Text $regionDisplayRaw
            $mdInfo += "- $groupName (Region: $regionDisplay)`n"
        }
        $mdInfo += "`n"
    }

    if ($groupsWithConnectors.Count -gt 0) {
        $reportTitle = 'Private Access Connector Groups'
        $portalLink = 'https://entra.microsoft.com/#view/Microsoft_Entra_GSA_Connect/Connectors.ReactView'

        # Build connector groups summary table
        $formatTemplate = @'

#### [{0}]({1})

| Connector group name | Region | Active connectors | Total connectors | Status |
| :------------------- | :----- | ----------------: | ---------------: | :----- |
{2}
'@

        $tableRows = ""
        $maxGroupsToShow = 10
        $groupsToDisplay = $groupsWithConnectors | Sort-Object Name | Select-Object -First $maxGroupsToShow

        foreach ($group in $groupsToDisplay) {
            $groupName = Get-SafeMarkdown -Text $group.Name
            $region = $group.Region
            $statusIcon = if ($group.Status -eq 'Pass') { '✅ Pass' } else { '❌ Fail' }
            $tableRows += "| $groupName | $region | $($group.ActiveCount) | $($group.TotalCount) | $statusIcon |`n"
        }

        $mdInfo += $formatTemplate -f $reportTitle, $portalLink, $tableRows

        # Add note if groups were truncated
        if ($groupsWithConnectors.Count -gt $maxGroupsToShow) {
            $remainingGroups = $groupsWithConnectors.Count - $maxGroupsToShow
            $mdInfo += "`n_Showing first $maxGroupsToShow of $($groupsWithConnectors.Count) connector groups. $remainingGroups additional group(s) not shown._`n"
        }

        # Add detailed tables for failing groups
        if ($failedGroups.Count -gt 0) {
            $mdInfo += "`n`n#### Connector Details for Failing Groups`n`n"

            $maxFailingGroupsToShow = 10
            $maxConnectorsPerGroup = 10
            $failingGroupsToDisplay = $failedGroups | Sort-Object Name | Select-Object -First $maxFailingGroupsToShow

            foreach ($failedGroup in $failingGroupsToDisplay) {
                $groupName = Get-SafeMarkdown -Text $failedGroup.Name
                $failedRegion = $failedGroup.Region
                $mdInfo += "**Connector Group: $groupName** (Region: $failedRegion)`n`n"

                if ($failedGroup.Members -and $failedGroup.Members.Count -gt 0) {
                    $mdInfo += "| Group Name | Machine Name | External IP | Connector Status | Version |`n"
                    $mdInfo += "| :--------- | :----------- | :---------- | :--------------- | :------ |`n"

                    $connectorsToDisplay = $failedGroup.Members | Sort-Object machineName | Select-Object -First $maxConnectorsPerGroup

                    foreach ($member in $connectorsToDisplay) {
                        $machineName = Get-SafeMarkdown -Text $member.machineName
                        $externalIpRaw = if ($member.externalIp) { $member.externalIp } else { 'N/A' }
                        $externalIp = Get-SafeMarkdown -Text $externalIpRaw
                        $statusRaw = if ($member.status -eq 'active') { '✅ Active' } else { '❌ Inactive' }
                        $status = Get-SafeMarkdown -Text $statusRaw
                        $versionRaw = if ($member.version) { $member.version } else { 'N/A' }
                        $version = Get-SafeMarkdown -Text $versionRaw
                        $mdInfo += "| $groupName | $machineName | $externalIp | $status | $version |`n"
                    }

                    # Add note if connectors were truncated for this group
                    if ($failedGroup.Members.Count -gt $maxConnectorsPerGroup) {
                        $remainingConnectors = $failedGroup.Members.Count - $maxConnectorsPerGroup
                        $mdInfo += "`n_Showing first $maxConnectorsPerGroup of $($failedGroup.Members.Count) connectors. $remainingConnectors additional connector(s) not shown._`n"
                    }

                    $mdInfo += "`n"
                }
                else {
                    $mdInfo += "_No connectors found in this group._`n`n"
                }
            }

            # Add note if failing groups were truncated
            if ($failedGroups.Count -gt $maxFailingGroupsToShow) {
                $remainingFailedGroups = $failedGroups.Count - $maxFailingGroupsToShow
                $mdInfo += "`n_Showing first $maxFailingGroupsToShow of $($failedGroups.Count) failing connector groups. $remainingFailedGroups additional failing group(s) not shown._`n"
            }
        }
    }

    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '25466'
        Title  = 'At least two Private Access Connectors are active and healthy per region'
        Status = $passed
        Result = $testResultMarkdown
    }
    if ($customStatus) {
        $params.CustomStatus = $customStatus
    }
    Add-ZtTestResultDetail @params
}
