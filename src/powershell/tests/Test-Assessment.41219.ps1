<#
.SYNOPSIS
    Microsoft Graph identity and device APIs are queryable so analysts (with Security Copilot) can review identities and devices during investigation.

.NOTES
    Test ID: 41219
    Workshop Task: SECOPS_129
    Pillar: SecOps
    Category: AI for security
    Required Azure role: Reader (or equivalent) on subscriptions hosting Security Copilot capacity (Q4)

    Q1/Q2/Q3/Q5 (Entra/Intune data-plane reachability and Intune licensing) are asserted via the
    MinimumLicense/Service metadata rather than runtime Graph queries; only Q4 is evaluated at runtime.
#>

function Test-Assessment-41219 {
    [ZtTest(
        Category           = 'AI for security',
        ImplementationCost = 'Low',
        MinimumLicense     = ('Consumption-based: Microsoft Security Copilot'),
        Pillar             = 'SecOps',
        RiskLevel          = 'Medium',
        Service            = ('Azure', 'Graph'),
        SfiPillar          = 'Accelerate response and remediation',
        TenantType         = ('Workforce'),
        TestId             = 41219,
        Title              = 'Microsoft Graph identity and device APIs are queryable so analysts (with Security Copilot) can review identities and devices during investigation',
        UserImpact         = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose
    $activity = 'Checking Security Copilot capacity provisioning'

    # Q4: Verify Security Copilot capacity via Azure Resource Graph.
    # Required Azure role: Reader (or equivalent read access) on the subscriptions hosting the capacity.
    Write-ZtProgress -Activity $activity -Status 'Verifying Security Copilot capacity via Azure Resource Graph (Q4)'
    $argQuery = @"
resources
| where type =~ 'microsoft.securitycopilot/capacities'
| join kind=leftouter (
    resourcecontainers
    | where type =~ 'microsoft.resources/subscriptions'
    | where properties.state =~ 'Enabled'
    | project subscriptionId, subscriptionName = name
) on subscriptionId
| project id, name, location, resourceGroup, subscriptionId, subscriptionName, provisioningState = tostring(properties.provisioningState)
"@
    $capacities = @()
    $q4Error    = $null
    try {
        $capacities = @(Invoke-ZtAzureResourceGraphRequest -Query $argQuery)
        Write-PSFMessage "Q4 ARG returned $($capacities.Count) Security Copilot capacity resource(s)" -Tag Test -Level VeryVerbose
    }
    catch {
        $q4Error = $_
        Write-PSFMessage "Q4 ARG query failed: $($q4Error.Exception.Message)" -Tag Test -Level Warning
    }

    #endregion Data Collection

    #region Assessment Logic

    # Classify Q4: Succeeded only when at least one capacity has provisioningState == Succeeded.
    $q4HttpStatus  = $null
    $succeededCaps = @()
    if ($null -ne $q4Error) {
        # Invoke-ZtAzureResourceGraphRequest throws "Azure REST request failed with status <code>: ..."
        if ($q4Error.Exception.Message -match 'with status (\d+):') {
            $q4HttpStatus = [int]$Matches[1]
        }
    }
    else {
        $succeededCaps = @($capacities | Where-Object { $_.provisioningState -eq 'Succeeded' })
    }
    $q4Status = if ($null -ne $q4Error) { 'Investigate' } elseif ($succeededCaps.Count -gt 0) { 'Succeeded' } else { 'Investigate' }

    # Pass: Q4 Succeeded (a Security Copilot capacity is provisioned and reachable via ARG).
    $passed       = ($q4Status -eq 'Succeeded')
    $customStatus = if ($passed) { $null } else { 'Investigate' }

    if ($passed) {
        $testResultMarkdown = "✅ A Security Copilot capacity is provisioned — so the prerequisites for AI-assisted identity and device review are in place for the assessment principal.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "⚠️ Azure Resource Graph returned an authorization failure, a service error, or no Security Copilot capacity — an eligible Microsoft 365 E5/E7 tenant may have an inclusion-path capacity that Azure Resource Graph does not surface, so verify enablement in the Security Copilot portal; or the returned capacity is not in a ``Succeeded`` provisioning state.`n`n%TestResult%"
    }

    #endregion Assessment Logic

    #region Report Generation

    $mdInfo = ''

    # Q4 capacity section (pattern from Test-Assessment.41215).
    $copilotCapacitiesLink = 'https://portal.azure.com/#browse/microsoft.securitycopilot%2Fcapacities'
    if ($null -ne $q4Error) {
        $q4ErrText = if ($q4HttpStatus -in @(401, 403)) {
            "Azure Resource Graph returned an authorization error (HTTP $q4HttpStatus). Verify the assessment principal has Azure Reader (or equivalent) access on the relevant subscriptions."
        } else {
            "Azure Resource Graph returned an error: $($q4Error.Exception.Message)"
        }
        $mdInfo += "`n⚠️ $q4ErrText`n"
    }
    elseif ($capacities.Count -gt 0) {
        $capacityRows = ''
        foreach ($item in $capacities | Sort-Object name) {
            $nameLink    = "[$(Get-SafeMarkdown $item.name)](https://portal.azure.com/#resource$($item.id))"
            $subDisplay  = if (-not [string]::IsNullOrWhiteSpace($item.subscriptionName)) { Get-SafeMarkdown $item.subscriptionName } else { $item.subscriptionId }
            $stateIcon   = switch ($item.provisioningState) {
                'Succeeded'                         { '✅ Succeeded' }
                { [string]::IsNullOrEmpty($_) }     { '⚠️ Unknown' }
                default                             { "⚠️ $($item.provisioningState)" }
            }
            $capacityRows += "| $nameLink | $(Get-SafeMarkdown $item.resourceGroup) | $($item.location) | $subDisplay | $stateIcon |`n"
        }

        $capacityTemplate = @'

## [Security Copilot capacities]({0})

| Name | Resource group | Location | Subscription | Provisioning state |
| :--- | :------------- | :------- | :----------- | :----------------- |
{1}
'@
        $mdInfo += $capacityTemplate -f $copilotCapacitiesLink, $capacityRows
    }
    else {
        $mdInfo += "`n⚠️ No Security Copilot capacity resources were found via Azure Resource Graph. An eligible Microsoft 365 E5/E7 tenant may have an inclusion-path capacity that is not visible to ARM — verify enablement in the [Security Copilot portal]($copilotCapacitiesLink).`n"
    }

    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo

    #endregion Report Generation

    $params = @{
        TestId = '41219'
        Title  = 'Microsoft Graph identity and device APIs are queryable so analysts (with Security Copilot) can review identities and devices during investigation'
        Status = $passed
        Result = $testResultMarkdown
    }
    if ($null -ne $customStatus) {
        $params.CustomStatus = $customStatus
    }
    Add-ZtTestResultDetail @params
}
