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
    $q1Error = $null
    try {
        $forwardingProfiles = Invoke-ZtGraphRequest -RelativeUri 'networkAccess/forwardingProfiles' -ApiVersion beta
    }
    catch {
        $q1Error = $_
        Write-PSFMessage "Unable to retrieve Private Access forwarding profile: $($_.Exception.Message)" -Tag Test -Level Error
    }
    $privateProfile = $forwardingProfiles | Where-Object { $_.trafficForwardingType -eq 'private' } | Select-Object -First 1
    $profileState = if ($privateProfile) { $privateProfile.state } else { 'Not found' }

    # Q2: List all connector groups
    Write-ZtProgress -Activity $activity -Status 'Querying connector groups'
    $connectorGroups = @()
    $q2Error = $null
    try {
        $connectorGroups = @(Invoke-ZtGraphRequest -RelativeUri 'onPremisesPublishingProfiles/applicationProxy/connectorGroups' -ApiVersion beta)
    }
    catch {
        $q2Error = $_
        Write-PSFMessage "Unable to retrieve connector groups: $($_.Exception.Message)" -Tag Test -Level Error
    }

    # Q3: Find the Quick Access service principal by its tag, then locate its connector group
    # The NetworkAccessQuickAccessApplication tag is on the servicePrincipal, not the application object.
    Write-ZtProgress -Activity $activity -Status 'Checking Quick Access application assignment'
    $quickAccessSp = $null
    $q3Error = $null
    try {
        $quickAccessSp = @(Invoke-ZtGraphRequest -RelativeUri "servicePrincipals?`$filter=tags/any(t:t eq 'NetworkAccessQuickAccessApplication')" -ApiVersion beta) | Select-Object -First 1
    }
    catch {
        $q3Error = $_
        Write-PSFMessage "Unable to query service principals for Quick Access tag: $($_.Exception.Message)" -Tag Test -Level Error
    }

    $quickAccessGroup = $null
    if ($quickAccessSp) {
        foreach ($group in $connectorGroups) {
            $apps = @()
            try {
                $apps = @(Invoke-ZtGraphRequest -RelativeUri "onPremisesPublishingProfiles/applicationProxy/connectorGroups/$($group.id)/applications" -ApiVersion beta)
            }
            catch {
                Write-PSFMessage "Unable to list applications for connector group $($group.name): $($_.Exception.Message)" -Tag Test -Level Warning
                continue
            }
            if ($apps | Where-Object { $_.appId -eq $quickAccessSp.appId }) {
                $quickAccessGroup = $group
                break
            }
        }
    }

    # Q4: List connectors in the Quick Access connector group
    $connectors = @()
    $q4Error = $null
    $activeConnectorCount = 0
    if ($quickAccessGroup) {
        Write-ZtProgress -Activity $activity -Status 'Checking connectors in Quick Access connector group'
        try {
            $connectors = @(Invoke-ZtGraphRequest -RelativeUri "onPremisesPublishingProfiles/applicationProxy/connectorGroups/$($quickAccessGroup.id)/members" -ApiVersion beta)
        }
        catch {
            $q4Error = $_
            Write-PSFMessage "Unable to list connectors for group $($quickAccessGroup.name): $($_.Exception.Message)" -Tag Test -Level Error
        }
        $activeConnectorCount = @($connectors | Where-Object { $_.status -eq 'active' }).Count
    }

    #endregion Data Collection

    #region Assessment Logic

    $passed = $false
    $apiError = $null

    if ($q1Error) {
        $apiError = "Unable to determine Quick Access status. An error occurred while retrieving the Private Access forwarding profile: $q1Error"
    }
    elseif ($q2Error) {
        $apiError = "Unable to determine Quick Access status. An error occurred while retrieving connector groups: $q2Error"
    }
    elseif ($q3Error) {
        $apiError = "Unable to determine Quick Access status. An error occurred while querying for the Quick Access service principal: $q3Error"
    }
    elseif ($q4Error) {
        $apiError = "Unable to determine Quick Access status. An error occurred while retrieving connectors: $q4Error"
    }
    elseif ($profileState -ne 'enabled') {
        Write-PSFMessage "Q1 Fail: Private Access forwarding profile state is '$profileState'" -Tag Test -Level VeryVerbose
    }
    elseif ($connectorGroups.Count -eq 0) {
        Write-PSFMessage 'Q2 Fail: No connector groups found' -Tag Test -Level VeryVerbose
    }
    elseif ($null -eq $quickAccessSp) {
        Write-PSFMessage 'Q3 Fail: No service principal with the NetworkAccessQuickAccessApplication tag found' -Tag Test -Level VeryVerbose
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

    $testResultMarkdown = if ($apiError) {
        $apiError
    }
    elseif ($passed) {
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
    $qaAssigned = if ($quickAccessGroup) { 'Yes' } else { 'No' }

    $mdInfo += @"

## [Quick Access Connector Binding Status]($portalLink)

| Property | Value |
| :--- | :--- |
| Private Access Profile State | $profileState |
| Connector Group Name | $groupName |
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
