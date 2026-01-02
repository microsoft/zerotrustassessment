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
    #endregion Azure Connection Verification

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
        if (-not $fwItems) {
            continue
        }

        # Step 2: Resolve Firewall Private IPs
        foreach ($fw in $fwItems) {

            $fwDetailUri = $resourceManagementUrl.TrimEnd('/') +
            "$($fw.id)?api-version=2025-03-01"

            try {
                $fwDetailResp = Invoke-WebRequest -Uri $fwDetailUri -Authentication Bearer -Token $azAccessToken -ErrorAction Stop
                $fwDetail = $fwDetailResp.Content | ConvertFrom-Json
            }
            catch {
                continue
            }

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

        if ($firewalls.Count -eq 0) {
            continue
        }

        # Step 3: List NICs
        $nicListUri = $resourceManagementUrl.TrimEnd('/') +
        "/subscriptions/$subId/providers/Microsoft.Network/networkInterfaces?api-version=2025-03-01"

        $nicResp = Invoke-WebRequest -Uri $nicListUri -Authentication Bearer -Token $azAccessToken
        $nics = ($nicResp.Content | ConvertFrom-Json).value

        foreach ($nic in $nics) {

            foreach ($ipconfig in $nic.properties.ipConfigurations) {

                $subnetId = $ipconfig.properties.subnet.id
                if ($subnetId -match 'AzureFirewallSubnet|GatewaySubnet|AzureBastionSubnet') {
                    continue
                }

                # Step 4: Effective Route Table (ASYNC)
                $rg = ($nic.id -split '/')[4]
                $nicName = $nic.name

                $ertUri = $resourceManagementUrl.TrimEnd('/') +
                "/subscriptions/$subId/resourceGroups/$rg/providers/Microsoft.Network/networkInterfaces/$nicName/effectiveRouteTable?api-version=2025-03-01"

                try {
                    $ertStart = Invoke-WebRequest `
                        -Uri $ertUri `
                        -Authentication Bearer `
                        -Token $azAccessToken `
                        -Method Post

                    $operationUri = $ertStart.Headers['Location'][0]

                    $retryAfter = if ($ertStart.Headers['Retry-After']) {
                        [int]$ertStart.Headers['Retry-After'][0]
                    }
                    else {
                        5
                    }

                    do {
                        Start-Sleep -Seconds $retryAfter

                        $ertPoll = Invoke-WebRequest `
                            -Uri $operationUri `
                            -Authentication Bearer `
                            -Token $azAccessToken `
                            -Method Get

                    } while ($ertPoll.StatusCode -eq 202)

                    $routes = ($ertPoll.Content | ConvertFrom-Json).value
                }
                catch {
                    continue
                }

                $defaultRoute = $routes | Where-Object {
                    $_.state -eq 'Active' -and
                    $_.source -eq 'User' -and
                    $_.addressPrefix -contains '0.0.0.0/0'
                } | Select-Object -First 1

                # No user-defined default route → FAIL
                if (-not $defaultRoute) {
                    $nicFindings += [PSCustomObject]@{
                        NicName     = $nic.name
                        NicId       = $nic.id
                        NextHopType = 'Internet'
                        NextHopIp   = ''
                        IsCompliant = $false
                    }
                    continue
                }

                # Match firewall private IP
                $fwMatch = $firewalls | Where-Object {
                    $defaultRoute.nextHopIpAddress -contains $_.PrivateIP
                } | Select-Object -First 1

                $nicFindings += [PSCustomObject]@{
                    FirewallName      = $fwMatch.FirewallName
                    FirewallId        = $fwMatch.FirewallId
                    FirewallPrivateIp = $fwMatch.PrivateIP

                    NicName           = $nic.name
                    NicId             = $nic.id

                    RouteSource       = $defaultRoute.source
                    RouteState        = $defaultRoute.state
                    AddressPrefix     = ($defaultRoute.addressPrefix -join ',')
                    NextHopType       = $defaultRoute.nextHopType
                    NextHopIpAddress  = ($defaultRoute.nextHopIpAddress -join ',')

                    IsCompliant       = ($fwMatch -ne $null)
                }
            }
        }
    }
    #endregion Data Collection

    #region Assessment Logic
    if ($nicFindings.Count -eq 0) {
        Add-ZtTestResultDetail -SkippedBecause NoResults
        return
    }

    $nonCompliant = $nicFindings | Where-Object { -not $_.IsCompliant }
    $passed = ($nonCompliant.Count -eq 0)

    if ($passed) {
        $testResultMarkdown = "Outbound traffic is routed through Azure Firewall private IP using a user-defined default route.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "Outbound traffic is not routed through Azure Firewall. The effective route for outbound traffic does not forward 0.0.0.0/0 to the Azure Firewall private IP.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Result Reporting
    $mdInfo = "## Outbound traffic routing evidence`n`n"
    $mdInfo += "| Azure Firewall | Firewall Private IP | Network Interface | Source | State | Address Prefix | Next Hop Type | Next Hop IP | Status |`n"
    $mdInfo += "| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |`n"

    foreach ($item in $nicFindings | Sort-Object NicName) {
        $icon = if ($item.IsCompliant) {
            '✅'
        }
        else {
            '❌'
        }
        $safeName = Get-SafeMarkdown -Text $item.NicName
        $mdInfo += "| $icon [$safeName](https://portal.azure.com/#@/resource$($item.NicId)) | $($item.NextHopType) | $($item.NextHopIp) | $icon |`n"
    }

    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo

    Add-ZtTestResultDetail -TestId '25535' -Status $passed -Result $testResultMarkdown
    #endregion Result Reporting
}
