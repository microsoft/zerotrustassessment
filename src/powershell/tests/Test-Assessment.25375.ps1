using module '..\Classes\TestDefinition.psm1'
using module '..\Classes\TestResult.psm1'

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
        GSA Service Plan IDs:
        - Entra_Premium_Internet_Access: 8d23cb83-ab07-418f-8517-d7aca77307dc
        - Entra_Premium_Private_Access: f057aab1-b184-49b2-85c0-881b02a405c5
#>

[TestDefinition]@{
    TestId      = '25375'
    Category    = 'Network'
    TestName    = 'Test-GSALicensesAvailableAndAssigned'
    Description = 'Validates that GSA licenses are available in the tenant and assigned to users'
    MinimumLicense = 'Entra_Premium_Internet_Access, Entra_Premium_Private_Access'
    SupportedClouds = @('Global')
    Result      = {
        [TestResult]@{
            TestId  = '25375'
            Tenant  = $env:TenantName
            Status  = $null
            Summary = $null
            Details = $null
            Data    = $null
            Params  = $params
        }
    }
    TestScript  = {
        param($params)

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
            $subscribedSkus = Get-MgSubscribedSku -ErrorAction Stop
        }
        catch {
            $skuCmdletFailed = $true
        }

        # Query 2: Retrieve all users with assigned licenses
        try {
            $allUsers = Get-MgUser -All -Property id,displayName,userPrincipalName,assignedLicenses -ErrorAction Stop
        }
        catch {
            $userCmdletFailed = $true
        }

        # Handle complete failure
        if ($skuCmdletFailed -and $userCmdletFailed) {
            return [TestResult]@{
                TestId  = '25375'
                Tenant  = $env:TenantName
                Status  = 'Skipped'
                Summary = 'Unable to retrieve GSA license and user data'
                Details = "⚠️ Unable to retrieve subscribedSkus and users due to query failure, connection issues, or insufficient permissions."
                Data    = $null
                Params  = $params
            }
        }

        # Handle partial failure - SKU query failed
        if ($skuCmdletFailed) {
            return [TestResult]@{
                TestId  = '25375'
                Tenant  = $env:TenantName
                Status  = 'Skipped'
                Summary = 'Unable to retrieve GSA license data'
                Details = "⚠️ Unable to retrieve subscribedSkus due to query failure, connection issues, or insufficient permissions."
                Data    = $null
                Params  = $params
            }
        }

        # Handle partial failure - User query failed (but we can still check if licenses exist)
        if ($userCmdletFailed) {
            # Check if GSA licenses exist
            $gsaSkus = $subscribedSkus | Where-Object {
                $sku = $_
                $sku.ServicePlans | Where-Object { $_.ServicePlanId -in $gsaServicePlanIds }
            }

            if ($gsaSkus.Count -eq 0) {
                return [TestResult]@{
                    TestId  = '25375'
                    Tenant  = $env:TenantName
                    Status  = 'Fail'
                    Summary = 'GSA licenses are not available in the tenant'
                    Details = "No subscribed SKUs contain GSA service plans (Entra Premium Internet Access or Entra Premium Private Access)."
                    Data    = $null
                    Params  = $params
                }
            }

            return [TestResult]@{
                TestId  = '25375'
                Tenant  = $env:TenantName
                Status  = 'Skipped'
                Summary = 'Unable to retrieve user assignment data'
                Details = "⚠️ GSA licenses exist in tenant but unable to retrieve users due to query failure, connection issues, or insufficient permissions."
                Data    = $null
                Params  = $params
            }
        }

        # Filter SKUs containing GSA service plans
        $gsaSkus = $subscribedSkus | Where-Object {
            $sku = $_
            $sku.ServicePlans | Where-Object { $_.ServicePlanId -in $gsaServicePlanIds }
        }

        # Check if GSA licenses exist in tenant
        if ($gsaSkus.Count -eq 0) {
            return [TestResult]@{
                TestId  = '25375'
                Tenant  = $env:TenantName
                Status  = 'Fail'
                Summary = 'GSA licenses are not available in the tenant'
                Details = "No subscribed SKUs contain GSA service plans (Entra Premium Internet Access or Entra Premium Private Access).`n`nPurchase GSA licenses: https://learn.microsoft.com/en-us/entra/global-secure-access/overview-what-is-global-secure-access#licensing-overview"
                Data    = $null
                Params  = $params
            }
        }

        # Check if any GSA licenses are enabled
        $enabledGsaSkus = $gsaSkus | Where-Object { $_.CapabilityStatus -eq 'Enabled' }
        if ($enabledGsaSkus.Count -eq 0) {
            return [TestResult]@{
                TestId  = '25375'
                Tenant  = $env:TenantName
                Status  = 'Fail'
                Summary = 'GSA licenses are not enabled in the tenant'
                Details = "GSA licenses exist but all have capabilityStatus other than 'Enabled' (e.g., Warning, Suspended, Deleted, LockedOut).`n`nReview license status: https://admin.microsoft.com/Adminportal/Home#/licenses"
                Data    = $null
                Params  = $params
            }
        }

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
            return [TestResult]@{
                TestId  = '25375'
                Tenant  = $env:TenantName
                Status  = 'Fail'
                Summary = 'GSA licenses exist but are not assigned to any users'
                Details = "GSA licenses are available and enabled in the tenant, but no users have GSA service plans assigned.`n`nAssign licenses to users: https://learn.microsoft.com/en-us/entra/fundamentals/license-users-groups"
                Data    = $null
                Params  = $params
            }
        }

        # Build report data
        $report = @()
        
        # GSA License Summary
        $report += "## [Licenses](https://admin.microsoft.com/Adminportal/Home#/licenses)"
        $report += ""
        $report += "**GSA License Summary:**"
        $report += ""

        $skuTableRows = @()
        foreach ($sku in $enabledGsaSkus) {
            $skuName = Get-SafeMarkdown -Text $sku.SkuPartNumber
            $status = Get-SafeMarkdown -Text $sku.CapabilityStatus
            $available = $sku.PrepaidUnits.Enabled
            $assigned = $sku.ConsumedUnits
            
            $skuTableRows += [PSCustomObject]@{
                SkuName   = $skuName
                Status    = $status
                Available = $available
                Assigned  = $assigned
            }
        }

        $report += "| SKU Name | Status | Available | Assigned |"
        $report += "| --- | --- | --- | --- |"
        foreach ($row in $skuTableRows) {
            $report += "| $($row.SkuName) | $($row.Status) | $($row.Available) | $($row.Assigned) |"
        }
        $report += ""

        # GSA Service Plans Detected
        $report += "**GSA Service Plans Detected:**"
        $report += ""

        $servicePlanTableRows = @()
        foreach ($sku in $enabledGsaSkus) {
            $gsaPlans = $sku.ServicePlans | Where-Object { $_.ServicePlanId -in $gsaServicePlanIds }
            foreach ($plan in $gsaPlans) {
                $planName = Get-SafeMarkdown -Text $plan.ServicePlanName
                $skuName = Get-SafeMarkdown -Text $sku.SkuPartNumber
                
                $servicePlanTableRows += [PSCustomObject]@{
                    ServicePlan = $planName
                    Sku         = $skuName
                }
            }
        }

        $report += "| Service Plan | SKU |"
        $report += "| --- | --- |"
        foreach ($row in $servicePlanTableRows) {
            $report += "| $($row.ServicePlan) | $($row.Sku) |"
        }
        $report += ""

        # User Assignment Summary
        $report += "**User Assignment Summary:**"
        $report += ""
        $report += "| Metric | Value |"
        $report += "| --- | --- |"
        $report += "| Users with GSA Internet Access | $($usersWithInternetAccess.Count) |"
        $report += "| Users with GSA Private Access | $($usersWithPrivateAccess.Count) |"
        $report += "| Total Users with Any GSA License | $gsaUserCount |"
        $report += ""

        # User list (truncate at 10)
        if ($gsaUserCount -gt 0) {
            $report += "**Users with GSA Licenses:**"
            $report += ""
            
            if ($gsaUserCount -gt 10) {
                $report += "Showing 10 of $gsaUserCount users."
                $report += ""
            }

            $report += "| Display Name | User Principal Name | Internet Access | Private Access |"
            $report += "| --- | --- | --- | --- |"
            
            $displayUsers = $usersWithAnyGsa | Select-Object -First 10
            foreach ($user in $displayUsers) {
                $displayName = Get-SafeMarkdown -Text $user.DisplayName
                $upn = Get-SafeMarkdown -Text $user.UserPrincipalName
                $hasInternet = if ($user.Id -in $usersWithInternetAccess.Id) { "✅" } else { "❌" }
                $hasPrivate = if ($user.Id -in $usersWithPrivateAccess.Id) { "✅" } else { "❌" }
                
                $report += "| $displayName | $upn | $hasInternet | $hasPrivate |"
            }
            
            if ($gsaUserCount -gt 10) {
                $report += "| ... | | | |"
            }
        }

        [TestResult]@{
            TestId  = '25375'
            Tenant  = $env:TenantName
            Status  = 'Pass'
            Summary = 'GSA licenses are available and assigned to users'
            Details = "✅ GSA licenses are provisioned in the tenant with enabled status and assigned to $gsaUserCount user(s)."
            Data    = ($report -join "`n")
            Params  = $params
        }
    }
}
