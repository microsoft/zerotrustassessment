<#
.SYNOPSIS
    Validates that GSA licenses are available in the tenant and assigned to users.

.DESCRIPTION
    This test checks whether Global Secure Access (GSA) licenses are provisioned in the tenant
    and actively assigned to users. It verifies:
    - GSA service plans exist in tenant subscribed SKUs
    - Licenses have capabilityStatus = "Enabled"
    - Licenses are assigned to at least one user
    - Service plans are not disabled for assigned users

.NOTES
    Test ID: 25375
    Category: Global Secure Access
    Required API: subscribedSkus (beta), users with assignedLicenses (beta)
    GSA Service Plan IDs:
    - Entra_Premium_Internet_Access: 8d23cb83-ab07-418f-8517-d7aca77307dc
    - Entra_Premium_Private_Access: f057aab1-b184-49b2-85c0-881b02a405c5
#>

function Test-Assessment-25375 {
    [ZtTest(
        Category = 'Global Secure Access',
        ImplementationCost = 'Low',
        MinimumLicense = ('Entra_Premium_Internet_Access', 'Entra_Premium_Private_Access'),
        Pillar = 'Network',
        RiskLevel = 'High',
        SfiPillar = 'Protect networks',
        TenantType = ('Workforce'),
        TestId = 25375,
        Title = 'GSA Licenses are available in the tenant and assigned to users',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking GSA license availability and assignment'
    Write-ZtProgress -Activity $activity -Status 'Querying tenant licenses'

    # GSA Service Plan IDs
    $gsaServicePlanIds = @{
        InternetAccess = '8d23cb83-ab07-418f-8517-d7aca77307dc' # Entra_Premium_Internet_Access
        PrivateAccess  = 'f057aab1-b184-49b2-85c0-881b02a405c5' # Entra_Premium_Private_Access
    }

    $skuCmdletFailed = $false
    $userCmdletFailed = $false
    $subscribedSkus = @()
    $allUsers = @()

    # Query 1: Retrieve tenant licenses with GSA service plans
    try {
        $subscribedSkus = Invoke-ZtGraphRequest `
            -RelativeUri 'subscribedSkus' `
            -ApiVersion beta
    }
    catch {
        $skuCmdletFailed = $true
        Write-PSFMessage "Failed to retrieve subscribed SKUs: $_" -Tag Test -Level Warning
    }

    Write-ZtProgress -Activity $activity -Status 'Querying user license assignments'

    # Query 2: Retrieve all users with assigned licenses
    try {
        $allUsers = Invoke-ZtGraphRequest `
            -RelativeUri 'users?$select=id,displayName,userPrincipalName,assignedLicenses&$count=true' `
            -ApiVersion beta
    }
    catch {
        $userCmdletFailed = $true
        Write-PSFMessage "Failed to retrieve users: $_" -Tag Test -Level Warning
    }
    #endregion Data Collection

    #region Assessment Logic
    $testResultMarkdown = ''
    $passed = $false

    # Handle any query failure - cannot determine license status
    if ($skuCmdletFailed -or $userCmdletFailed) {
        Write-PSFMessage "Failed to retrieve GSA license data" -Tag Test -Level Error
        Add-ZtTestResultDetail -SkippedBecause NotApplicable -Result 'Failed to retrieve GSA license data from Microsoft Graph.'
        return
    }

    # Filter SKUs containing GSA service plans
    $gsaSkus = @($subscribedSkus | Where-Object {
        $sku = $_
        $sku.ServicePlans | Where-Object { $_.ServicePlanId -in $gsaServicePlanIds.Values }
    })

    # Check if GSA licenses exist and are enabled
    $enabledGsaSkus = @($gsaSkus | Where-Object { $_.CapabilityStatus -eq 'Enabled' })

    if ($gsaSkus.Count -eq 0 -or $enabledGsaSkus.Count -eq 0) {
        # No GSA licenses available or not enabled - skip test
        Write-PSFMessage 'No GSA licenses are available in this tenant.' -Tag Test -Level Verbose
        Add-ZtTestResultDetail -SkippedBecause NotApplicable -Result 'No GSA licenses are available in this tenant.'
        return
    }

    Write-ZtProgress -Activity $activity -Status 'Analyzing user license assignments'

    # Build SKU ID to SKU mapping for user license cross-reference
    $gsaSkuIds = @{}
    foreach ($sku in $enabledGsaSkus) {
        $gsaSkuIds[$sku.SkuId] = $sku
    }

    # Pre-filter GSA service plans for performance
    $internetAccessPlansBySkuId = @{}
    $privateAccessPlansBySkuId = @{}
    foreach ($sku in $enabledGsaSkus) {
        $internetPlan = $sku.ServicePlans | Where-Object { $_.ServicePlanId -eq $gsaServicePlanIds.InternetAccess }
        if ($internetPlan) {
            $internetAccessPlansBySkuId[$sku.SkuId] = $internetPlan
        }
        $privatePlan = $sku.ServicePlans | Where-Object { $_.ServicePlanId -eq $gsaServicePlanIds.PrivateAccess }
        if ($privatePlan) {
            $privateAccessPlansBySkuId[$sku.SkuId] = $privatePlan
        }
    }

    # Count users with GSA licenses assigned
    $usersWithInternetAccess = [System.Collections.Generic.List[object]]::new()
    $usersWithPrivateAccess = [System.Collections.Generic.List[object]]::new()
    $usersWithAnyGsa = [System.Collections.Generic.List[object]]::new()

    foreach ($user in $allUsers) {
        if (-not $user.AssignedLicenses -or $user.AssignedLicenses.Count -eq 0) {
            continue
        }

        $hasInternetAccess = $false
        $hasPrivateAccess = $false

        foreach ($license in $user.AssignedLicenses) {
            if ($gsaSkuIds.ContainsKey($license.SkuId)) {
                # Defensive: treat null disabledPlans as empty array
                $disabledPlans = if ($license.DisabledPlans) { $license.DisabledPlans } else { @() }

                # Check if Internet Access is enabled
                if ($internetAccessPlansBySkuId.ContainsKey($license.SkuId)) {
                    $internetAccessPlan = $internetAccessPlansBySkuId[$license.SkuId]
                    if ($internetAccessPlan.ServicePlanId -notin $disabledPlans) {
                        $hasInternetAccess = $true
                    }
                }

                # Check if Private Access is enabled
                if ($privateAccessPlansBySkuId.ContainsKey($license.SkuId)) {
                    $privateAccessPlan = $privateAccessPlansBySkuId[$license.SkuId]
                    if ($privateAccessPlan.ServicePlanId -notin $disabledPlans) {
                        $hasPrivateAccess = $true
                    }
                }
            }
        }

        if ($hasInternetAccess) {
            $usersWithInternetAccess.Add($user)
        }
        if ($hasPrivateAccess) {
            $usersWithPrivateAccess.Add($user)
        }
        if ($hasInternetAccess -or $hasPrivateAccess) {
            $usersWithAnyGsa.Add($user)
        }
    }

    $gsaUserCount = $usersWithAnyGsa.Count

    # Evaluate test result
    if ($gsaUserCount -eq 0) {
        # Licenses exist and enabled but not assigned to any user - fail
        $passed = $false
        $testResultMarkdown = "❌ GSA licenses are available in the tenant but not assigned to any user.`n`n%TestResult%"
    }
    else {
        # Licenses exist, enabled, and assigned to at least one user - pass
        $passed = $true
        $testResultMarkdown = "✅ GSA licenses are available and assigned to at least one user.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    # Build detailed information if we have valid license data
    $mdInfo = ''

    if ($null -ne $enabledGsaSkus -and $enabledGsaSkus.Count -gt 0) {
        $reportTitle = 'Licenses'
        $portalLink = 'https://admin.microsoft.com/Adminportal/Home#/licenses'

        $formatTemplate = @'

## [{0}]({1})

**GSA License Summary:**

| SKU Name | Status | Available | Assigned |
| :------- | :----- | --------: | -------: |
{2}

**GSA Service Plans Detected:**

| Service Plan | SKU |
| :----------- | :-- |
{3}

**User Assignment Summary:**

| Metric | Value |
| :----- | ----: |
{4}

{5}
'@

        # Build SKU table
        $skuTableRows = ''
        foreach ($sku in $enabledGsaSkus) {
            $skuName = Get-SafeMarkdown -Text $sku.SkuPartNumber
            $status = Get-SafeMarkdown -Text $sku.CapabilityStatus
            $available = $sku.PrepaidUnits.Enabled
            $assigned = $sku.ConsumedUnits

            $skuTableRows += "| $skuName | $status | $available | $assigned |`n"
        }

        # Build service plan table
        $servicePlanTableRows = ''
        foreach ($sku in $enabledGsaSkus) {
            $gsaPlans = $sku.ServicePlans | Where-Object { $_.ServicePlanId -in $gsaServicePlanIds.Values }
            foreach ($plan in $gsaPlans) {
                $planName = Get-SafeMarkdown -Text $plan.ServicePlanName
                $skuName = Get-SafeMarkdown -Text $sku.SkuPartNumber

                $servicePlanTableRows += "| $planName | $skuName |`n"
            }
        }

        # Build user assignment summary
        $assignmentSummary = "| Users with GSA Internet Access | $($usersWithInternetAccess.Count) |`n"
        $assignmentSummary += "| Users with GSA Private Access | $($usersWithPrivateAccess.Count) |`n"
        $assignmentSummary += "| Total users with any GSA license | $gsaUserCount |`n"

        # Build user list (truncate at 10)
        $userListSection = ''
        if ($gsaUserCount -gt 0) {
            if ($gsaUserCount -gt 10) {
                $userListSection += "**Users with GSA licenses (Showing 10 of $gsaUserCount):**`n`n"
            }
            else {
                $userListSection += "**Users with GSA licenses:**`n`n"
            }

            $userListSection += "| Display name | User principal name | Internet Access | Private Access |`n"
            $userListSection += "| :----------- | :------------------ | :-------------- | :------------- |`n"

            # Build HashSets for efficient ID lookups
            $internetAccessIds = [System.Collections.Generic.HashSet[string]]::new([string[]]($usersWithInternetAccess.Id))
            $privateAccessIds = [System.Collections.Generic.HashSet[string]]::new([string[]]($usersWithPrivateAccess.Id))

            $displayUsers = $usersWithAnyGsa | Select-Object -First 10
            foreach ($user in $displayUsers) {
                $displayName = Get-SafeMarkdown -Text $user.DisplayName
                $upn = Get-SafeMarkdown -Text $user.UserPrincipalName
                $hasInternet = if ($internetAccessIds.Contains($user.Id)) { '✅' } else { '❌' }
                $hasPrivate = if ($privateAccessIds.Contains($user.Id)) { '✅' } else { '❌' }

                $userListSection += "| $displayName | $upn | $hasInternet | $hasPrivate |`n"
            }

            if ($gsaUserCount -gt 10) {
                $userListSection += "| ... | | | |`n`n"
                $userListSection += "View all users in [Microsoft 365 admin center - Licenses](https://admin.microsoft.com/Adminportal/Home#/licenses)"
            }
        }

        $mdInfo = $formatTemplate -f $reportTitle, $portalLink, $skuTableRows, $servicePlanTableRows, $assignmentSummary, $userListSection
    }

    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '25375'
        Title  = 'GSA Licenses are available in the tenant and assigned to users'
        Status = $passed
        Result = $testResultMarkdown
    }
    Add-ZtTestResultDetail @params
}
