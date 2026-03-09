function Test-Assessment-25533 {
    [ZtTest(
        Category = 'Azure Network Security',
        ImplementationCost = 'Low',
        MinimumLicense = ('DDoS_Network_Protection', 'DDoS_IP_Protection'),
        Pillar = 'Network',
        RiskLevel = 'High',
        SfiPillar = 'Protect networks',
        TenantType = ('Workforce', 'External'),
        TestId = 25533,
        Title = 'DDoS Protection is enabled for all Public IP Addresses in VNETs',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking DDoS Protection is enabled for all Public IP Addresses in VNETs'

    # Check if connected to Azure
    Write-ZtProgress -Activity $activity -Status 'Checking Azure connection'

    $azContext = Get-AzContext -ErrorAction SilentlyContinue
    if (-not $azContext) {
        Write-PSFMessage 'Not connected to Azure.' -Level Warning
        Add-ZtTestResultDetail -SkippedBecause NotConnectedAzure
        return
    }

    Write-ZtProgress -Activity $activity -Status 'Querying Azure Resource Graph'

    # Query all Public IP addresses with their DDoS protection settings
    $argQuery = @"
Resources
| where type =~ 'microsoft.network/publicipaddresses' | join kind=leftouter (ResourceContainers | where type =~ 'microsoft.resources/subscriptions' | project subscriptionName=name, subscriptionId ) on subscriptionId | project PublicIpName = name, PublicIpId = id, SubscriptionName = subscriptionName, SubscriptionId = subscriptionId, Location = location, ProtectionMode = tostring(properties.ddosSettings.protectionMode), ipConfigId = tolower(properties.ipConfiguration.id)
"@

    $publicIps = @()
    try {
        $publicIps = @(Invoke-ZtAzureResourceGraphRequest -Query $argQuery)
        Write-PSFMessage "ARG Query returned $($publicIps.Count) records" -Tag Test -Level VeryVerbose
    }
    catch {
        Write-PSFMessage "Azure Resource Graph query failed: $($_.Exception.Message)" -Tag Test -Level Warning
        Add-ZtTestResultDetail -SkippedBecause NotSupported
        return
    }

    # Skip if no public IPs found
    if ($publicIps.Count -eq 0) {
        Write-PSFMessage 'No Public IP addresses found.' -Tag Test -Level Verbose
        Add-ZtTestResultDetail -SkippedBecause NotApplicable
        return
    }

    # Build unified resource-to-VNET mapping cache for all supported resource types.
    # Each query populates the same hashtable keyed by resource ID (lowercase).
    # $resourceQueryFailed tracks whether any prerequisite query failed so we can
    # avoid marking affected IPs as non-compliant due to transient ARG/RBAC issues.
    Write-ZtProgress -Activity $activity -Status 'Querying resource-to-VNET associations'

    $resourceVnetCache = @{}
    $resourceQueryFailed = $false

    # NICs — subnet in ipConfigurations[].properties.subnet.id
    $nicQuery = @"
Resources
| where type =~ 'microsoft.network/networkinterfaces'
| mvexpand ipConfigurations = properties.ipConfigurations
| project
    resourceId = tolower(id),
    subnetId = tolower(ipConfigurations.properties.subnet.id)
| extend vnetId = tolower(substring(subnetId, 0, indexof(subnetId, '/subnets/')))
| distinct resourceId, vnetId
"@
    try {
        @(Invoke-ZtAzureResourceGraphRequest -Query $nicQuery) | ForEach-Object { $resourceVnetCache[$_.resourceId] = $_.vnetId }
        Write-PSFMessage "NIC query: $($resourceVnetCache.Count) records in cache" -Tag Test -Level VeryVerbose
    }
    catch {
        Write-PSFMessage "Network Interface query failed: $($_.Exception.Message)" -Tag Test -Level Warning
        $resourceQueryFailed = $true
    }

    # Application Gateways — subnet in gatewayIPConfigurations[].properties.subnet.id
    $appGwQuery = @"
Resources
| where type =~ 'microsoft.network/applicationgateways'
| mvexpand gwIpConfig = properties.gatewayIPConfigurations
| project
    resourceId = tolower(id),
    subnetId = tolower(gwIpConfig.properties.subnet.id)
| extend vnetId = tolower(substring(subnetId, 0, indexof(subnetId, '/subnets/')))
| distinct resourceId, vnetId
"@
    try {
        @(Invoke-ZtAzureResourceGraphRequest -Query $appGwQuery) | ForEach-Object { $resourceVnetCache[$_.resourceId] = $_.vnetId }
        Write-PSFMessage "Application Gateway query: $($resourceVnetCache.Count) records in cache" -Tag Test -Level VeryVerbose
    }
    catch {
        Write-PSFMessage "Application Gateway query failed: $($_.Exception.Message)" -Tag Test -Level Warning
        $resourceQueryFailed = $true
    }

    # Azure Firewalls — subnet in ipConfigurations[].properties.subnet.id
    $firewallQuery = @"
Resources
| where type =~ 'microsoft.network/azurefirewalls'
| mvexpand ipConfig = properties.ipConfigurations
| project
    resourceId = tolower(id),
    subnetId = tolower(ipConfig.properties.subnet.id)
| extend vnetId = tolower(substring(subnetId, 0, indexof(subnetId, '/subnets/')))
| distinct resourceId, vnetId
"@
    try {
        @(Invoke-ZtAzureResourceGraphRequest -Query $firewallQuery) | ForEach-Object { $resourceVnetCache[$_.resourceId] = $_.vnetId }
        Write-PSFMessage "Azure Firewall query: $($resourceVnetCache.Count) records in cache" -Tag Test -Level VeryVerbose
    }
    catch {
        Write-PSFMessage "Azure Firewall query failed: $($_.Exception.Message)" -Tag Test -Level Warning
        $resourceQueryFailed = $true
    }

    # Bastion Hosts — subnet in ipConfigurations[].properties.subnet.id
    $bastionQuery = @"
Resources
| where type =~ 'microsoft.network/bastionhosts'
| mvexpand ipConfig = properties.ipConfigurations
| project
    resourceId = tolower(id),
    subnetId = tolower(ipConfig.properties.subnet.id)
| extend vnetId = tolower(substring(subnetId, 0, indexof(subnetId, '/subnets/')))
| distinct resourceId, vnetId
"@
    try {
        @(Invoke-ZtAzureResourceGraphRequest -Query $bastionQuery) | ForEach-Object { $resourceVnetCache[$_.resourceId] = $_.vnetId }
        Write-PSFMessage "Bastion Host query: $($resourceVnetCache.Count) records in cache" -Tag Test -Level VeryVerbose
    }
    catch {
        Write-PSFMessage "Bastion Host query failed: $($_.Exception.Message)" -Tag Test -Level Warning
        $resourceQueryFailed = $true
    }

    # Virtual Network Gateways — subnet in ipConfigurations[].properties.subnet.id
    $vnetGwQuery = @"
Resources
| where type =~ 'microsoft.network/virtualnetworkgateways'
| mvexpand ipConfig = properties.ipConfigurations
| project
    resourceId = tolower(id),
    subnetId = tolower(ipConfig.properties.subnet.id)
| extend vnetId = tolower(substring(subnetId, 0, indexof(subnetId, '/subnets/')))
| distinct resourceId, vnetId
"@
    try {
        @(Invoke-ZtAzureResourceGraphRequest -Query $vnetGwQuery) | ForEach-Object { $resourceVnetCache[$_.resourceId] = $_.vnetId }
        Write-PSFMessage "VNet Gateway query: $($resourceVnetCache.Count) records in cache" -Tag Test -Level VeryVerbose
    }
    catch {
        Write-PSFMessage "Virtual Network Gateway query failed: $($_.Exception.Message)" -Tag Test -Level Warning
        $resourceQueryFailed = $true
    }

    # Load Balancers — public LBs have no subnet on frontendIPConfigurations;
    # resolve VNET by tracing backend pool NICs (already cached above).
    $lbQuery = @"
Resources
| where type =~ 'microsoft.network/loadbalancers'
| mvexpand backendPool = properties.backendAddressPools
| mvexpand backendIpConfig = backendPool.properties.backendIPConfigurations
| project
    lbId = tolower(id),
    nicIpConfigId = tolower(backendIpConfig.id)
| extend nicId = tolower(substring(nicIpConfigId, 0, indexof(nicIpConfigId, '/ipconfigurations/')))
| distinct lbId, nicId
"@
    try {
        $lbNicMappings = @(Invoke-ZtAzureResourceGraphRequest -Query $lbQuery)
        foreach ($mapping in $lbNicMappings) {
            $nicVnet = $resourceVnetCache[$mapping.nicId]
            if ($nicVnet -and -not $resourceVnetCache.ContainsKey($mapping.lbId)) {
                $resourceVnetCache[$mapping.lbId] = $nicVnet
            }
        }
        Write-PSFMessage "Load Balancer query: $($resourceVnetCache.Count) records in cache" -Tag Test -Level VeryVerbose
    }
    catch {
        Write-PSFMessage "Load Balancer query failed: $($_.Exception.Message)" -Tag Test -Level Warning
        $resourceQueryFailed = $true
    }

    # Query VNET DDoS protection settings
    Write-ZtProgress -Activity $activity -Status 'Querying VNET DDoS settings'

    $vnetDdosCache = @{}
    $vnetQueryFailed = $false
    $vnetQuery = @"
Resources
| where type =~ 'microsoft.network/virtualnetworks'
| project
    vnetId = tolower(id),
    vnetName = name,
    isDdosEnabled = (properties.enableDdosProtection == true),
    hasDdosPlan = isnotempty(properties.ddosProtectionPlan.id)
"@
    try {
        @(Invoke-ZtAzureResourceGraphRequest -Query $vnetQuery) | ForEach-Object { $vnetDdosCache[$_.vnetId] = $_ }
        Write-PSFMessage "VNET Query returned $($vnetDdosCache.Count) records" -Tag Test -Level VeryVerbose
    }
    catch {
        Write-PSFMessage "VNET DDoS query failed: $($_.Exception.Message)" -Tag Test -Level Warning
        $vnetQueryFailed = $true
    }
    #endregion Data Collection

    #region Assessment Logic
    $findings = @()

    # Evaluate each public IP for DDoS compliance
    foreach ($pip in $publicIps) {
        $protectionMode = if ([string]::IsNullOrWhiteSpace($pip.ProtectionMode)) { 'Disabled' } else { $pip.ProtectionMode }
        $resourceType = 'N/A'
        $vnetName = 'N/A'
        $vnetDdosStatus = 'N/A'
        $isCompliant = $false

        if ($protectionMode -eq 'Enabled') {
            # Rule: If protectionMode is "Enabled" → Pass (DDoS IP Protection is directly enabled)
            $isCompliant = $true
        }
        elseif ($protectionMode -eq 'Disabled') {
            # Rule: If protectionMode is "Disabled" → Fail (no protection)
            $isCompliant = $false
        }
        elseif ($protectionMode -eq 'VirtualNetworkInherited') {
            # Rule: If protectionMode is "VirtualNetworkInherited"
            if ([string]::IsNullOrWhiteSpace($pip.ipConfigId)) {
                # Rule: If ipConfiguration is missing or null → Fail (unattached, cannot inherit protection from any VNET)
                $isCompliant = $false
                $vnetDdosStatus = 'N/A'
            }
            else {
                # Rule: If ipConfiguration.id exists
                if ($pip.ipConfigId -match '/providers/microsoft\.network/([^/]+)/') {
                    # Parse the resource type from ipConfiguration.id
                    $resourceTypeRaw = $matches[1]
                    $typeMap = @{
                        'networkinterfaces'         = 'Network Interface'
                        'applicationgateways'       = 'Application Gateway'
                        'loadbalancers'             = 'Load Balancer'
                        'azurefirewalls'            = 'Azure Firewall'
                        'bastionhosts'              = 'Azure Bastion'
                        'virtualnetworkgateways'    = 'Virtual Network Gateway'
                    }
                    $resourceType = $typeMap[$resourceTypeRaw.ToLower()]
                    if (-not $resourceType) {
                        $resourceType = $resourceTypeRaw
                    }

                    # Extract the parent resource ID from ipConfiguration.id.
                    # Handles all three config segment names used across resource types:
                    #   /ipConfigurations/          — NICs, Firewalls, Bastion, VNet Gateways
                    #   /frontendIPConfigurations/  — Load Balancers, Application Gateways (public IP side)
                    #   /gatewayIPConfigurations/   — Application Gateways (subnet side)
                    if ($pip.ipConfigId -match '(/subscriptions/[^/]+/resourcegroups/[^/]+/providers/microsoft\.network/[^/]+/[^/]+)/(ipconfigurations|frontendipconfigurations|gatewayipconfigurations)/') {
                        $parentResourceId = $matches[1].ToLower()
                    }
                    else {
                        # Fallback split for any unrecognised pattern
                        $parentResourceId = ($pip.ipConfigId -split '/(ipconfigurations|frontendipconfigurations|gatewayipconfigurations)/')[0].ToLower()
                    }

                    $vnetId = $resourceVnetCache[$parentResourceId]

                    if ($vnetId -and $vnetDdosCache.ContainsKey($vnetId)) {
                        # Rule: If properties.enableDdosProtection == true AND properties.ddosProtectionPlan.id exists → Pass
                        # Rule: If properties.enableDdosProtection == false OR properties.ddosProtectionPlan.id is missing → Fail
                        $vnet = $vnetDdosCache[$vnetId]
                        $vnetName = $vnet.vnetName

                        if ($vnet.isDdosEnabled -eq $true -and $vnet.hasDdosPlan -eq $true) {
                            $isCompliant = $true
                            $vnetDdosStatus = 'Enabled'
                        }
                        else {
                            $isCompliant = $false
                            $vnetDdosStatus = 'Disabled'
                        }
                    }
                    elseif ($resourceQueryFailed -or $vnetQueryFailed) {
                        # A prerequisite query failed — mark Unknown to avoid a false non-compliance
                        # result caused by a transient ARG or RBAC error.
                        $isCompliant = $null
                        $vnetDdosStatus = 'Unknown'
                    }
                    else {
                        # Queries succeeded but resource not in cache — VNET has no DDoS protection
                        $isCompliant = $false
                        $vnetDdosStatus = 'Disabled'
                    }
                }
                else {
                    # Could not parse resource type
                    $isCompliant = $false
                }
            }
        }

        $findings += [PSCustomObject]@{
            PublicIpName           = $pip.PublicIpName
            PublicIpId             = $pip.PublicIpId
            SubscriptionName       = $pip.SubscriptionName
            SubscriptionId         = $pip.SubscriptionId
            ProtectionMode         = $protectionMode
            AssociatedResourceType = $resourceType
            AssociatedVnetName     = $vnetName
            VnetDdosProtection     = $vnetDdosStatus
            IsCompliant            = $isCompliant
        }
    }

    $failedCount = @($findings | Where-Object { $_.IsCompliant -eq $false }).Count
    $unknownCount = @($findings | Where-Object { $null -eq $_.IsCompliant }).Count

    # A test only "passes" when there are no failures and no unknowns.
    $passed = ($failedCount -eq 0 -and $unknownCount -eq 0)

    if ($passed) {
        $testResultMarkdown = "✅ DDoS Protection is enabled for all Public IP addresses, either through DDoS IP Protection enabled directly on the public IP or through DDoS Network Protection enabled on the associated VNET.`n`n%TestResult%"
    }
    else {
        $failMessage = "❌ DDoS Protection is not enabled for one or more Public IP addresses. This includes public IPs with DDoS protection explicitly disabled, and public IPs that inherit from a VNET that does not have a DDoS Protection Plan enabled."
        if ($unknownCount -gt 0) {
            $failMessage += " $unknownCount public IP(s) could not be fully evaluated due to query failures and require manual verification."
        }
        $testResultMarkdown = "$failMessage`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    $formatTemplate = @'

## [{0}]({1})

| Public IP name | DDoS protection mode | Resource type | Associated VNET | VNET DDoS protection | Status |
| :--- | :--- | :--- | :--- | :--- | :---: |
{2}

'@

    $reportTitle = 'Public IP addresses DDoS protection status'
    $portalLink = 'https://portal.azure.com/#view/HubsExtension/BrowseResource/resourceType/Microsoft.Network%2FpublicIPAddresses'

    # Prepare table rows
    $tableRows = ''
    foreach ($item in $findings | Sort-Object @{Expression = 'IsCompliant'; Descending = $false}, 'PublicIpName') {
        $pipLink = "https://portal.azure.com/#resource$($item.PublicIpId)"
        $pipMd = "[$(Get-SafeMarkdown $item.PublicIpName)]($pipLink)"

        # Format protection mode
        $protectionDisplay = switch ($item.ProtectionMode) {
            'Enabled' { '✅ Enabled' }
            'VirtualNetworkInherited' { 'VirtualNetworkInherited' }
            'Disabled' { '❌ Disabled' }
            default { $item.ProtectionMode }
        }

        # Format resource type
        $resourceTypeDisplay = if ($item.AssociatedResourceType -eq 'N/A') { 'N/A' } else { $item.AssociatedResourceType }

        # Format VNET name
        $vnetDisplay = if ($item.AssociatedVnetName -eq 'N/A' -or [string]::IsNullOrWhiteSpace($item.AssociatedVnetName)) { 'N/A' } else { Get-SafeMarkdown $item.AssociatedVnetName }

        # Format VNET DDoS status
        $vnetDdosDisplay = switch ($item.VnetDdosProtection) {
            'Enabled'  { '✅ Enabled' }
            'Disabled' { '❌ Disabled' }
            'Unknown'  { '⚠️ Unknown' }
            'N/A'      { 'N/A' }
            default    { $item.VnetDdosProtection }
        }

        # Format overall status
        $statusDisplay = if ($null -eq $item.IsCompliant) { '⚠️ Unknown' } elseif ($item.IsCompliant) { '✅ Pass' } else { '❌ Fail' }

        $tableRows += "| $pipMd | $protectionDisplay | $resourceTypeDisplay | $vnetDisplay | $vnetDdosDisplay | $statusDisplay |`n"
    }

    $mdInfo = $formatTemplate -f $reportTitle, $portalLink, $tableRows
    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '25533'
        Title  = 'DDoS Protection is enabled for all Public IP Addresses in VNETs'
        Status = $passed
        Result = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
