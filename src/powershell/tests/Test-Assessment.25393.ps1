<#
.SYNOPSIS
    Validates that Quick Access is enabled and bound to a connector with active connectors.

.DESCRIPTION
    This test checks that the Private Access traffic forwarding profile is enabled, that
    a connector group has the Quick Access application assigned, and that at least one
    connector in that group has an active status.

.NOTES
    Test ID: 25393
    Category: Global Secure Access
    Required API: networkAccess/forwardingProfiles, onPremisesPublishingProfiles/applicationProxy (beta)
#>

function Test-Assessment-25393 {

    [ZtTest(
        Category = 'Global Secure Access',
        ImplementationCost = 'Medium',
        MinimumLicense = ('AAD_PREMIUM', 'Entra_Premium_Private_Access'),
        Pillar = 'Network',
        RiskLevel = 'High',
        SfiPillar = 'Protect networks',
        TenantType = ('Workforce'),
        TestId = 25393,
        Title = 'Quick Access is enabled and bound to a connector',
        UserImpact = 'Medium'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose
    $activity = 'Checking Quick Access connector binding status'

    # Q1: Retrieve the Private Access traffic forwarding profile
    Write-ZtProgress -Activity $activity -Status 'Checking Private Access forwarding profile'

    $privateProfile = $null
    try {
        $privateProfile = Invoke-ZtGraphRequest `
            -RelativeUri "networkAccess/forwardingProfiles?`$filter=trafficForwardingType eq 'private'" `
            -ApiVersion beta
    }
    catch {
        Write-PSFMessage "Unable to retrieve Private Access forwarding profile: $_" -Tag Test -Level Warning
    }

    $profileState = 'Not found'
    if ($privateProfile) {
        $profileData = @($privateProfile) | Select-Object -First 1
        $profileState = $profileData.state
    }

    # Q2: List all connector groups
    Write-ZtProgress -Activity $activity -Status 'Querying connector groups'

    $connectorGroups = @()
    try {
        $connectorGroups = @(Invoke-ZtGraphRequest `
            -RelativeUri 'onPremisesPublishingProfiles/applicationProxy/connectorGroups' `
            -ApiVersion beta)
    }
    catch {
        Write-PSFMessage "Unable to retrieve connector groups: $_" -Tag Test -Level Warning
    }

    if ($connectorGroups.Count -eq 0) {
        Write-PSFMessage 'No connector groups found.' -Tag Test -Level VeryVerbose
        Add-ZtTestResultDetail -SkippedBecause NotApplicable
        return
    }

    # Q3: Find the connector group that has the Quick Access application assigned
    Write-ZtProgress -Activity $activity -Status 'Checking Quick Access application assignment'

    $quickAccessGroupId = $null
    $quickAccessGroupName = $null

    foreach ($group in $connectorGroups) {
        $apps = @()
        try {
            $apps = @(Invoke-ZtGraphRequest `
                -RelativeUri "onPremisesPublishingProfiles/applicationProxy/connectorGroups/$($group.id)/applications" `
                -ApiVersion beta)
        }
        catch {
            Write-PSFMessage "Unable to list applications for connector group $($group.name): $_" -Tag Test -Level Warning
            continue
        }

        # Identify the Quick Access application by the NetworkAccessQuickAccessApplication tag
        foreach ($app in $apps) {
            if (@($app.tags) -contains 'NetworkAccessQuickAccessApplication') {
                $quickAccessGroupId = $group.id
                $quickAccessGroupName = $group.name
                break
            }
        }

        if ($quickAccessGroupId) { break }
    }

    # Q4: List connectors in the Quick Access connector group
    $connectors = @()
    $activeConnectorCount = 0

    if ($quickAccessGroupId) {
        Write-ZtProgress -Activity $activity -Status 'Checking connectors in Quick Access connector group'

        try {
            $connectors = @(Invoke-ZtGraphRequest `
                -RelativeUri "onPremisesPublishingProfiles/applicationProxy/connectorGroups/$quickAccessGroupId/members" `
                -ApiVersion beta)
        }
        catch {
            Write-PSFMessage "Unable to list connectors for group $quickAccessGroupName : $_" -Tag Test -Level Warning
        }

        $activeConnectorCount = @($connectors | Where-Object { $_.status -eq 'active' }).Count
    }

    #endregion Data Collection

    #region Assessment Logic

    # Pass: Profile enabled + Quick Access assigned to a group + at least one active connector
    $passed = ($profileState -eq 'enabled' -and $null -ne $quickAccessGroupId -and $activeConnectorCount -gt 0)

    if ($passed) {
        $testResultMarkdown = "✅ Quick Access is bound to a connector group with at least one active connector, and the Private Access traffic forwarding profile is enabled.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "❌ Quick Access is not bound to a connector group with active connectors, or the Private Access traffic forwarding profile is not enabled.`n`n%TestResult%"
    }

    #endregion Assessment Logic

    #region Report Generation

    $portalLink = 'https://entra.microsoft.com/#view/Microsoft_AAD_IAM/QuickAccessMenuBlade/~/GlobalSecureAccess'

    $mdInfo = "`n## [Quick Access Connector Binding Status]($portalLink)`n`n"
    $mdInfo += "| Property | Value |`n"
    $mdInfo += "| :--- | :--- |`n"
    $mdInfo += "| Private Access Profile State | $profileState |`n"
    $mdInfo += "| Connector Group Name | $(if ($quickAccessGroupName) { Get-SafeMarkdown -Text $quickAccessGroupName } else { 'N/A' }) |`n"
    $mdInfo += "| Connector Group ID | $(if ($quickAccessGroupId) { $quickAccessGroupId } else { 'N/A' }) |`n"
    $mdInfo += "| Quick Access App Assigned | $(if ($quickAccessGroupId) { 'Yes' } else { 'No' }) |`n`n"

    # Connector Status table (only if a Quick Access group was found)
    if ($quickAccessGroupId) {
        $mdInfo += "## Connector Status`n`n"
        $mdInfo += "| Connector Name | Status | External IP | Version |`n"
        $mdInfo += "| :--- | :--- | :--- | :--- |`n"

        if ($connectors.Count -gt 0) {
            foreach ($connector in $connectors) {
                $connectorName = Get-SafeMarkdown -Text $connector.machineName
                $statusText = if ($connector.status -eq 'active') { '✅ Active' } else { '❌ Inactive' }
                $externalIp = if ($connector.externalIp) { $connector.externalIp } else { 'N/A' }
                $version = if ($connector.version) { $connector.version } else { 'N/A' }

                $mdInfo += "| $connectorName | $statusText | $externalIp | $version |`n"
            }
        }
        else {
            $mdInfo += "| - | No connectors found | - | - |`n"
        }
        $mdInfo += "`n"
    }

    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo

    #endregion Report Generation

    $params = @{
        TestId = '25393'
        Title  = 'Quick Access is enabled and bound to a connector'
        Status = $passed
        Result = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
