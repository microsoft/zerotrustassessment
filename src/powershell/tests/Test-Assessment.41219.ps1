<#
.SYNOPSIS
    Microsoft Graph identity and device APIs are queryable so analysts (with Security Copilot) can review identities and devices during investigation.

.NOTES
    Test ID: 41219
    Workshop Task: SECOPS_129
    Pillar: SecOps
    Category: AI for security
    Required Graph permissions: Device.Read.All (Q1), User.Read.All (Q2),
        DeviceManagementManagedDevices.Read.All (Q3), LicenseAssignment.Read.All (Q5)
    Required Azure role: Reader (or equivalent) on subscriptions hosting Security Copilot capacity (Q4)
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
    $activity = 'Checking Microsoft Graph identity and device data plane reachability for Security Copilot'

    # Q5: Determine Intune licensing from subscribedSkus before evaluating Q3.
    # Required permission: LicenseAssignment.Read.All (least-privilege).
    # INTUNE_A (Plan 1) and INTUNE_P2 (Plan 2, additive to Plan 1) both indicate Intune is licensed.
    Write-ZtProgress -Activity $activity -Status 'Checking Intune licensing via subscribedSkus (Q5)'
    $intuneServicePlanNames = @('INTUNE_A', 'INTUNE_P2')
    $intuneLicensed   = $false
    $decidingPlanName = $null
    $subscribedSkusCount = 0
    try {
        $subscribedSkus    = @(Invoke-ZtGraphRequest -RelativeUri 'subscribedSkus' -Select 'skuPartNumber,servicePlans,capabilityStatus' -ApiVersion beta -ErrorAction Stop)
        $subscribedSkusCount = $subscribedSkus.Count
        $decidingPlan      = $subscribedSkus |
            Where-Object { $_.capabilityStatus -eq 'Enabled' } |
            ForEach-Object { $_.servicePlans } |
            Where-Object { $_.servicePlanName -in $intuneServicePlanNames -and $_.provisioningStatus -eq 'Success' } |
            Select-Object -First 1
        $intuneLicensed   = $null -ne $decidingPlan
        if ($decidingPlan) { $decidingPlanName = $decidingPlan.servicePlanName }
    }
    catch {
        Write-PSFMessage "Q5 subscribedSkus query failed: $($_.Exception.Message)" -Tag Test -Level Warning
        $params = @{
            TestId       = '41219'
            Title        = 'Microsoft Graph identity and device APIs are queryable so analysts (with Security Copilot) can review identities and devices during investigation'
            # More specific than the generic spec Investigate message; names the required permission for actionability.
            Status       = $false
            Result       = "⚠️ Intune licensing could not be determined — ``GET /subscribedSkus`` returned an error. Verify the assessment principal has ``LicenseAssignment.Read.All`` permission and re-run."
            CustomStatus = 'Investigate'
        }
        Add-ZtTestResultDetail @params
        return
    }

    # Q1: Verify the Microsoft Entra device data plane is reachable.
    Write-ZtProgress -Activity $activity -Status 'Verifying Entra device data plane (Q1)'
    $q1Devices    = $null
    $q1Error      = $null
    $q1HttpStatus = $null
    try {
        $q1Devices = @((Invoke-ZtGraphRequest -RelativeUri 'devices' -Select 'id,displayName,operatingSystem,trustType,isCompliant,isManaged' -Top 1 -DisablePaging -ApiVersion beta -ErrorAction Stop).value)
    }
    catch {
        $q1Error      = $_
        $q1HttpStatus = Get-ZtHttpStatusCode -ErrorRecord $_
        Write-PSFMessage "Q1 Entra devices query failed: $($_.Exception.Message)" -Tag Test -Level Warning
    }

    # Q2: Verify the Microsoft Entra users data plane is reachable.
    Write-ZtProgress -Activity $activity -Status 'Verifying Entra users data plane (Q2)'
    $q2Users      = $null
    $q2Error      = $null
    $q2HttpStatus = $null
    try {
        $q2Users = @((Invoke-ZtGraphRequest -RelativeUri 'users' -Select 'id,userPrincipalName,accountEnabled,assignedLicenses' -Top 1 -DisablePaging -ApiVersion beta -ErrorAction Stop).value)
    }
    catch {
        $q2Error      = $_
        $q2HttpStatus = Get-ZtHttpStatusCode -ErrorRecord $_
        Write-PSFMessage "Q2 Entra users query failed: $($_.Exception.Message)" -Tag Test -Level Warning
    }

    # Q3: Verify the Intune managed device data plane (excluded as N/A when Intune is not licensed per Q5).
    $q3Devices    = $null
    $q3Error      = $null
    $q3HttpStatus = $null
    $q3Excluded   = -not $intuneLicensed
    if (-not $q3Excluded) {
        Write-ZtProgress -Activity $activity -Status 'Verifying Intune managed device data plane (Q3)'
        try {
            $q3Devices = @((Invoke-ZtGraphRequest -RelativeUri 'deviceManagement/managedDevices' -Select 'id,deviceName,operatingSystem,complianceState,lastSyncDateTime' -Top 1 -DisablePaging -ApiVersion beta -ErrorAction Stop).value)
        }
        catch {
            $q3Error      = $_
            $q3HttpStatus = Get-ZtHttpStatusCode -ErrorRecord $_
            Write-PSFMessage "Q3 Intune managed devices query failed: $($_.Exception.Message)" -Tag Test -Level Warning
        }
    }

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

    # Classify each Graph data plane as Reachable, Investigate, or N/A (Q3 excluded when Intune not licensed).
    $q1Status = if ($null -ne $q1Error) { 'Investigate' } else { 'Reachable' }
    $q2Status = if ($null -ne $q2Error) { 'Investigate' } else { 'Reachable' }
    $q3Status = if ($q3Excluded) { 'N/A' } elseif ($null -ne $q3Error) { 'Investigate' } else { 'Reachable' }

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

    # Pass: Q1 AND Q2 reachable AND (Q3 reachable OR Q3 excluded) AND Q4 Succeeded.
    $entraReachable = ($q1Status -eq 'Reachable') -and ($q2Status -eq 'Reachable')
    $intuneOk       = ($q3Status -eq 'Reachable') -or ($q3Status -eq 'N/A')
    $capacityReady  = ($q4Status -eq 'Succeeded')
    $passed         = $entraReachable -and $intuneOk -and $capacityReady
    $customStatus   = if ($passed) { $null } else { 'Investigate' }

    if ($passed) {
        $testResultMarkdown = "✅ Microsoft Entra users and devices are reachable, the Intune managed-devices plane is reachable (or excluded as not licensed), and a Security Copilot capacity is provisioned — so the prerequisites for AI-assisted identity and device review are in place for the assessment principal.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "⚠️ A data plane returned an authorization failure (401/403), throttling, a service error, or a malformed response; or no Security Copilot capacity was returned — an eligible Microsoft 365 E5/E7 tenant may have an inclusion-path capacity that Azure Resource Graph does not surface, so verify enablement in the Security Copilot portal; or the returned capacity is not in a ``Succeeded`` provisioning state.`n`n%TestResult%"
    }

    #endregion Assessment Logic

    #region Report Generation

    # Build the data plane summary table (Q1, Q2, Q3, Q5).
    $q1Icon  = if ($q1Status -eq 'Reachable') { '✅ Reachable' } elseif ($null -ne $q1HttpStatus) { "⚠️ HTTP $q1HttpStatus" } else { '⚠️ Investigate' }
    $q1Count = if ($null -eq $q1Error) { $q1Devices.Count } else { '—' }
    $q1Props = if ($null -eq $q1Error -and $q1Devices.Count -gt 0) {
        $d = $q1Devices[0]
        "trustType=$($d.trustType), isCompliant=$($d.isCompliant), isManaged=$($d.isManaged)"
    } elseif ($null -ne $q1HttpStatus -and $q1HttpStatus -in @(401, 403)) {
        "HTTP $q1HttpStatus — verify Device.Read.All is granted"
    } else { '—' }

    $q2Icon  = if ($q2Status -eq 'Reachable') { '✅ Reachable' } elseif ($null -ne $q2HttpStatus) { "⚠️ HTTP $q2HttpStatus" } else { '⚠️ Investigate' }
    $q2Count = if ($null -eq $q2Error) { $q2Users.Count } else { '—' }
    $q2Props = if ($null -eq $q2Error -and $q2Users.Count -gt 0) {
        $u = $q2Users[0]
        "accountEnabled=$($u.accountEnabled), assignedLicenses=$($u.assignedLicenses.Count)"
    } elseif ($null -ne $q2HttpStatus -and $q2HttpStatus -in @(401, 403)) {
        "HTTP $q2HttpStatus — verify User.Read.All is granted"
    } else { '—' }

    $q3Icon  = switch ($q3Status) {
        'Reachable'   { '✅ Reachable' }
        'N/A'         { '— N/A' }
        default       { if ($null -ne $q3HttpStatus) { "⚠️ HTTP $q3HttpStatus" } else { '⚠️ Investigate' } }
    }
    $q3Count = if ($q3Excluded) { '—' } elseif ($null -eq $q3Error) { $q3Devices.Count } else { '—' }
    $q3Props = if ($q3Excluded) {
        'N/A (Intune not licensed) — excluded from evaluation'
    } elseif ($null -eq $q3Error -and $q3Devices.Count -gt 0) {
        "complianceState=$($q3Devices[0].complianceState)"
    } elseif ($null -ne $q3HttpStatus -and $q3HttpStatus -in @(401, 403)) {
        "HTTP $q3HttpStatus — verify DeviceManagementManagedDevices.Read.All is granted"
    } else { '—' }

    # Q5 row: licensing decision and deciding service-plan identifier.
    $q5LicenseIcon = if ($intuneLicensed) { '✅ Licensed' } else { '❌ Not licensed' }
    $q5PlanDisplay = if ($decidingPlanName) { $decidingPlanName } else { '—' }

    $planeRows = @"
| Entra devices (Q1) | $q1Icon | $q1Count | $q1Props |
| Entra users (Q2) | $q2Icon | $q2Count | $q2Props |
| Intune managed devices (Q3) | $q3Icon | $q3Count | $q3Props |
| Intune licensing probe (Q5) | $q5LicenseIcon | $subscribedSkusCount | Deciding plan: $q5PlanDisplay |
"@

    $dataPlaneTemplate = @'

## Data plane and licensing status

| Data plane | Status | Row count | Sample properties / notes |
| :--------- | :----- | --------: | :------------------------ |
{0}
'@
    $mdInfo = $dataPlaneTemplate -f $planeRows

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
