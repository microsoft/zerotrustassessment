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
        Title = 'GSA Licenses are available in the Tenant and assigned to users',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking GSA license availability and assignment'
    Write-ZtProgress -Activity $activity -Status 'Querying tenant licenses'

    # GSA Service Plan IDs
    $gsaServicePlanIds = @(
        '8d23cb83-ab07-418f-8517-d7aca77307dc', # Entra_Premium_Internet_Access
        'f057aab1-b184-49b2-85c0-881b02a405c5'  # Entra_Premium_Private_Access
    )

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
    $customStatus = $null

    # Handle any query failure - cannot determine license status
    if ($skuCmdletFailed -or $userCmdletFailed) {
        $testResultMarkdown = "⚠️ Unable to determine GSA license status.`n`n%TestResult%"
        $customStatus = 'Skipped'
    }
    # Filter SKUs containing GSA service plans
    elseif ($null -ne $subscribedSkus) {
        $gsaSkus = $subscribedSkus | Where-Object {
            $sku = $_
            $sku.ServicePlans | Where-Object { $_.ServicePlanId -in $gsaServicePlanIds }
        }

        # Check if GSA licenses exist and are enabled
        $enabledGsaSkus = $gsaSkus | Where-Object { $_.CapabilityStatus -eq 'Enabled' }

        if ($gsaSkus.Count -eq 0 -or $enabledGsaSkus.Count -eq 0) {
            $testResultMarkdown = "❌ GSA licenses are not available or not assigned to users in the tenant.`n`n%TestResult%"
        }
        else {
            Write-ZtProgress -Activity $activity -Status 'Analyzing user license assignments'

            # Build SKU ID to SKU mapping for user license cross-reference
            $gsaSkuIds = @{}
            foreach ($sku in $enabledGsaSkus) {
                $gsaSkuIds[$sku.SkuId] = $sku
            }

            # Count users with GSA licenses assigned
            $usersWithInternetAccess = @()
            $usersWithPrivateAccess = @()
            $usersWithAnyGsa = @()

            foreach ($user in $allUsers) {
                if (-not $user.AssignedLicenses -or $user.AssignedLicenses.Count -eq 0) {
                    continue
                }

                $hasInternetAccess = $false
                $hasPrivateAccess = $false

                foreach ($license in $user.AssignedLicenses) {
                    if ($gsaSkuIds.ContainsKey($license.SkuId)) {
                        $sku = $gsaSkuIds[$license.SkuId]
                        $disabledPlans = $license.DisabledPlans

                        # Check if Internet Access is enabled
                        $internetAccessPlan = $sku.ServicePlans | Where-Object { $_.ServicePlanId -eq '8d23cb83-ab07-418f-8517-d7aca77307dc' }
                        if ($internetAccessPlan -and $internetAccessPlan.ServicePlanId -notin $disabledPlans) {
                            $hasInternetAccess = $true
                        }

                        # Check if Private Access is enabled
                        $privateAccessPlan = $sku.ServicePlans | Where-Object { $_.ServicePlanId -eq 'f057aab1-b184-49b2-85c0-881b02a405c5' }
                        if ($privateAccessPlan -and $privateAccessPlan.ServicePlanId -notin $disabledPlans) {
                            $hasPrivateAccess = $true
                        }
                    }
                }

                if ($hasInternetAccess) {
                    $usersWithInternetAccess += $user
                }
                if ($hasPrivateAccess) {
                    $usersWithPrivateAccess += $user
                }
                if ($hasInternetAccess -or $hasPrivateAccess) {
                    $usersWithAnyGsa += $user
                }
            }

            $gsaUserCount = $usersWithAnyGsa.Count

            # Evaluate test result
            if ($gsaUserCount -eq 0) {
                $passed = $false
                $testResultMarkdown = "❌ GSA licenses are not available or not assigned to users in the tenant.`n`n%TestResult%"
            }
            else {
                $passed = $true
                $testResultMarkdown = "✅ GSA licenses are available in the tenant and assigned to users.`n`n%TestResult%"
            }
        }
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

**GSA license summary:**

| Sku name | Status | Available | Assigned |
| :------- | :----- | --------: | -------: |
{2}

**GSA service plans detected:**

| Service plan | Sku |
| :----------- | :-- |
{3}

**User assignment summary:**

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
            $gsaPlans = $sku.ServicePlans | Where-Object { $_.ServicePlanId -in $gsaServicePlanIds }
            foreach ($plan in $gsaPlans) {
                $planName = Get-SafeMarkdown -Text $plan.ServicePlanName
                $skuName = Get-SafeMarkdown -Text $sku.SkuPartNumber

                $servicePlanTableRows += "| $planName | $skuName |`n"
            }
        }

        # Build user assignment summary
        $assignmentSummary = "| Users with GSA internet access | $($usersWithInternetAccess.Count) |`n"
        $assignmentSummary += "| Users with GSA private access | $($usersWithPrivateAccess.Count) |`n"
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

            $userListSection += "| Display name | User principal name | Internet access | Private access |`n"
            $userListSection += "| :----------- | :------------------ | :-------------- | :------------- |`n"

            $displayUsers = $usersWithAnyGsa | Select-Object -First 10
            foreach ($user in $displayUsers) {
                $displayName = Get-SafeMarkdown -Text $user.DisplayName
                $upn = Get-SafeMarkdown -Text $user.UserPrincipalName
                $hasInternet = if ($user.Id -in $usersWithInternetAccess.Id) { '✅' } else { '❌' }
                $hasPrivate = if ($user.Id -in $usersWithPrivateAccess.Id) { '✅' } else { '❌' }

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
        Title  = 'GSA Licenses are available in the Tenant and assigned to users'
        Status = $passed
        Result = $testResultMarkdown
    }
    if ($customStatus) {
        $params.CustomStatus = $customStatus
    }
    Add-ZtTestResultDetail @params
}
