    <#
.SYNOPSIS
    Test to check if outbound traffic from VNET integrated workloads is routed through Azure Firewall

.NOTES
    Some Azure Firewall documentation links may return 404 errors.
    This test uses the Azure REST API version 2025-03-01.
#>

function Test-Assessment-25535 {
    [ZtTest(
        Category = 'Azure Network Security',
        ImplementationCost = 'Medium',
        MinimumLicense = ('Azure_Firewall_Basic', 'Azure_Firewall_Standard', 'Azure_Firewall_Premium'),
        Pillar = 'Network',
        RiskLevel = 'High',
        SfiPillar = 'Protect networks',
        TenantType = ('Workforce', 'External'),
        TestId = 25535,
        Title = 'Outbound traffic from VNET integrated workloads is routed through Azure Firewall',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Helper Functions
    function Get-FirewallPrivateIP {
        param([string]$SubscriptionId)

        $firewalls = @()
        $fwListUri = "/subscriptions/$SubscriptionId/providers/Microsoft.Network/azureFirewalls?api-version=2025-03-01"

        try {
            $fwResp = Invoke-AzRestMethod -Path $fwListUri -Method GET
            $fwItems = ($fwResp.Content | ConvertFrom-Json).value
        }
        catch {
            Write-PSFMessage "Unable to list Azure Firewalls in subscription $SubscriptionId." -Tag Test -Level Warning
            return $firewalls
        }

        foreach ($fw in $fwItems) {
            try {
                $fwDetailResp = Invoke-AzRestMethod -Path "$($fw.id)?api-version=2025-03-01" -Method GET
                $fwDetail = $fwDetailResp.Content | ConvertFrom-Json

                foreach ($ipconfig in $fwDetail.properties.ipConfigurations) {
                    if ($ipconfig.properties.privateIPAddress) {
                        $firewalls += [PSCustomObject]@{
                            FirewallName   = $fwDetail.name
                            FirewallId     = $fwDetail.id
                            PrivateIP      = $ipconfig.properties.privateIPAddress
                            SubscriptionId = $SubscriptionId
                        }
                    }
                }
            }
            catch { # Firewall exists but details could not be read (RBAC or transient issue).
                # Skipping is intentional to avoid failing the whole test.
            }
        }

        return $firewalls
    }

     function Get-WorkloadNicOperation {
        param(
            [object]$Subscription,
            [string]$SubscriptionId
        )

        $asyncOperations = @()
        $nicListUri = "/subscriptions/$SubscriptionId/providers/Microsoft.Network/networkInterfaces?api-version=2025-03-01"

        try {
            # Azure REST list APIs are paginated.
            # Handling nextLink is required to avoid missing NICs in large subscriptions.
            $nics = @()
            $nicResp = Invoke-AzRestMethod -Path $nicListUri -Method GET
            $nicPage = $nicResp.Content | ConvertFrom-Json

            if ($nicPage.value) {
                $nics += $nicPage.value
            }

            $nextLink = $nicPage.nextLink
            while ($nextLink) {
                $nicResp = Invoke-AzRestMethod -Uri $nextLink -Method GET
                $nicPage = $nicResp.Content | ConvertFrom-Json
                if ($nicPage.value) {
                    $nics += $nicPage.value
                }
                $nextLink = $nicPage.nextLink
            }
        }
        catch {
            Write-PSFMessage "Unable to list network interfaces in subscription $($Subscription.Name)." -Tag Test -Level Warning
            return $asyncOperations
        }

        foreach ($nic in $nics) {
            foreach ($ipconfig in $nic.properties.ipConfigurations) {
                $subnetId = $ipconfig.properties.subnet?.id
                if (-not $subnetId) { continue }

                if ($subnetId -match 'AzureFirewallSubnet|GatewaySubnet|AzureBastionSubnet') {
                    continue
                }

                $rg = ($nic.id -split '/')[4]
                $ertUri = "/subscriptions/$SubscriptionId/resourceGroups/$rg/providers/Microsoft.Network/networkInterfaces/$($nic.name)/effectiveRouteTable?api-version=2025-03-01"

                try {
                    $ertStart = Invoke-AzRestMethod -Path $ertUri -Method POST
                    $retryAfter = if ($ertStart.Headers.'Retry-After') {
                        [int]$ertStart.Headers.'Retry-After'[0]
                    } else {
                        5
                    }

                    # effectiveRouteTable is a documented async ARM operation.
                    # It returns 202 with a Location header.
                    # No defensive null-check is added so unexpected API behavior is visible.
                    $asyncOperations += @{
                        OperationUri     = $ertStart.Headers.Location[0]
                        Nic              = $nic
                        RetryAfter       = $retryAfter
                        SubnetId         = $subnetId
                        SubscriptionId   = $Subscription.Id
                        SubscriptionName = $Subscription.Name
                    }
                }
                catch {
                    Write-PSFMessage "Failed to initiate effectiveRouteTable request for NIC $($nic.name): $($_.Exception.Message)" -Tag Test -Level Warning
                }
            }
        }
        return $asyncOperations
    }

    function Wait-AsyncOperation {
        param([array]$Operations)

        $completedOperations = @()
        $pendingOperations = $Operations
        $maxRetries = 120  # ~10 minutes with 5 second intervals

        while ($pendingOperations.Count -gt 0) {
            $stillPending = @()

            foreach ($op in $pendingOperations) {
                try {
                    $ertPoll = Invoke-AzRestMethod -Uri $op.OperationUri -Method GET
                    # The effectiveRouteTable async API returns 202 while in progress.
                    # Any non-202 response indicates the operation has completed.
                    # This logic is intentionally kept simple and unchanged.
                    if ($ertPoll.StatusCode -ne 202) {
                        $op.Routes = ($ertPoll.Content | ConvertFrom-Json).value
                        $op.Completed = $true
                        $completedOperations += $op
                    } else {
                        $stillPending += $op
                    }
                }
                catch {
                    Write-PSFMessage "Error polling operation for NIC $($op.Nic.name): $($_.Exception.Message)" -Tag Test -Level Warning
                    $op.Completed = $true
                    $op.Error = $true
                    $completedOperations += $op
                }
            }

            $pendingOperations = $stillPending
            if ($pendingOperations.Count -eq 0) { break }

            $maxRetries--
            if ($maxRetries -le 0) {
                Write-PSFMessage "Timeout polling effectiveRouteTable operations. Processing $($pendingOperations.Count) incomplete operations." -Tag Test -Level Warning
                $completedOperations += $pendingOperations
                break
            }

            Write-PSFMessage "Polling $($pendingOperations.Count) pending operations..." -Tag Test -Level Verbose
            Start-Sleep -Seconds ($pendingOperations[0].RetryAfter)
        }
        return $completedOperations
    }

    function ConvertTo-NicFinding {
        param(
            [object]$Operation,
            [array]$Firewalls
        )

        # Handle error or missing routes
        if ($Operation.Error -or -not $Operation.Routes) {
            return [PSCustomObject]@{
                NicName           = $Operation.Nic.name
                NicId             = $Operation.Nic.id
                NextHopType       = 'Unknown'
                NextHopIpAddress  = ''
                IsCompliant       = $false
                SubscriptionId    = $Operation.SubscriptionId
                SubscriptionName  = $Operation.SubscriptionName
                SubnetId          = $Operation.SubnetId
                FirewallPrivateIp = 'N/A'
            }
        }
        # addressPrefix can be returned as string or array.
        # Both checks are kept intentionally to support both shapes.
        # Find user-defined default route
        $defaultRoute = $Operation.Routes | Where-Object {
            $_.state -eq 'Active' -and
            $_.source -eq 'User' -and
            $_.nextHopType -eq 'VirtualAppliance' -and
            (($_.addressPrefix -contains '0.0.0.0/0') -or ($_.addressPrefix -eq '0.0.0.0/0'))
        } | Select-Object -First 1

        if (-not $defaultRoute) {
            return [PSCustomObject]@{
                NicName           = $Operation.Nic.name
                NicId             = $Operation.Nic.id
                NextHopType       = 'Internet'
                NextHopIpAddress  = ''
                IsCompliant       = $false
                SubscriptionId    = $Operation.SubscriptionId
                SubscriptionName  = $Operation.SubscriptionName
                SubnetId          = $Operation.SubnetId
                FirewallPrivateIp = 'N/A'
            }
        }

        # Match next hop to firewall private IP
        $nextHop = $defaultRoute.nextHopIpAddress
        # This logic is intentionally NOT changed.
        # nextHopIpAddress may be string or array.
        # Using both -eq and -contains keeps backward compatibility
        # and avoids forcing assumptions about the API response type.
        $fwMatch = $Firewalls | Where-Object {
            ($nextHop -eq $_.PrivateIP) -or ($nextHop -contains $_.PrivateIP)
        } | Select-Object -First 1

        return [PSCustomObject]@{
            FirewallName      = if ($fwMatch) { $fwMatch.FirewallName } else { 'N/A' }
            FirewallId        = if ($fwMatch) { $fwMatch.FirewallId } else { 'N/A' }
            FirewallPrivateIp = if ($fwMatch) { $fwMatch.PrivateIP } else { 'N/A' }
            NicName           = $Operation.Nic.name
            NicId             = $Operation.Nic.id
            RouteSource       = $defaultRoute.source
            RouteState        = $defaultRoute.state
            AddressPrefix     = ($defaultRoute.addressPrefix -join ',')
            NextHopType       = $defaultRoute.nextHopType
            NextHopIpAddress  = ($defaultRoute.nextHopIpAddress -join ',')
            IsCompliant       = ($null -ne $fwMatch)
            SubscriptionId    = $Operation.SubscriptionId
            SubscriptionName  = $Operation.SubscriptionName
            SubnetId          = $Operation.SubnetId
        }
    }

    #endregion Helper Functions

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    if ((Get-AzContext).Environment.name -ne 'AzureCloud') {
        Write-PSFMessage "This test is only applicable to the Global environment." -Tag Test -Level VeryVerbose
        Add-ZtTestResultDetail -SkippedBecause NotSupported
        return
    }

    try {
        $accessToken = Get-AzAccessToken -AsSecureString -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
    }
    catch {
        Write-PSFMessage $_.Exception.Message -Tag Test -Level Error
    }

    if (-not $accessToken) {
        Write-PSFMessage "Azure authentication token not found." -Tag Test -Level Warning
        Add-ZtTestResultDetail -SkippedBecause 'NotConnectedAzure'
        return
    }

    $subscriptions = Get-AzSubscription
    $firewalls = @()
    $nicFindings = @()

    foreach ($sub in $subscriptions) {
        Set-AzContext -SubscriptionId $sub.Id | Out-Null

        # Collect firewall private IPs
        $firewalls += Get-FirewallPrivateIP -SubscriptionId $sub.Id
        if ($firewalls.Count -eq 0) { continue }

        # Launch async operations for workload NICs
        $asyncOperations = Get-WorkloadNicOperation -Subscription $sub -SubscriptionId $sub.Id
        if ($asyncOperations.Count -eq 0) { continue }

        Write-PSFMessage "Launched $($asyncOperations.Count) async effectiveRouteTable requests for subscription $($sub.Name)" -Tag Test -Level Verbose

        # Wait for all operations to complete
        $completedOperations = Wait-AsyncOperation -Operations $asyncOperations

        # Process results into findings
        foreach ($op in $completedOperations) {
            $nicFindings += ConvertTo-NicFinding -Operation $op -Firewalls $firewalls
        }
    }
    #endregion Data Collection

    #region Assessment Logic
    if ($nicFindings.Count -eq 0) {
        Write-PSFMessage "No workload NICs found to evaluate." -Tag Test -Level Verbose
        return
    }

    $nonCompliantCount = @($nicFindings | Where-Object { -not $_.IsCompliant }).Count
    if ($nonCompliantCount -eq 0) {
        $passed = $true
        $testResultMarkdown = "✅ Outbound traffic is routed through Azure Firewall.`n`n%TestResult%"
    }
    else {
        $passed = $false
        $testResultMarkdown = "❌ Outbound traffic is not routed through Azure Firewall.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    $mdInfo = "## Outbound traffic routing evidence`n`n"
    $mdInfo += "| Subscription | Network interface | Subnet | Azure firewall private IP | Default route next hop type | Next hop IP address | Result |`n"
    $mdInfo += "| :--- | :--- | :--- | :--- | :--- | :--- | :--- |`n"

    foreach ($item in $nicFindings | Sort-Object SubscriptionName, NicName) {
        $icon = if ($item.IsCompliant) { '✅' } else { '❌' }

        $subLink = "https://portal.azure.com/#resource/subscriptions/$($item.SubscriptionId)"
        $subName = Get-SafeMarkdown -Text $item.SubscriptionName

        $nicLink = "https://portal.azure.com/#resource$($item.NicId)"
        $nicName = Get-SafeMarkdown -Text $item.NicName

        $subnetLink = "https://portal.azure.com/#resource$($item.SubnetId)"
        $subnetName = Get-SafeMarkdown -Text (($item.SubnetId -split '/')[-1])

        $fwIp = if ($item.FirewallPrivateIp) { $item.FirewallPrivateIp } else { 'N/A' }
        $nextHopType = if ($item.NextHopType) { $item.NextHopType } else { 'None' }
        $nextHopIp = if ($item.NextHopIpAddress) { $item.NextHopIpAddress } else { '' }

        $mdInfo += "| [$subName]($subLink) | [$nicName]($nicLink) | [$subnetName]($subnetLink) | $fwIp | $nextHopType | $nextHopIp | $icon |`n"
    }

    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '25535'
        Title  = 'Outbound traffic from VNET integrated workloads is routed through Azure Firewall'
        Status = $passed
        Result = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
