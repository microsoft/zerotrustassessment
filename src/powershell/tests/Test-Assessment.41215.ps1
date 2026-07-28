<#
.SYNOPSIS
    Microsoft Security Copilot capacity (Security Compute Units) is provisioned in the tenant

.DESCRIPTION
    Verifies that at least one Microsoft Security Copilot Security Compute Unit (SCU) capacity
    is provisioned and in the Succeeded state across all Azure subscriptions accessible to the
    caller, using Azure Resource Graph.

.NOTES
    Test ID: 41215
    Workshop Task: SECOPS_110
    Pillar: SecOps
    Category: AI for security
    Required API: Azure Resource Graph (management.azure.com)
#>

function Test-Assessment-41215 {
    [ZtTest(
        Category = 'AI for security',
        ImplementationCost = 'Low',
        Service = ('Azure'),
        MinimumLicense = ('Consumption-based: Microsoft Security Copilot'),
        Pillar = 'SecOps',
        RiskLevel = 'Medium',
        SfiPillar = 'Monitor and detect cyberthreats',
        TenantType = ('Workforce'),
        TestId = 41215,
        Title = 'Microsoft Security Copilot capacity (Security Compute Units) is provisioned in the tenant',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking Microsoft Security Copilot capacity provisioning'

    # Q1: Enumerate Security Copilot capacity resources across all accessible subscriptions via Azure Resource Graph.
    # Joining resourcecontainers to surface subscription display names alongside the capacity rows.
    Write-ZtProgress -Activity $activity -Status 'Querying Security Copilot capacities via Resource Graph'

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
    try {
        $capacities = @(Invoke-ZtAzureResourceGraphRequest -Query $argQuery)
        Write-PSFMessage "ARG Query returned $($capacities.Count) Security Copilot capacity resource(s)" -Tag Test -Level VeryVerbose
    }
    catch {
        Write-PSFMessage "Azure Resource Graph query failed: $($_.Exception.Message)" -Tag Test -Level Warning
        # Spec: this check never returns Skipped from the function body; an ARG error is Investigate.
        $params = @{
            TestId       = '41215'
            Title        = 'Microsoft Security Copilot capacity (Security Compute Units) is provisioned in the tenant'
            Status       = $false
            Result       = '⚠️ Azure Resource Graph returned an unexpected error while querying Security Copilot capacities. This is likely a transient issue; re-run the assessment.'
            CustomStatus = 'Investigate'
        }
        Add-ZtTestResultDetail @params
        return
    }
    #endregion Data Collection

    #region Assessment Logic
    $passed = $false
    $customStatus = $null

    # Pass: at least one capacity resource reports provisioningState = Succeeded.
    # Investigate: zero rows (may indicate E5/E7 inclusion path or no subscription scope) OR
    #              rows present but none in Succeeded state (e.g. Failed, Provisioning, Deleting).
    $succeededCapacities = @($capacities | Where-Object { $_.provisioningState -eq 'Succeeded' })

    if ($succeededCapacities.Count -gt 0) {
        $passed = $true
        $testResultMarkdown = "✅ A Microsoft Security Copilot Security Compute Unit (SCU) capacity is provisioned and ready in the tenant.`n`n%TestResult%"
    }
    else {
        $customStatus = 'Investigate'
        $testResultMarkdown = "⚠️ No ready Security Copilot capacity was returned from Azure Resource Graph. Security Copilot may still be enabled through the Microsoft 365 E5/E7 inclusion path (which is not exposed through ARM), or no Azure subscription scope was available to evaluate; verify enablement in the Security Copilot portal.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    $securityCopilotCapacitiesLink = 'https://portal.azure.com/#browse/microsoft.securitycopilot%2Fcapacities'

    $mdInfo = ''
    if ($capacities.Count -gt 0) {
        $tableRows = ''
        foreach ($item in $capacities | Sort-Object name) {
            $nameLink = "[$(Get-SafeMarkdown $item.name)](https://portal.azure.com/#resource$($item.id))"
            # Prefer subscription display name; fall back to raw subscriptionId when the join returns nothing
            $subscriptionDisplay = if (-not [string]::IsNullOrWhiteSpace($item.subscriptionName)) { Get-SafeMarkdown $item.subscriptionName } else { $item.subscriptionId }
            $provisioningStateDisplay = switch ($item.provisioningState) {
                'Succeeded' { '✅ Succeeded' }
                default     { "⚠️ $($item.provisioningState)" }
            }
            $tableRows += "| $nameLink | $(Get-SafeMarkdown $item.resourceGroup) | $($item.location) | $subscriptionDisplay | $provisioningStateDisplay |`n"
        }

        $formatTemplate = @'


## [Security Copilot capacities]({0})

| Name | Resource group | Location | Subscription | Provisioning state |
| :--- | :------------- | :------- | :----------- | :----------------- |
{1}

'@

        $mdInfo = $formatTemplate -f $securityCopilotCapacitiesLink, $tableRows
    }

    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '41215'
        Title  = 'Microsoft Security Copilot capacity (Security Compute Units) is provisioned in the tenant'
        Status = $passed
        Result = $testResultMarkdown
    }
    if ($null -ne $customStatus) {
        $params.CustomStatus = $customStatus
    }

    Add-ZtTestResultDetail @params
}
