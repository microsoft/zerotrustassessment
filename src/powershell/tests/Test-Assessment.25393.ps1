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
    $forwardingProfiles = $null
    try {
        $forwardingProfiles = Invoke-ZtGraphRequest -RelativeUri 'networkAccess/forwardingProfiles' -ApiVersion beta
    }
    catch {
        Write-PSFMessage "Unable to retrieve Private Access forwarding profile: $($_.Exception.Message)" -Tag Test -Level Warning
    }
    $privateProfile = $forwardingProfiles | Where-Object { $_.trafficForwardingType -eq 'private' } | Select-Object -First 1
    $profileState = if ($privateProfile) { $privateProfile.state } else { 'Not found' }

    # Q2: List all connector groups
    Write-ZtProgress -Activity $activity -Status 'Querying connector groups'
    $connectorGroups = @()
    try {
        $connectorGroups = @(Invoke-ZtGraphRequest -RelativeUri 'onPremisesPublishingProfiles/applicationProxy/connectorGroups' -ApiVersion beta)
    }
    catch {
        Write-PSFMessage "Unable to retrieve connector groups: $($_.Exception.Message)" -Tag Test -Level Warning
    }

    # Q3: Find the connector group that has the Quick Access application assigned
    Write-ZtProgress -Activity $activity -Status 'Checking Quick Access application assignment'
    $quickAccessGroup = $null
    foreach ($group in $connectorGroups) {
        $apps = @()
        try {
            $apps = @(Invoke-ZtGraphRequest -RelativeUri "onPremisesPublishingProfiles/applicationProxy/connectorGroups/$($group.id)/applications" -ApiVersion beta)
        }
        catch {
            Write-PSFMessage "Unable to list applications for connector group $($group.name): $($_.Exception.Message)" -Tag Test -Level Warning
            continue
        }
        if ($apps | Where-Object { @($_.tags) -contains 'NetworkAccessQuickAccessApplication' }) {
            $quickAccessGroup = $group
            break
        }
    }

    # Q4: List connectors in the Quick Access connector group
    $connectors = @()
    $activeConnectorCount = 0
    if ($quickAccessGroup) {
        Write-ZtProgress -Activity $activity -Status 'Checking connectors in Quick Access connector group'
        try {
            $connectors = @(Invoke-ZtGraphRequest -RelativeUri "onPremisesPublishingProfiles/applicationProxy/connectorGroups/$($quickAccessGroup.id)/members" -ApiVersion beta)
        }
        catch {
            Write-PSFMessage "Unable to list connectors for group $($quickAccessGroup.name): $($_.Exception.Message)" -Tag Test -Level Warning
        }
        $activeConnectorCount = @($connectors | Where-Object { $_.status -eq 'active' }).Count
    }

    #endregion Data Collection

    #region Assessment Logic

    $passed = $false

    if ($profileState -ne 'enabled') {
        Write-PSFMessage "Q1 Fail: Private Access forwarding profile state is '$profileState'" -Tag Test -Level VeryVerbose
    }
    elseif ($connectorGroups.Count -eq 0) {
        Write-PSFMessage 'Q2 Fail: No connector groups found' -Tag Test -Level VeryVerbose
    }
    elseif ($null -eq $quickAccessGroup) {
        Write-PSFMessage 'Q3 Fail: No connector group has the Quick Access application assigned' -Tag Test -Level VeryVerbose
    }
    elseif ($activeConnectorCount -eq 0) {
        Write-PSFMessage 'Q4 Fail: No active connectors in the Quick Access connector group' -Tag Test -Level VeryVerbose
    }
    else {
        $passed = $true
    }

    $testResultMarkdown = if ($passed) {
        "Quick Access is bound to a connector group with at least one active connector, and the Private Access traffic forwarding profile is enabled.`n`n%TestResult%"
    }
    else {
        "Quick Access is not bound to a connector group with active connectors, or the Private Access traffic forwarding profile is not enabled.`n`n%TestResult%"
    }

    #endregion Assessment Logic

    #region Report Generation

    $mdInfo = ''

    $portalLink = 'https://entra.microsoft.com/#view/Microsoft_AAD_IAM/QuickAccessMenuBlade/~/GlobalSecureAccess'
    $groupName  = if ($quickAccessGroup) { Get-SafeMarkdown -Text $quickAccessGroup.name } else { 'N/A' }
    $groupId    = if ($quickAccessGroup) { $quickAccessGroup.id } else { 'N/A' }
    $qaAssigned = if ($quickAccessGroup) { 'Yes' } else { 'No' }

    $mdInfo += @"

## [Quick Access Connector Binding Status]($portalLink)

| Property | Value |
| :--- | :--- |
| Private Access Profile State | $profileState |
| Connector Group Name | $groupName |
| Connector Group ID | $groupId |
| Quick Access App Assigned | $qaAssigned |

"@

    if ($connectors.Count -gt 0) {
        $connectorRows = ''
        foreach ($connector in $connectors) {
            $name    = Get-SafeMarkdown -Text $connector.machineName
            $status  = if ($connector.status -eq 'active') { '✅ Active' } else { '❌ Inactive' }
            $ip      = if ($connector.externalIp) { $connector.externalIp } else { 'N/A' }
            $version = if ($connector.version) { $connector.version } else { 'N/A' }
            $connectorRows += "| $name | $status | $ip | $version |`n"
        }

        $mdInfo += @'
## Connector Status

| Connector Name | Status | External IP | Version |
| :--- | :--- | :--- | :--- |
{0}
'@ -f $connectorRows
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
