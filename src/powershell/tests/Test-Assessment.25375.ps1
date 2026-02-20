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
    Required API: subscribedSkus (beta)
    Required Database: User table
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
    param(
        $Database
    )

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
    $userLicenses = @()

    # Query 1: Retrieve tenant licenses with GSA service plans
    try {
        $subscribedSkus = Invoke-ZtGraphRequest -RelativeUri 'subscribedSkus' -ApiVersion beta -ErrorAction Stop
    }
    catch {
        $skuCmdletFailed = $true
        Write-PSFMessage "Failed to retrieve subscribed SKUs: $_" -Tag Test -Level Warning
    }

    Write-ZtProgress -Activity $activity -Status 'Querying user license assignments'

    # Query 2: Retrieve all users with assigned licenses from database
    try {
        $sqlUsers = @"
SELECT
    u.id,
    u.displayName,
    u.userPrincipalName,
    unnest(u.assignedLicenses).skuId::VARCHAR AS skuId,
    unnest(u.assignedLicenses).disabledPlans AS disabledPlans
FROM "User" u
WHERE len(u.assignedLicenses) > 0
"@
        $userLicenses = @(Invoke-DatabaseQuery -Database $Database -Sql $sqlUsers -AsCustomObject -ErrorAction Stop)
        # Filter out any records with null IDs
        $userLicenses = @($userLicenses | Where-Object { $_.id })
    }
    catch {
        $userCmdletFailed = $true
        Write-PSFMessage "Failed to retrieve users: $_" -Tag Test -Level Warning
    }
    #endregion Data Collection

    #region Assessment Logic
    $testResultMarkdown = ''
    $passed = $false
    $customStatus = $null

    # Handle any query failure - cannot determine license status
    if ($skuCmdletFailed -or $userCmdletFailed) {
        Write-PSFMessage "Unable to retrieve GSA license data due to query failure" -Tag Test -Level Warning
        $customStatus = 'Investigate'
        $testResultMarkdown = "⚠️ Unable to determine GSA license availability and assignment due to query failure, connection issues, or insufficient permissions.`n`n"

        Add-ZtTestResultDetail -TestId '25375' -Title 'GSA Licenses are available in the tenant and assigned to users' -Status $false -Result $testResultMarkdown -CustomStatus $customStatus
        return
    }

    # Filter SKUs containing GSA service plans
    $gsaSkus = @($subscribedSkus | Where-Object {
        $_.ServicePlans | Where-Object { $_.ServicePlanId -in $gsaServicePlanIds.Values }
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

    # Build SKU ID to SKU mapping and pre-filter service plans for performance
    $gsaSkuIds = @{}
    $internetAccessPlansBySku = @{}
    $privateAccessPlansBySku = @{}

    foreach ($sku in $enabledGsaSkus) {
        $skuIdString = $sku.SkuId.ToString().ToLower()
        $gsaSkuIds[$skuIdString] = $sku

        # Pre-filter service plans to avoid repeated Where-Object calls
        $internetPlan = $sku.ServicePlans | Where-Object { $_.ServicePlanId -eq $gsaServicePlanIds.InternetAccess }
        if ($internetPlan) {
            $internetAccessPlansBySku[$skuIdString] = $internetPlan
        }

        $privatePlan = $sku.ServicePlans | Where-Object { $_.ServicePlanId -eq $gsaServicePlanIds.PrivateAccess }
        if ($privatePlan) {
            $privateAccessPlansBySku[$skuIdString] = $privatePlan
        }
    }

    # Count users with GSA licenses assigned
    $usersWithInternetAccess = [System.Collections.Generic.List[object]]::new()
    $usersWithPrivateAccess = [System.Collections.Generic.List[object]]::new()
    $usersWithAnyGsa = [System.Collections.Generic.List[object]]::new()

    # Group licenses by user (since query returns one row per license)
    $userGroups = $userLicenses | Group-Object -Property id

    foreach ($userGroup in $userGroups) {
        $userId = $userGroup.Name
        $userLicenseRecords = $userGroup.Group
        $userDisplayName = $userLicenseRecords[0].displayName
        $userPrincipalName = $userLicenseRecords[0].userPrincipalName

        $hasInternetAccess = $false
        $hasPrivateAccess = $false

        foreach ($licenseRecord in $userLicenseRecords) {
            if (-not $licenseRecord.skuId) { continue }

            $userSkuId = $licenseRecord.skuId.ToString().ToLower()

            if ($gsaSkuIds.ContainsKey($userSkuId)) {
                $disabledPlans = if ($licenseRecord.disabledPlans) { $licenseRecord.disabledPlans } else { @() }

                # Check if Internet Access service plan is enabled
                if ($internetAccessPlansBySku.ContainsKey($userSkuId)) {
                    $internetPlan = $internetAccessPlansBySku[$userSkuId]
                    if ($internetPlan.ServicePlanId -notin $disabledPlans) {
                        $hasInternetAccess = $true
                    }
                }

                # Check if Private Access service plan is enabled
                if ($privateAccessPlansBySku.ContainsKey($userSkuId)) {
                    $privatePlan = $privateAccessPlansBySku[$userSkuId]
                    if ($privatePlan.ServicePlanId -notin $disabledPlans) {
                        $hasPrivateAccess = $true
                    }
                }
            }
        }

        # Create user object for display
        $userObj = [PSCustomObject]@{
            Id = $userId
            DisplayName = $userDisplayName
            UserPrincipalName = $userPrincipalName
        }

        if ($hasInternetAccess) {
            $usersWithInternetAccess.Add($userObj)
        }
        if ($hasPrivateAccess) {
            $usersWithPrivateAccess.Add($userObj)
        }
        if ($hasInternetAccess -or $hasPrivateAccess) {
            $usersWithAnyGsa.Add($userObj)
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
            if ($usersWithInternetAccess.Count -gt 0) {
                $internetAccessIds = [System.Collections.Generic.HashSet[string]]::new([string[]]($usersWithInternetAccess.Id))
            } else {
                $internetAccessIds = [System.Collections.Generic.HashSet[string]]::new()
            }

            if ($usersWithPrivateAccess.Count -gt 0) {
                $privateAccessIds = [System.Collections.Generic.HashSet[string]]::new([string[]]($usersWithPrivateAccess.Id))
            } else {
                $privateAccessIds = [System.Collections.Generic.HashSet[string]]::new()
            }

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
    if ($customStatus) {
        $params.CustomStatus = $customStatus
    }
    Add-ZtTestResultDetail @params
}
