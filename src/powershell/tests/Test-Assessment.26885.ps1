<#
.SYNOPSIS
    Validates that metrics are enabled for DDoS-protected public IP addresses.

.DESCRIPTION
    This test evaluates diagnostic settings for public IP addresses that have Azure DDoS
    Protection enabled (either via DDoS IP Protection or inherited from a DDoS-protected VNET).
    It verifies that at least one diagnostic setting has metrics enabled with a valid destination
    (Log Analytics workspace, Storage account, or Event Hub) configured.

.NOTES
    Test ID: 26885
    Category: Azure Network Security
    Required APIs: Azure Management REST API (public IPs, VNETs, network interfaces, diagnostic settings)
#>

function Test-Assessment-26885 {

    [ZtTest(
        Category = 'Azure Network Security',
        ImplementationCost = 'Low',
        Service = ('Azure'),
        MinimumLicense = ('DDoS_Network_Protection', 'DDoS_IP_Protection'),
        Pillar = 'Network',
        RiskLevel = 'Medium',
        SfiPillar = 'Monitor and detect cyberthreats',
        TenantType = ('Workforce'),
        TestId = 26885,
        Title = 'Metrics are enabled for DDoS-protected public IPs',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Helper Functions

    function Get-SubnetIdFromIpConfiguration {
        <#
        .SYNOPSIS
            Gets the subnet ID from an IP configuration by determining the parent resource type.
        #>
        param(
            [Parameter(Mandatory)]
            [string]$IpConfigurationId
        )

        if ($IpConfigurationId -match '/providers/Microsoft.Network/networkInterfaces/') {
            $nicPath = ($IpConfigurationId -split '/ipConfigurations/')[0] + '?api-version=2023-04-01'
            $nic = Invoke-ZtAzureRequest -Path $nicPath

            $ipConfigName = ($IpConfigurationId -split '/ipConfigurations/')[-1]
            foreach ($ipConfig in $nic.properties.ipConfigurations) {
                if (($ipConfig.id -eq $IpConfigurationId) -or ($ipConfig.name -eq $ipConfigName)) {
                    if ($ipConfig.properties.subnet.id) {
                        return $ipConfig.properties.subnet.id
                    }
                    break
                }
            }
        }
        elseif ($IpConfigurationId -match '/providers/Microsoft.Network/loadBalancers/') {
            $lbPath = ($IpConfigurationId -split '/frontendIPConfigurations/')[0] + '?api-version=2023-04-01'
            $lb = Invoke-ZtAzureRequest -Path $lbPath

            $frontendIpConfigName = ($IpConfigurationId -split '/frontendIPConfigurations/')[-1]
            $frontendHasNoSubnet = $false
            foreach ($frontendIp in $lb.properties.frontendIPConfigurations) {
                if (($frontendIp.id -eq $IpConfigurationId) -or ($frontendIp.name -eq $frontendIpConfigName)) {
                    if ($frontendIp.properties.subnet.id) {
                        return $frontendIp.properties.subnet.id
                    }
                    $frontendHasNoSubnet = $true
                    break
                }
            }

            # External LB: trace through backend pool NIC to find a VNET
            if (-not $frontendHasNoSubnet) { return $null }
            foreach ($backendPool in $lb.properties.backendAddressPools) {
                foreach ($backendAddress in $backendPool.properties.backendIPConfigurations) {
                    if ($backendAddress.id -match '/providers/Microsoft.Network/networkInterfaces/') {
                        $nicPath = ($backendAddress.id -split '/ipConfigurations/')[0] + '?api-version=2023-04-01'
                        $nic = Invoke-ZtAzureRequest -Path $nicPath
                        $backendIpConfigName = ($backendAddress.id -split '/ipConfigurations/')[-1]
                        foreach ($ipConfig in $nic.properties.ipConfigurations) {
                            if (($ipConfig.id -eq $backendAddress.id) -or ($ipConfig.name -eq $backendIpConfigName)) {
                                if ($ipConfig.properties.subnet.id) {
                                    return $ipConfig.properties.subnet.id
                                }
                                break
                            }
                        }
                    }
                }
            }
        }
        elseif ($IpConfigurationId -match '/providers/Microsoft.Network/applicationGateways/') {
            $appGwPath = ($IpConfigurationId -split '/frontendIPConfigurations/')[0] + '?api-version=2023-04-01'
            $appGw = Invoke-ZtAzureRequest -Path $appGwPath

            $frontendIpConfigName = ($IpConfigurationId -split '/frontendIPConfigurations/')[-1]
            foreach ($frontendIp in $appGw.properties.frontendIPConfigurations) {
                if (($frontendIp.id -eq $IpConfigurationId) -or ($frontendIp.name -eq $frontendIpConfigName)) {
                    if ($frontendIp.properties.subnet.id) {
                        return $frontendIp.properties.subnet.id
                    }
                    break
                }
            }

            foreach ($gwIpConfig in $appGw.properties.gatewayIPConfigurations) {
                if ($gwIpConfig.properties.subnet.id) {
                    return $gwIpConfig.properties.subnet.id
                }
            }
        }
        elseif ($IpConfigurationId -match '/providers/Microsoft.Network/azureFirewalls/') {
            $fwPath = ($IpConfigurationId -split '/azureFirewallIpConfigurations/')[0] + '?api-version=2023-04-01'
            $fw = Invoke-ZtAzureRequest -Path $fwPath
            $ipConfigName = ($IpConfigurationId -split '/azureFirewallIpConfigurations/')[-1]
            foreach ($ipConfig in $fw.properties.ipConfigurations) {
                if (($ipConfig.id -eq $IpConfigurationId) -or ($ipConfig.name -eq $ipConfigName)) {
                    if ($ipConfig.properties.subnet.id) {
                        return $ipConfig.properties.subnet.id
                    }
                    break
                }
            }
        }
        elseif ($IpConfigurationId -match '/providers/Microsoft.Network/bastionHosts/') {
            $bastionPath = ($IpConfigurationId -split '/bastionHostIpConfigurations/')[0] + '?api-version=2023-04-01'
            $bastion = Invoke-ZtAzureRequest -Path $bastionPath
            $ipConfigName = ($IpConfigurationId -split '/bastionHostIpConfigurations/')[-1]
            foreach ($ipConfig in $bastion.properties.ipConfigurations) {
                if (($ipConfig.id -eq $IpConfigurationId) -or ($ipConfig.name -eq $ipConfigName)) {
                    if ($ipConfig.properties.subnet.id) {
                        return $ipConfig.properties.subnet.id
                    }
                    break
                }
            }
        }
        elseif ($IpConfigurationId -match '/providers/Microsoft.Network/virtualNetworkGateways/') {
            $vngPath = ($IpConfigurationId -split '/ipConfigurations/')[0] + '?api-version=2023-04-01'
            $vng = Invoke-ZtAzureRequest -Path $vngPath
            $ipConfigName = ($IpConfigurationId -split '/ipConfigurations/')[-1]
            foreach ($ipConfig in $vng.properties.ipConfigurations) {
                if (($ipConfig.id -eq $IpConfigurationId) -or ($ipConfig.name -eq $ipConfigName)) {
                    if ($ipConfig.properties.subnet.id) {
                        return $ipConfig.properties.subnet.id
                    }
                    break
                }
            }
        }

        return $null
    }

    #endregion Helper Functions

    #region Data Collection

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose
    $activity = 'Evaluating DDoS Protection metrics configuration'

    # Check Azure connection
    Write-ZtProgress -Activity $activity -Status 'Checking Azure connection'

    $azContext = Get-AzContext -ErrorAction SilentlyContinue
    if (-not $azContext) {
        Write-PSFMessage 'Not connected to Azure.' -Tag Test -Level Warning
        Add-ZtTestResultDetail -SkippedBecause NotConnectedAzure
        return
    }

    # Check supported environment
    Write-ZtProgress -Activity $activity -Status 'Checking Azure environment'

    if ($azContext.Environment.Name -ne 'AzureCloud') {
        Write-PSFMessage 'This test is only applicable to the AzureCloud environment.' -Tag Test -Level VeryVerbose
        Add-ZtTestResultDetail -SkippedBecause NotSupported
        return
    }

    # Check Azure access token
    try {
        $accessToken = Get-AzAccessToken -AsSecureString -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
    }
    catch {
        Write-PSFMessage $_.Exception.Message -Tag Test -Level Error
    }

    if (-not $accessToken) {
        Write-PSFMessage 'Azure authentication token not found.' -Tag Test -Level Warning
        Add-ZtTestResultDetail -SkippedBecause NotConnectedAzure
        return
    }

    # Query all public IP addresses via Azure Resource Graph
    Write-ZtProgress -Activity $activity -Status 'Querying Public IP Addresses via Resource Graph'

    $argQuery = @"
resources
| where type =~ 'microsoft.network/publicipaddresses'
| where properties.provisioningState =~ 'Succeeded'
| join kind=leftouter (
    resourcecontainers
    | where type =~ 'microsoft.resources/subscriptions'
    | project subscriptionName=name, subscriptionId
) on subscriptionId
| project
    PublicIpName=name,
    PublicIpId=id,
    ResourceGroup=resourceGroup,
    Location=location,
    IpAddress=tostring(properties.ipAddress),
    ProtectionMode=tostring(properties.ddosSettings.protectionMode),
    IpConfigurationId=tostring(properties.ipConfiguration.id),
    SubscriptionId=subscriptionId,
    SubscriptionName=subscriptionName
"@

    $allPublicIps = @()
    try {
        $allPublicIps = @(Invoke-ZtAzureResourceGraphRequest -Query $argQuery)
        Write-PSFMessage "ARG Query returned $($allPublicIps.Count) Public IP Address(es)" -Tag Test -Level VeryVerbose
    }
    catch {
        Write-PSFMessage "Azure Resource Graph query failed: $($_.Exception.Message)" -Tag Test -Level Warning
        Add-ZtTestResultDetail -SkippedBecause NotSupported
        return
    }

    if ($allPublicIps.Count -eq 0) {
        Write-PSFMessage 'No Public IP addresses found.' -Tag Test -Level VeryVerbose
        Add-ZtTestResultDetail -SkippedBecause NotApplicable
        return
    }


    Write-ZtProgress -Activity $activity -Status 'Evaluating DDoS protection status'

    $ddosProtectedIps = @()

    foreach ($publicIp in $allPublicIps) {
        $protectionMode = $publicIp.ProtectionMode
        $ipConfigId = $publicIp.IpConfigurationId

        # Skip explicitly disabled
        if ($protectionMode -eq 'Disabled') { continue }

        # Directly protected via DDoS IP Protection
        if ($protectionMode -eq 'Enabled') {
            $ddosProtectedIps += [PSCustomObject]@{
                PublicIpName     = $publicIp.PublicIpName
                PublicIpId       = $publicIp.PublicIpId
                ResourceGroup    = $publicIp.ResourceGroup
                Location         = $publicIp.Location
                IpAddress        = $publicIp.IpAddress
                ProtectionType   = 'IP Protection'
                AssociatedResourceType = 'N/A'
                AssociatedVnet   = 'N/A'
                SubscriptionId   = $publicIp.SubscriptionId
                SubscriptionName = $publicIp.SubscriptionName
            }
            continue
        }

        # VirtualNetworkInherited: requires VNET to actually have DDoS Network Protection
        if ($protectionMode -eq 'VirtualNetworkInherited') {
            # Skip orphaned IPs (no associated resource)
            if ([string]::IsNullOrEmpty($ipConfigId)) { continue }

            $vnetId = $null
            $vnetName = $null
            $associatedResourceType = 'Unknown'

            try {
                if ($ipConfigId -match '/providers/Microsoft.Network/networkInterfaces/') {
                    $associatedResourceType = 'Network Interface'
                }
                elseif ($ipConfigId -match '/providers/Microsoft.Network/loadBalancers/') {
                    $associatedResourceType = 'Load Balancer'
                }
                elseif ($ipConfigId -match '/providers/Microsoft.Network/applicationGateways/') {
                    $associatedResourceType = 'Application Gateway'
                }
                elseif ($ipConfigId -match '/providers/Microsoft.Network/azureFirewalls/') {
                    $associatedResourceType = 'Azure Firewall'
                }
                elseif ($ipConfigId -match '/providers/Microsoft.Network/bastionHosts/') {
                    $associatedResourceType = 'Azure Bastion'
                }
                elseif ($ipConfigId -match '/providers/Microsoft.Network/virtualNetworkGateways/') {
                    $associatedResourceType = 'Virtual Network Gateway'
                }

                $subnetId = Get-SubnetIdFromIpConfiguration -IpConfigurationId $ipConfigId
                if ($subnetId -and $subnetId -match '(/subscriptions/.+/resourceGroups/.+/providers/Microsoft.Network/virtualNetworks/[^/]+)') {
                    $vnetId = $Matches[1]
                    $vnetName = ($vnetId -split '/')[-1]
                }
            }
            catch {
                Write-PSFMessage "Error getting subnet for $($publicIp.PublicIpName): $($_.Exception.Message)" -Tag Test -Level Warning
                continue
            }

            if (-not $vnetId) { continue }

            # Verify VNET has DDoS Network Protection enabled with a Protection Plan
            try {
                $vnet = Invoke-ZtAzureRequest -Path ($vnetId + '?api-version=2023-04-01')

                $ddosEnabled = $vnet.properties.enableDdosProtection -eq $true
                $ddosPlanId = $vnet.properties.ddosProtectionPlan.id

                if ($ddosEnabled -and $ddosPlanId) {
                    $ddosProtectedIps += [PSCustomObject]@{
                        PublicIpName           = $publicIp.PublicIpName
                        PublicIpId             = $publicIp.PublicIpId
                        ResourceGroup          = $publicIp.ResourceGroup
                        Location               = $publicIp.Location
                        IpAddress              = $publicIp.IpAddress
                        ProtectionType         = 'Network Protection'
                        AssociatedResourceType = $associatedResourceType
                        AssociatedVnet         = $vnetName
                        SubscriptionId         = $publicIp.SubscriptionId
                        SubscriptionName       = $publicIp.SubscriptionName
                    }
                }
            }
            catch {
                Write-PSFMessage "Error checking VNET DDoS protection for $($publicIp.PublicIpName): $($_.Exception.Message)" -Tag Test -Level Warning
            }
        }
    }

    if ($ddosProtectedIps.Count -eq 0) {
        Write-PSFMessage 'No DDoS-protected Public IP addresses found.' -Tag Test -Level VeryVerbose
        Add-ZtTestResultDetail -SkippedBecause NotApplicable
        return
    }

    #endregion Data Collection


    #region Assessment Logic

    Write-ZtProgress -Activity $activity -Status 'Querying diagnostic settings'

    $evaluationResults = @()

    foreach ($pip in $ddosProtectedIps) {
        $diagPath = $pip.PublicIpId + '/providers/Microsoft.Insights/diagnosticSettings?api-version=2021-05-01-preview'

        $diagSettings = @()
        try {
            $diagSettings = @(Invoke-ZtAzureRequest -Path $diagPath)
        }
        catch {
            Write-PSFMessage "Error querying diagnostic settings for $($pip.PublicIpName): $($_.Exception.Message)" -Tag Test -Level Warning
        }

        # Metrics are enabled when at least one diagnostic setting has an enabled metric
        # AND a valid destination is configured.
        $metricsEnabled = $false
        $workspaceName = 'N/A'

        foreach ($setting in $diagSettings) {
            $workspaceId = $setting.properties.workspaceId
            $storageAccountId = $setting.properties.storageAccountId
            $eventHubAuthRuleId = $setting.properties.eventHubAuthorizationRuleId

            $hasDestination = $workspaceId -or $storageAccountId -or $eventHubAuthRuleId
            if (-not $hasDestination) { continue }

            $hasEnabledMetric = $false
            foreach ($metric in $setting.properties.metrics) {
                if ($metric.enabled) { $hasEnabledMetric = $true; break }
            }

            if ($hasEnabledMetric) {
                $metricsEnabled = $true

                if ($workspaceId -and $workspaceName -eq 'N/A') {
                    $workspaceName = ($workspaceId -split '/')[-1]
                }
            }
        }

        $evaluationResults += [PSCustomObject]@{
            SubscriptionId         = $pip.SubscriptionId
            SubscriptionName       = $pip.SubscriptionName
            PublicIpName           = $pip.PublicIpName
            PublicIpId             = $pip.PublicIpId
            ResourceGroup          = $pip.ResourceGroup
            Location               = $pip.Location
            IpAddress              = $pip.IpAddress
            ProtectionType         = $pip.ProtectionType
            AssociatedResourceType = $pip.AssociatedResourceType
            AssociatedVnet         = $pip.AssociatedVnet
            MetricsEnabled         = $metricsEnabled
            LogAnalyticsWorkspace  = $workspaceName
             Status                 = if ($metricsEnabled) { 'Pass' } else { 'Fail' }
        }
    }

    $passedItems = @($evaluationResults | Where-Object { $_.Status -eq 'Pass' })
    $failedItems = @($evaluationResults | Where-Object { $_.Status -eq 'Fail' })

    $passed = ($failedItems.Count -eq 0) -and ($passedItems.Count -gt 0)

    if ($passed) {
        $testResultMarkdown = "✅ Metrics are enabled for all DDoS-protected public IP addresses.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "❌ Metrics are not enabled for one or more DDoS-protected public IP addresses.`n`n%TestResult%"
    }

    #endregion Assessment Logic

    #region Report Generation

    $portalPublicIpBrowseLink = 'https://portal.azure.com/#browse/Microsoft.Network%2FpublicIPAddresses'
    $portalResourceBaseLink = 'https://portal.azure.com/#resource'

    $mdInfo = "`n## [DDoS-protected Public IP metrics status]($portalPublicIpBrowseLink)`n`n"

    if ($evaluationResults.Count -gt 0) {
        $tableRows = ''
        $formatTemplate = @'
| Public IP name | Resource Group | Subscription | IP address | Protection type | Associated resource | Associated VNET | Metrics enabled | Log Analytics workspace | Status |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
{0}

'@

        $maxItemsToDisplay = 5
        $displayResults = $evaluationResults
        $hasMoreItems = $false
        if ($evaluationResults.Count -gt $maxItemsToDisplay) {
            $displayResults = $evaluationResults | Select-Object -First $maxItemsToDisplay
            $hasMoreItems = $true
        }

        foreach ($result in $displayResults) {
            $pipLink         = "[$(Get-SafeMarkdown $result.PublicIpName)]($portalResourceBaseLink$($result.PublicIpId)/diagnostics)"
            $resourceGroup   = Get-SafeMarkdown $result.ResourceGroup
            $subscription    = Get-SafeMarkdown $result.SubscriptionName
            $ipAddress       = Get-SafeMarkdown $result.IpAddress
            $protectionType  = $result.ProtectionType
            $associatedRes   = Get-SafeMarkdown $result.AssociatedResourceType
            $associatedVnet  = Get-SafeMarkdown $result.AssociatedVnet
            $metricsStatus   = if ($result.MetricsEnabled) { '✅ Yes' } else { '❌ No' }
            $workspace       = Get-SafeMarkdown $result.LogAnalyticsWorkspace
            $statusText      = if ($result.Status -eq 'Pass') { '✅ Pass' } else { '❌ Fail' }

            $tableRows += "| $pipLink | $resourceGroup | $subscription | $ipAddress | $protectionType | $associatedRes | $associatedVnet | $metricsStatus | $workspace | $statusText |`n"
        }

        if ($hasMoreItems) {
            $remainingCount = $evaluationResults.Count - $maxItemsToDisplay
            $tableRows += "`n... and $remainingCount more. [View all Public IP Addresses in the portal]($portalPublicIpBrowseLink)`n"
        }

        $mdInfo += $formatTemplate -f $tableRows
    }

    $mdInfo += "**Summary:**`n`n"
    $mdInfo += "- Total DDoS-protected Public IPs evaluated: $($evaluationResults.Count)`n"
    $mdInfo += "- Public IPs with metrics enabled: $($passedItems.Count)`n"
    $mdInfo += "- Public IPs missing metrics: $($failedItems.Count)`n"

    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo

    #endregion Report Generation

    $params = @{
        TestId = '26885'
        Title  = 'Metrics are enabled for DDoS-protected public IPs'
        Status = $passed
        Result = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
