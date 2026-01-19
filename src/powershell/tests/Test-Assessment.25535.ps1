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

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    if ((Get-MgContext).Environment -ne 'Global') {
        Write-PSFMessage "This test is only applicable to the Global environment." -Tag Test -Level VeryVerbose
        return
    }

    #region Azure Connection Verification
    try {
        $accessToken = Get-AzAccessToken -AsSecureString -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
    }
    catch {
        Write-PSFMessage $_.Exception.Message -Tag Test -Level Error
    }

    if (-not $accessToken) {
        Write-PSFMessage "Azure authentication token not found." -Tag Test -Level Warning
        Add-ZtTestResultDetail -SkippedBecause NoAzureAccess
        return
    }
    #endregion

    #region Data Collection
    $azAccessToken = $accessToken.Token
    $resourceManagementUrl = (Get-AzContext).Environment.ResourceManagerUrl
    $subscriptions = Get-AzSubscription

    $firewalls = @()
    $nicFindings = @()

    foreach ($sub in $subscriptions) {

        Set-AzContext -SubscriptionId $sub.Id | Out-Null
        $subId = $sub.Id

        # Step 1: List Azure Firewalls
        $fwListUri = $resourceManagementUrl.TrimEnd('/') +
            "/subscriptions/$subId/providers/Microsoft.Network/azureFirewalls?api-version=2025-03-01"

        try {
            $fwResp = Invoke-WebRequest -Uri $fwListUri -Authentication Bearer -Token $azAccessToken -ErrorAction Stop
        }
        catch {
            Write-PSFMessage "Unable to list Azure Firewalls in subscription $($sub.Name)." -Tag Test -Level Warning
            continue
        }

        $fwItems = ($fwResp.Content | ConvertFrom-Json).value
        if (-not $fwItems) { continue }

        # Step 2: Resolve Firewall Private IPs
        foreach ($fw in $fwItems) {

            $fwDetailUri = $resourceManagementUrl.TrimEnd('/') +
                "$($fw.id)?api-version=2025-03-01"

            try {
                $fwDetailResp = Invoke-WebRequest -Uri $fwDetailUri -Authentication Bearer -Token $azAccessToken -ErrorAction Stop
                $fwDetail = $fwDetailResp.Content | ConvertFrom-Json
            }
            catch { continue }

            foreach ($ipconfig in $fwDetail.properties.ipConfigurations) {
                if ($ipconfig.properties.privateIPAddress) {
                    $firewalls += [PSCustomObject]@{
                        FirewallName   = $fwDetail.name
                        FirewallId     = $fwDetail.id
                        PrivateIP      = $ipconfig.properties.privateIPAddress
                        SubscriptionId = $subId
                    }
                }
            }
        }

        if ($firewalls.Count -eq 0) { continue }

        # Step 3: List NICs
        $nicListUri = $resourceManagementUrl.TrimEnd('/') +
            "/subscriptions/$subId/providers/Microsoft.Network/networkInterfaces?api-version=2025-03-01"

        try {
            $nicResp = Invoke-WebRequest -Uri $nicListUri -Authentication Bearer -Token $azAccessToken -ErrorAction Stop
        }
        catch {
            Write-PSFMessage "Unable to list network interfaces in subscription $($sub.Name)." -Tag Test -Level Warning
            continue
        }

        $nics = ($nicResp.Content | ConvertFrom-Json).value

        # Step 4: Stage 1 - Launch all async effectiveRouteTable requests
        $asyncOperations = @()

        foreach ($nic in $nics) {
            foreach ($ipconfig in $nic.properties.ipConfigurations) {

                if (-not $ipconfig.properties.subnet?.id) { continue }

                $subnetId = $ipconfig.properties.subnet.id
                if ($subnetId -match 'AzureFirewallSubnet|GatewaySubnet|AzureBastionSubnet') {
                    continue
                }

                $rg = ($nic.id -split '/')[4]
                $nicName = $nic.name

                $ertUri = $resourceManagementUrl.TrimEnd('/') +
                    "/subscriptions/$subId/resourceGroups/$rg/providers/Microsoft.Network/networkInterfaces/$nicName/effectiveRouteTable?api-version=2025-03-01"

                try {
                    $ertStart = Invoke-WebRequest -Uri $ertUri -Authentication Bearer -Token $azAccessToken -Method Post -ErrorAction Stop
                    $operationUri = $ertStart.Headers['Location'][0]

                    $retryAfter = if ($ertStart.Headers['Retry-After']) {
                        [int]$ertStart.Headers['Retry-After'][0]
                    } else { 5 }

                    $asyncOperations += @{
                        OperationUri = $operationUri
                        Nic          = $nic
                        RetryAfter   = $retryAfter
                        Timestamp    = Get-Date
                        SubnetId     = $subnetId
                        SubscriptionId = $sub.Id
                        SubscriptionName = $sub.Name
                    }
                }
                catch {
                    Write-PSFMessage "Failed to initiate effectiveRouteTable request for NIC $nicName : $($_.Exception.Message)" -Tag Test -Level Warning
                }
            }
        }

        if ($asyncOperations.Count -eq 0) { continue }

        Write-PSFMessage "Launched $($asyncOperations.Count) async effectiveRouteTable requests for subscription $($sub.Name)" -Tag Test -Level Verbose

        # Step 4: Stage 2 - Poll all operations in parallel
        $completedOperations = @()
        $maxRetries = 120  # ~10 minutes with 5 second intervals

        do {
            $stillPending = @()

            foreach ($op in $asyncOperations) {
                if ($op.Completed) {
                    $completedOperations += $op
                    continue
                }

                try {
                    $ertPoll = Invoke-WebRequest -Uri $op.OperationUri -Authentication Bearer -Token $azAccessToken -ErrorAction Stop

                    if ($ertPoll.StatusCode -ne 202) {
                        $op.Routes = ($ertPoll.Content | ConvertFrom-Json).value
                        $op.Completed = $true
                        $completedOperations += $op
                    } else {
                        $stillPending += $op
                    }
                }
                catch {
                    Write-PSFMessage "Error polling operation for NIC $($op.Nic.name) : $($_.Exception.Message)" -Tag Test -Level Warning
                    $op.Completed = $true
                    $op.Error = $true
                    $completedOperations += $op
                }
            }

            $asyncOperations = $stillPending

            if ($asyncOperations.Count -gt 0) {
                $maxRetries--
                if ($maxRetries -le 0) {
                    Write-PSFMessage "Timeout polling effectiveRouteTable operations. Processing $($asyncOperations.Count) incomplete operations." -Tag Test -Level Warning
                    $completedOperations += $asyncOperations
                    break
                }

                $retryAfter = ($asyncOperations | Select-Object -First 1).RetryAfter
                Write-PSFMessage "Polling $($asyncOperations.Count) pending operations..." -Tag Test -Level Verbose
                Start-Sleep -Seconds $retryAfter
            }

        } while ($asyncOperations.Count -gt 0)

        # Step 4: Stage 3 - Process completed operations
        foreach ($op in $completedOperations) {
            if ($op.Error -or -not $op.Routes) {
                $nicFindings += [PSCustomObject]@{
                    NicName     = $op.Nic.name
                    NicId       = $op.Nic.id
                    NextHopType = 'Unknown'
                    NextHopIp   = ''
                    IsCompliant = $false
                    SubscriptionId = $op.SubscriptionId
                    SubscriptionName = $op.SubscriptionName
                    SubnetId = $op.SubnetId
                    FirewallPrivateIp = 'N/A'
                    NextHopIpAddress = ''
                }
                continue
            }

            $defaultRoute = $op.Routes | Where-Object {
                $_.state -eq 'Active' -and
                $_.source -eq 'User' -and
                (($_.addressPrefix -eq '0.0.0.0/0') -or ($_.addressPrefix -contains '0.0.0.0/0'))
            } | Select-Object -First 1

            if (-not $defaultRoute) {
                $nicFindings += [PSCustomObject]@{
                    NicName     = $op.Nic.name
                    NicId       = $op.Nic.id
                    NextHopType = 'Internet'
                    NextHopIp   = ''
                    IsCompliant = $false
                    SubscriptionId = $op.SubscriptionId
                    SubscriptionName = $op.SubscriptionName
                    SubnetId = $op.SubnetId
                    FirewallPrivateIp = 'N/A'
                    NextHopIpAddress = ''
                }
                continue
            }

            $fwMatch = $firewalls | Where-Object {
                # Handle nextHopIpAddress being either a string or an array
                $nextHop = $defaultRoute.nextHopIpAddress
                ( ($nextHop -eq $_.PrivateIP) -or ($nextHop -contains $_.PrivateIP) )
            } | Select-Object -First 1

            $nicFindings += [PSCustomObject]@{
                FirewallName      = if ($fwMatch) { $fwMatch.FirewallName } else { 'N/A' }
                FirewallId        = if ($fwMatch) { $fwMatch.FirewallId } else { 'N/A' }
                FirewallPrivateIp = if ($fwMatch) { $fwMatch.PrivateIP } else { 'N/A' }
                NicName           = $op.Nic.name
                NicId             = $op.Nic.id
                RouteSource       = $defaultRoute.source
                RouteState        = $defaultRoute.state
                AddressPrefix     = ($defaultRoute.addressPrefix -join ',')
                NextHopType       = $defaultRoute.nextHopType
                NextHopIpAddress  = ($defaultRoute.nextHopIpAddress -join ',')
                IsCompliant       = ($fwMatch -ne $null)
                SubscriptionId    = $op.SubscriptionId
                SubscriptionName  = $op.SubscriptionName
                SubnetId          = $op.SubnetId
            }
        }
    }
    #endregion

    #region Assessment Logic
    if ($nicFindings.Count -eq 0) {
        Add-ZtTestResultDetail -SkippedBecause NoResults
        return
    }

    $passed = ($nicFindings | Where-Object { -not $_.IsCompliant }).Count -eq 0

    $testResultMarkdown = if ($passed) {
        "Outbound traffic is routed through Azure Firewall.`n`n%TestResult%"
    } else {
        "Outbound traffic is not routed through Azure Firewall.`n`n%TestResult%"
    }
    #endregion

    #region Result Reporting
    $mdInfo = "## Outbound traffic routing evidence`n`n"
    $mdInfo += "| Subscription | Network interface | Subnet | Azure firewall private IP | Default route next hop type | Next hop IP address | Result |`n"
    $mdInfo += "| :--- | :--- | :--- | :--- | :--- | :--- | :--- |`n"

    foreach ($item in $nicFindings | Sort-Object SubscriptionName, NicName) {
        $icon = if ($item.IsCompliant) { '✅' } else { '❌' }

        $subName = if ($item.SubscriptionName) { $item.SubscriptionName } else { 'N/A' }
        $subLink = "https://portal.azure.com/#resource/subscriptions/$($item.SubscriptionId)"
        $subMd = "[$(Get-SafeMarkdown -Text $subName)]($subLink)"

        $nicName = if ($item.NicName) { $item.NicName } else { 'N/A' }
        $nicLink = "https://portal.azure.com/#resource$($item.NicId)"
        $nicMd = "[$(Get-SafeMarkdown -Text $nicName)]($nicLink)"

        $subnetName = if ($item.SubnetId) { ($item.SubnetId -split '/')[-1] } else { 'N/A' }
        $subnetLink = "https://portal.azure.com/#resource$($item.SubnetId)"
        $subnetMd = "[$(Get-SafeMarkdown -Text $subnetName)]($subnetLink)"

        $fwIp = if ($item.FirewallPrivateIp) { $item.FirewallPrivateIp } else { 'N/A' }
        $nextHopType = if ($item.NextHopType) { $item.NextHopType } else { 'None' }
        $nextHopIp = if ($item.NextHopIpAddress) { $item.NextHopIpAddress } else { '' }

        $mdInfo += "| $subMd | $nicMd | $subnetMd | $fwIp | $nextHopType | $nextHopIp | $icon |`n"
    }

    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo
    Add-ZtTestResultDetail -TestId '25535' -Status $passed -Result $testResultMarkdown
    #endregion
}
