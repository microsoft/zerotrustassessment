<#
.SYNOPSIS
    The tenant holds the licenses required to operate Global Secure Access.

.DESCRIPTION
    This test verifies that the tenant holds the licensing prerequisites for Global Secure Access:
    - Microsoft Entra ID P1 (foundational requirement)
    - At least one GSA entitlement with capabilityStatus = "Enabled":
      * Microsoft Entra Internet Access
      * Microsoft Entra Private Access
      * Microsoft Agent 365

    Per-user license assignment is intentionally not evaluated. License enforcement
    for Global Secure Access is applied at the tenant level.

.NOTES
    Test ID: 25375
    Category: Global Secure Access
    Required API: subscribedSkus (beta)
    GSA Service Plan IDs:
    - Entra_Premium_Internet_Access: 8d23cb83-ab07-418f-8517-d7aca77307dc
    - Entra_Premium_Private_Access: f057aab1-b184-49b2-85c0-881b02a405c5
    - AGENT_365: d0ce5ebb-9db0-491f-b780-8973a1d815fe
#>

function Test-Assessment-25375 {
    [ZtTest(
    	Category = 'Global Secure Access',
    	ImplementationCost = 'Low',
    	Service = ('Graph'),
    	CompatibleLicense = ('AAD_PREMIUM','AAD_PREMIUM_P2'),
    	Pillar = 'Network',
    	RiskLevel = 'High',
    	SfiPillar = 'Protect networks',
    	TenantType = ('Workforce'),
    	TestId = 25375,
    	Title = 'The tenant holds the licenses required to operate Global Secure Access',
    	UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking Global Secure Access licensing prerequisites'
    Write-ZtProgress -Activity $activity -Status 'Querying tenant licenses'

    # GSA Service Plan IDs
    $gsaServicePlanIds = @{
        InternetAccess = '8d23cb83-ab07-418f-8517-d7aca77307dc' # Entra_Premium_Internet_Access
        PrivateAccess  = 'f057aab1-b184-49b2-85c0-881b02a405c5' # Entra_Premium_Private_Access
        Agent365       = 'd0ce5ebb-9db0-491f-b780-8973a1d815fe' # AGENT_365
    }

    $skuCmdletFailed = $false
    $subscribedSkus = @()

    # Q1: Retrieve tenant licenses with GSA service plans
    try {
        $subscribedSkus = Invoke-ZtGraphRequest -RelativeUri 'subscribedSkus' -ApiVersion beta -ErrorAction Stop
    }
    catch {
        $skuCmdletFailed = $true
        Write-PSFMessage "Failed to retrieve subscribed SKUs: $_" -Tag Test -Level Warning
    }
    #endregion Data Collection

    #region Assessment Logic
    $testResultMarkdown = ''
    $passed = $false
    $customStatus = $null

    # Handle query failure - cannot determine license status
    if ($skuCmdletFailed) {
        Write-PSFMessage "Unable to retrieve GSA license data due to query failure" -Tag Test -Level Warning
        $customStatus = 'Investigate'
        $testResultMarkdown = "⚠️ Unable to determine Global Secure Access licensing prerequisites due to query failure, connection issues, or insufficient permissions.`n`n%TestResult%"

        $params = @{
            TestId       = '25375'
            Title        = 'The tenant holds the licenses required to operate Global Secure Access'
            Status       = $false
            Result       = $testResultMarkdown
            CustomStatus = $customStatus
        }
        Add-ZtTestResultDetail @params
        return
    }

    # Filter SKUs containing any GSA service plans - if none exist, skip the test
    $gsaSkus = @($subscribedSkus | Where-Object {
        $_.ServicePlans | Where-Object { $_.ServicePlanId -in $gsaServicePlanIds.Values }
    })

    if ($gsaSkus.Count -eq 0) {
        Write-PSFMessage 'No GSA-related SKUs found in tenant.' -Tag Test -Level Verbose
        Add-ZtTestResultDetail -SkippedBecause NotApplicable -Result 'No GSA licenses are available in this tenant.'
        return
    }

    # Identify which GSA service plans are available with Enabled status
    $availableServicePlans = @{}
    foreach ($planKey in $gsaServicePlanIds.Keys) {
        $planId = $gsaServicePlanIds[$planKey]
        $availableServicePlans[$planKey] = $false

        foreach ($sku in $subscribedSkus) {
            if ($sku.CapabilityStatus -eq 'Enabled') {
                $matchingPlan = $sku.ServicePlans | Where-Object { $_.ServicePlanId -eq $planId }
                if ($matchingPlan) {
                    $availableServicePlans[$planKey] = $true
                    break
                }
            }
        }
    }

    # Compute licensing signals
    $hasInternetAccess = $availableServicePlans['InternetAccess']
    $hasPrivateAccess  = $availableServicePlans['PrivateAccess']
    $hasAgent365       = $availableServicePlans['Agent365']

    $hasGsaEntitlement     = $hasInternetAccess -and $hasPrivateAccess -and $hasAgent365
    $hasPartialEntitlement = ($hasInternetAccess -or $hasPrivateAccess -or $hasAgent365) -and (-not $hasGsaEntitlement)

    # Evaluate results
    if ($hasGsaEntitlement) {
        $passed = $true
        $testResultMarkdown = "✅ The tenant has all active Global Secure Access licensing entitlement.`n`n%TestResult%"
    }
    elseif ($hasPartialEntitlement) {
        $passed = $false
        $customStatus = 'Investigate'
        $missingPlans = @()
        if (-not $hasInternetAccess) { $missingPlans += 'Microsoft Entra Internet Access' }
        if (-not $hasPrivateAccess)  { $missingPlans += 'Microsoft Entra Private Access' }
        if (-not $hasAgent365)       { $missingPlans += 'Microsoft Agent 365' }
        $missingList = $missingPlans -join ', '
        $testResultMarkdown = "⚠️ The tenant is missing some of the Global Secure Access licensing entitlements: $missingList.`n`n%TestResult%"
    }
    else {
        $passed = $false
        $testResultMarkdown = "❌ The tenant is missing all of the required prerequisites — an active Global Secure Access licensing entitlement for all Microsoft Entra Internet Access, Microsoft Entra Private Access and Microsoft Agent 365.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    # Build detailed information if we have GSA-related SKUs
    $mdInfo = ''

    if ($gsaSkus.Count -gt 0) {
        $reportTitle = 'Licenses'
        $portalLink = 'https://admin.microsoft.com/Adminportal/Home#/licenses'

        $formatTemplate = @'


## [{0}]({1})

**Tenant Licensing Summary:**

| Requirement | Status | Source SKU(s) |
| :---------- | :----- | :------------ |
{2}

**SKUs Containing Tracked Service Plans:**

{4}{3}
'@

        # Build requirement status table
        $requirementTableRows = ''

        # Determine source SKUs for each service plan
        $internetAccessSkus = @($gsaSkus | Where-Object {
            $_.CapabilityStatus -eq 'Enabled' -and ($_.ServicePlans | Where-Object { $_.ServicePlanId -eq $gsaServicePlanIds.InternetAccess })
        } | ForEach-Object { Get-SafeMarkdown -Text $_.SkuPartNumber })

        $privateAccessSkus = @($gsaSkus | Where-Object {
            $_.CapabilityStatus -eq 'Enabled' -and ($_.ServicePlans | Where-Object { $_.ServicePlanId -eq $gsaServicePlanIds.PrivateAccess })
        } | ForEach-Object { Get-SafeMarkdown -Text $_.SkuPartNumber })

        $agent365Skus = @($gsaSkus | Where-Object {
            $_.CapabilityStatus -eq 'Enabled' -and ($_.ServicePlans | Where-Object { $_.ServicePlanId -eq $gsaServicePlanIds.Agent365 })
        } | ForEach-Object { Get-SafeMarkdown -Text $_.SkuPartNumber })

        # Internet Access row
        $internetStatus = if ($hasInternetAccess) { '✅ Enabled' } else { '❌ Missing' }
        $internetSkuList = if ($internetAccessSkus.Count -gt 0) { $internetAccessSkus -join ', ' } else { '—' }
        $requirementTableRows += "| Microsoft Entra Internet Access | $internetStatus | $internetSkuList |`n"

        # Private Access row
        $privateStatus = if ($hasPrivateAccess) { '✅ Enabled' } else { '❌ Missing' }
        $privateSkuList = if ($privateAccessSkus.Count -gt 0) { $privateAccessSkus -join ', ' } else { '—' }
        $requirementTableRows += "| Microsoft Entra Private Access | $privateStatus | $privateSkuList |`n"

        # Agent 365 row
        $agent365Status = if ($hasAgent365) { '✅ Enabled' } else { '❌ Missing' }
        $agent365SkuList = if ($agent365Skus.Count -gt 0) { $agent365Skus -join ', ' } else { '—' }
        $requirementTableRows += "| Microsoft Agent 365 | $agent365Status | $agent365SkuList |`n"

        # Build SKU details table
        $skuDetailRows = ''
        $maxDisplay = 10
        $totalSkus = $gsaSkus.Count
        $displaySkus = if ($totalSkus -gt $maxDisplay) { $gsaSkus | Select-Object -First $maxDisplay } else { $gsaSkus }

        # Add count header if truncation occurs
        $countHeader = ''
        if ($totalSkus -gt $maxDisplay) {
            $countHeader = "Showing $maxDisplay of $totalSkus SKUs.`n`n"
        }

        foreach ($sku in $displaySkus) {
            $skuName = Get-SafeMarkdown -Text $sku.SkuPartNumber
            $capabilityStatus = $sku.CapabilityStatus

            # List tracked service plans in this SKU
            $trackedPlans = @($sku.ServicePlans | Where-Object { $_.ServicePlanId -in $gsaServicePlanIds.Values } | ForEach-Object { Get-SafeMarkdown -Text $_.ServicePlanName })
            $planList = if ($trackedPlans.Count -gt 0) { $trackedPlans -join ', ' } else { '—' }

            $available = $sku.PrepaidUnits.Enabled
            $assigned = $sku.ConsumedUnits

            $skuDetailRows += "| $skuName | $capabilityStatus | $planList | $available | $assigned |`n"
        }

        if ($totalSkus -gt $maxDisplay) {
            $remaining = $totalSkus - $maxDisplay
            $skuDetailRows += "| ... ($remaining more) | | | | |`n"
        }

        # Build complete table with header row
        $tableWithHeader = "| SKU Name | Capability Status | Tracked Service Plans Included | Available | Assigned |`n"
        $tableWithHeader += "| :------- | :---------------- | :----------------------------- | --------: | -------: |`n"
        $tableWithHeader += $skuDetailRows

        $mdInfo = $formatTemplate -f $reportTitle, $portalLink, $requirementTableRows, $tableWithHeader, $countHeader
    }
    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '25375'
        Title  = 'The tenant holds the licenses required to operate Global Secure Access'
        Status = $passed
        Result = $testResultMarkdown
    }
    if ($customStatus) {
        $params.CustomStatus = $customStatus
    }
    Add-ZtTestResultDetail @params
}
