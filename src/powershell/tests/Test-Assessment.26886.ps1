<#
.SYNOPSIS
    Validates that diagnostic logging is enabled for DDoS-protected public IP addresses.

.DESCRIPTION
    This test evaluates diagnostic settings for public IP addresses that have Azure DDoS Protection
    enabled (either via DDoS IP Protection or inherited from a protected VNET). It verifies that
    all three required DDoS log categories are enabled with a valid destination configured.

.NOTES
    Test ID: 26886
    Category: Azure Network Security
    Required APIs: Azure Management REST API (public IPs, VNETs, network interfaces, diagnostic settings)
#>

function Test-Assessment-26886 {

    [ZtTest(
        Category = 'Azure Network Security',
        ImplementationCost = 'Low',
        MinimumLicense = ('DDoS_Network_Protection', 'DDoS_IP_Protection'),
        Pillar = 'Network',
        RiskLevel = 'Medium',
        SfiPillar = 'Protect networks',
        TenantType = ('Workforce'),
        TestId = 26886,
        Title = 'Diagnostic logging is enabled for DDoS-protected public IPs',
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

        # Parse the IP configuration ID to determine the resource type
        # Common patterns:
        # - NIC: /subscriptions/.../resourceGroups/.../providers/Microsoft.Network/networkInterfaces/{nicName}/ipConfigurations/{ipConfigName}
        # - Load Balancer: /subscriptions/.../resourceGroups/.../providers/Microsoft.Network/loadBalancers/{lbName}/frontendIPConfigurations/{ipConfigName}
        # - App Gateway: /subscriptions/.../resourceGroups/.../providers/Microsoft.Network/applicationGateways/{appGwName}/frontendIPConfigurations/{ipConfigName}

        if ($IpConfigurationId -match '/providers/Microsoft.Network/networkInterfaces/') {
            # It's a NIC - extract the NIC resource path and query it
            $nicPath = ($IpConfigurationId -split '/ipConfigurations/')[0] + '?api-version=2023-04-01'
            $nic = Invoke-ZtAzureRequest -Path $nicPath

            # Find the subnet from the matching IP configuration
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
            # Load Balancer frontend IPs can be associated with a subnet for internal LBs
            # For external LBs, they're not associated with a subnet directly
            # We need to find a backend pool NIC to trace to the VNET
            $lbPath = ($IpConfigurationId -split '/frontendIPConfigurations/')[0] + '?api-version=2023-04-01'
            $lb = Invoke-ZtAzureRequest -Path $lbPath

            # Check the matching frontend IP configuration for subnet (internal LB)
            $frontendIpConfigName = ($IpConfigurationId -split '/frontendIPConfigurations/')[-1]
            $frontendHasNoSubnet = $false
            foreach ($frontendIp in $lb.properties.frontendIPConfigurations) {
                if (($frontendIp.id -eq $IpConfigurationId) -or ($frontendIp.name -eq $frontendIpConfigName)) {
                    if ($frontendIp.properties.subnet.id) {
                        return $frontendIp.properties.subnet.id
                    }
                    # Matched the correct entry but it has no subnet (external LB frontend)
                    $frontendHasNoSubnet = $true
                    break
                }
            }

            # For external LB (matched frontend has no subnet), check backend pool NICs
            if (-not $frontendHasNoSubnet) { return $null }  # No match found at all — bail out
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
            # Application Gateway - get the gateway's subnet from gateway IP configurations
            $appGwPath = ($IpConfigurationId -split '/frontendIPConfigurations/')[0] + '?api-version=2023-04-01'
            $appGw = Invoke-ZtAzureRequest -Path $appGwPath

            # For private frontend IPs, the matched frontendIPConfiguration carries a subnet directly
            $frontendIpConfigName = ($IpConfigurationId -split '/frontendIPConfigurations/')[-1]
            foreach ($frontendIp in $appGw.properties.frontendIPConfigurations) {
                if (($frontendIp.id -eq $IpConfigurationId) -or ($frontendIp.name -eq $frontendIpConfigName)) {
                    if ($frontendIp.properties.subnet.id) {
                        return $frontendIp.properties.subnet.id
                    }
                    break  # Matched config has no subnet (public frontend); fall through
                }
            }

            # Fall back to gateway IP configurations (subnet where the gateway itself is deployed)
            foreach ($gwIpConfig in $appGw.properties.gatewayIPConfigurations) {
                if ($gwIpConfig.properties.subnet.id) {
                    return $gwIpConfig.properties.subnet.id
                }
            }
        }

        return $null
    }

    #endregion Helper Functions

    #region Data Collection

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose
    $activity = 'Evaluating DDoS Protection diagnostic logging configuration'

    # Check if connected to Azure
    Write-ZtProgress -Activity $activity -Status 'Checking Azure connection'

    $azContext = Get-AzContext -ErrorAction SilentlyContinue
    if (-not $azContext) {
        Write-PSFMessage 'Not connected to Azure.' -Level Warning
        Add-ZtTestResultDetail -SkippedBecause NotConnectedAzure
        return
    }

    # Check the supported environment
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

    # Q1: Query all public IP addresses using Azure Resource Graph
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
    Location=location,
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

    # Check if any Public IP addresses exist
    if ($allPublicIps.Count -eq 0) {
        Write-PSFMessage 'No Public IP addresses found.' -Tag Test -Level VeryVerbose
        Add-ZtTestResultDetail -SkippedBecause NotApplicable
        return
    }

    # Filter and evaluate DDoS-protected public IPs
    Write-ZtProgress -Activity $activity -Status 'Evaluating DDoS protection status'

    $ddosProtectedIps = @()
    $requiredLogCategories = @('DDoSProtectionNotifications', 'DDoSMitigationFlowLogs', 'DDoSMitigationReports')

    foreach ($publicIp in $allPublicIps) {
        $protectionMode = $publicIp.ProtectionMode
        $ipConfigId = $publicIp.IpConfigurationId

        # Skip if DDoS protection is disabled
        if ($protectionMode -eq 'Disabled') {
            continue
        }

        # If protectionMode is "Enabled", it's protected via DDoS IP Protection SKU
        if ($protectionMode -eq 'Enabled') {
            $ddosProtectedIps += [PSCustomObject]@{
                PublicIpName     = $publicIp.PublicIpName
                PublicIpId       = $publicIp.PublicIpId
                Location         = $publicIp.Location
                ProtectionType   = 'IP Protection'
                AssociatedVnet   = 'N/A'
                SubscriptionId   = $publicIp.SubscriptionId
                SubscriptionName = $publicIp.SubscriptionName
            }
            continue
        }

        # If protectionMode is "VirtualNetworkInherited", check if VNET has DDoS protection
        if ($protectionMode -eq 'VirtualNetworkInherited') {
            # Skip orphaned public IPs (not attached to any resource)
            if ([string]::IsNullOrEmpty($ipConfigId)) {
                continue
            }

            # Q2: Get the associated resource to find the subnet/VNET
            $vnetId = $null
            $vnetName = $null

            try {
                # Parse the ipConfiguration to determine resource type and get subnet
                $subnetId = Get-SubnetIdFromIpConfiguration -IpConfigurationId $ipConfigId
                if ($subnetId) {
                    # Extract VNET ID from subnet ID
                    # Subnet ID format: /subscriptions/.../resourceGroups/.../providers/Microsoft.Network/virtualNetworks/{vnetName}/subnets/{subnetName}
                    if ($subnetId -match '(/subscriptions/.+/resourceGroups/.+/providers/Microsoft.Network/virtualNetworks/[^/]+)') {
                        $vnetId = $Matches[1]
                        $vnetName = ($vnetId -split '/')[-1]
                    }
                }
            }
            catch {
                Write-PSFMessage "Error getting subnet for $($publicIp.PublicIpName): $_" -Level Warning
                continue
            }

            # Skip if we couldn't determine the VNET
            if (-not $vnetId) {
                continue
            }

            # Q3: Check if the VNET has DDoS Network Protection enabled
            try {
                $vnetPath = $vnetId + '?api-version=2023-04-01'
                $vnet = Invoke-ZtAzureRequest -Path $vnetPath

                $ddosEnabled = $vnet.properties.enableDdosProtection -eq $true
                $ddosPlanId = $vnet.properties.ddosProtectionPlan.id

                if ($ddosEnabled -and $ddosPlanId) {
                    $ddosProtectedIps += [PSCustomObject]@{
                        PublicIpName     = $publicIp.PublicIpName
                        PublicIpId       = $publicIp.PublicIpId
                        Location         = $publicIp.Location
                        ProtectionType   = 'Network Protection'
                        AssociatedVnet   = $vnetName
                        SubscriptionId   = $publicIp.SubscriptionId
                        SubscriptionName = $publicIp.SubscriptionName
                    }
                }
            }
            catch {
                Write-PSFMessage "Error checking VNET DDoS protection for $($publicIp.PublicIpName): $_" -Level Warning
            }
        }
    }

    # Check if any DDoS-protected public IPs exist
    if ($ddosProtectedIps.Count -eq 0) {
        Write-PSFMessage 'No DDoS-protected Public IP addresses found.' -Tag Test -Level VeryVerbose
        Add-ZtTestResultDetail -SkippedBecause NotApplicable
        return
    }

    # Q4: Get diagnostic settings for each DDoS-protected public IP
    Write-ZtProgress -Activity $activity -Status 'Querying diagnostic settings'

    $evaluationResults = @()

    foreach ($pip in $ddosProtectedIps) {
        $pipId = $pip.PublicIpId
        $pipName = $pip.PublicIpName

        # Query diagnostic settings
        $diagPath = $pipId + '/providers/Microsoft.Insights/diagnosticSettings?api-version=2021-05-01-preview'

        $diagSettings = @()
        try {
            $diagSettings = @(Invoke-ZtAzureRequest -Path $diagPath)
        }
        catch {
            Write-PSFMessage "Error querying diagnostic settings for $pipName : $_" -Level Warning
        }

        # Evaluate diagnostic settings
        $allDestinationTypes = @()
        $hasValidDiagSetting = $false

        foreach ($setting in $diagSettings) {
            $workspaceId = $setting.properties.workspaceId
            $storageAccountId = $setting.properties.storageAccountId
            $eventHubAuthRuleId = $setting.properties.eventHubAuthorizationRuleId

            # Check if destination is configured
            $hasDestination = $workspaceId -or $storageAccountId -or $eventHubAuthRuleId

            if ($hasDestination) {
                # Determine destination types
                $destTypes = @()
                if ($workspaceId) { $destTypes += 'Log Analytics' }
                if ($storageAccountId) { $destTypes += 'Storage' }
                if ($eventHubAuthRuleId) { $destTypes += 'Event Hub' }
                $allDestinationTypes += $destTypes

                # Collect enabled log categories for this single setting
                # Also detect allLogs/audit category groups which cover all required categories
                $settingEnabledCategories = @()
                $hasAllLogsGroup = $false
                foreach ($log in $setting.properties.logs) {
                    if ($log.enabled) {
                        if ($log.categoryGroup -in @('allLogs', 'audit')) {
                            $hasAllLogsGroup = $true
                        }
                        $categoryName = if ($log.category) { $log.category } else { $log.categoryGroup }
                        if ($categoryName) { $settingEnabledCategories += $categoryName }
                    }
                }

                # Per spec: a single setting must cover all three required categories.
                # allLogs/audit category groups implicitly cover all required categories.
                if ($hasAllLogsGroup) {
                    $hasValidDiagSetting = $true
                } else {
                    $missingInThisSetting = @($requiredLogCategories | Where-Object { $_ -notin $settingEnabledCategories })
                    if ($missingInThisSetting.Count -eq 0) {
                        $hasValidDiagSetting = $true
                    }
                }
            }
        }

        # Deduplicate destination types across settings
        $allDestinationTypes = $allDestinationTypes | Select-Object -Unique

        # Per spec: at least one single diagnostic setting must have all three required log
        # categories enabled with a valid destination (categories must not be split across settings)

        $status = if ($hasValidDiagSetting) { 'Pass' } else { 'Fail' }
        $destinationType = if ($allDestinationTypes.Count -gt 0) { $allDestinationTypes -join ', ' } else { 'None' }

        # Collect all enabled categories across all settings (for display/table purposes only)
        # Also detect allLogs/audit category groups which cover all required categories
        $allEnabledCategories = @()
        $anyAllLogsGroup = $false
        foreach ($setting in $diagSettings) {
            foreach ($log in $setting.properties.logs) {
                if ($log.enabled) {
                    if ($log.categoryGroup -in @('allLogs', 'audit')) {
                        $anyAllLogsGroup = $true
                    }
                    $categoryName = if ($log.category) { $log.category } else { $log.categoryGroup }
                    if ($categoryName) { $allEnabledCategories += $categoryName }
                }
            }
        }
        $allEnabledCategories = $allEnabledCategories | Select-Object -Unique

        # Determine enabled status for each required log category (for table display).
        # If allLogs/audit is present in any setting, all categories are implicitly covered.
        $notificationsEnabled = $anyAllLogsGroup -or ('DDoSProtectionNotifications' -in $allEnabledCategories)
        $flowLogsEnabled = $anyAllLogsGroup -or ('DDoSMitigationFlowLogs' -in $allEnabledCategories)
        $reportsEnabled = $anyAllLogsGroup -or ('DDoSMitigationReports' -in $allEnabledCategories)

        $evaluationResults += [PSCustomObject]@{
            SubscriptionId                = $pip.SubscriptionId
            SubscriptionName              = $pip.SubscriptionName
            PublicIpName                  = $pipName
            PublicIpId                    = $pipId
            Location                      = $pip.Location
            ProtectionType                = $pip.ProtectionType
            AssociatedVnet                = $pip.AssociatedVnet
            DiagnosticsConfigured         = $diagSettings.Count -gt 0
            DDoSProtectionNotifications   = $notificationsEnabled
            DDoSMitigationFlowLogs        = $flowLogsEnabled
            DDoSMitigationReports         = $reportsEnabled
            DestinationType               = $destinationType
            Status                        = $status
        }
    }

    #endregion Data Collection

    #region Assessment Logic

    $passedItems = $evaluationResults | Where-Object { $_.Status -eq 'Pass' }
    $failedItems = $evaluationResults | Where-Object { $_.Status -eq 'Fail' }

    $passed = ($failedItems.Count -eq 0) -and ($passedItems.Count -gt 0)

    if ($passed) {
        $testResultMarkdown = "✅ Diagnostic logging is enabled for all DDoS-protected public IP addresses.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "❌ Diagnostic logging is not enabled for one or more DDoS-protected public IP addresses.`n`n%TestResult%"
    }

    #endregion Assessment Logic

    #region Report Generation

    # Portal link variables
    $portalPublicIpBrowseLink = 'https://portal.azure.com/#browse/Microsoft.Network%2FpublicIPAddresses'
    $portalSubscriptionBaseLink = 'https://portal.azure.com/#resource/subscriptions'
    $portalResourceBaseLink = 'https://portal.azure.com/#resource'

    $mdInfo = "`n## [DDoS-protected Public IP diagnostic logging status]($portalPublicIpBrowseLink)`n`n"

    # Public IP Status table
    if ($evaluationResults.Count -gt 0) {
        $tableRows = ""
        $formatTemplate = @'
| Public IP name | Resource ID | Protection type | Associated VNET | Diag. configured | Notifications | Flow logs | Reports | Destination | Status |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
{0}

'@

        # Limit display to first 5 items if there are many public IPs
        $maxItemsToDisplay = 5
        $displayResults = $evaluationResults
        $hasMoreItems = $false
        if ($evaluationResults.Count -gt $maxItemsToDisplay) {
            $displayResults = $evaluationResults | Select-Object -First $maxItemsToDisplay
            $hasMoreItems = $true
        }

        foreach ($result in $displayResults) {
            $pipLink = "[$(Get-SafeMarkdown $result.PublicIpName)]($portalResourceBaseLink$($result.PublicIpId)/diagnostics)"
            $resourceId = Get-SafeMarkdown $result.PublicIpId
            $protectionType = $result.ProtectionType
            $associatedVnet = Get-SafeMarkdown $result.AssociatedVnet
            $diagConfigured = if ($result.DiagnosticsConfigured) { 'Yes' } else { 'No' }
            $notificationsStatus = if ($result.DDoSProtectionNotifications) { '✅' } else { '❌' }
            $flowLogsStatus = if ($result.DDoSMitigationFlowLogs) { '✅' } else { '❌' }
            $reportsStatus = if ($result.DDoSMitigationReports) { '✅' } else { '❌' }
            $destConfigured = if ($result.DestinationType -eq 'None') { 'None' } else { $result.DestinationType }
            $statusText = if ($result.Status -eq 'Pass') { '✅ Pass' } else { '❌ Fail' }

            $tableRows += "| $pipLink | $resourceId | $protectionType | $associatedVnet | $diagConfigured | $notificationsStatus | $flowLogsStatus | $reportsStatus | $destConfigured | $statusText |`n"
        }

        # Add note if more items exist
        if ($hasMoreItems) {
            $remainingCount = $evaluationResults.Count - $maxItemsToDisplay
            $tableRows += "`n... and $remainingCount more. [View all Public IP Addresses in the portal]($portalPublicIpBrowseLink)`n"
        }

        $mdInfo += $formatTemplate -f $tableRows
    }

    # Summary
    $mdInfo += "**Summary:**`n`n"
    $mdInfo += "- Total DDoS-protected Public IPs evaluated: $($evaluationResults.Count)`n"
    $mdInfo += "- Public IPs with complete diagnostic logging: $($passedItems.Count)`n"
    $mdInfo += "- Public IPs missing diagnostic logging: $($failedItems.Count)`n"

    # Replace the placeholder with detailed information
    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo

    #endregion Report Generation

    $params = @{
        TestId = '26886'
        Title  = 'Diagnostic logging is enabled for DDoS-protected public IPs'
        Status = $passed
        Result = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
