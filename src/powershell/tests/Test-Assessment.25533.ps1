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

    # Query Network Interfaces to VNET mapping
    Write-ZtProgress -Activity $activity -Status 'Querying Network Interface associations'

    $nicVnetCache = @{}
    $nicQuery = @"
Resources
| where type =~ 'microsoft.network/networkinterfaces'
| mvexpand ipConfigurations = properties.ipConfigurations
| project
    nicId = tolower(id),
    subnetId = tolower(ipConfigurations.properties.subnet.id)
| extend vnetId = tolower(substring(subnetId, 0, indexof(subnetId, '/subnets/')))
| distinct nicId, vnetId
"@

    try {
        @(Invoke-ZtAzureResourceGraphRequest -Query $nicQuery) | ForEach-Object { $nicVnetCache[$_.nicId] = $_.vnetId }
        Write-PSFMessage "NIC Query returned $($nicVnetCache.Count) records" -Tag Test -Level VeryVerbose
    }
    catch {
        Write-PSFMessage "Network Interface query failed: $($_.Exception.Message)" -Tag Test -Level Warning
    }

    # Query VNET DDoS protection settings
    Write-ZtProgress -Activity $activity -Status 'Querying VNET DDoS settings'

    $vnetDdosCache = @{}
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
                # Rule: If ipConfiguration is missing or null → Fail (unattached, cannot inherit protection)
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

                    # Only NIC-attached public IPs can inherit VNET DDoS protection via this lookup
                    if ($resourceTypeRaw.ToLower() -eq 'networkinterfaces') {
                        # Extract NIC ID and lookup VNET from cache
                        $nicId = ($pip.ipConfigId -split '/ipConfigurations/')[0].ToLower()
                        $vnetId = $nicVnetCache[$nicId]

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
                        else {
                            # VNET not found in cache - no DDoS protection
                            $isCompliant = $false
                            $vnetDdosStatus = 'Disabled'
                        }
                    }
                    else {
                        # Non-NIC associations cannot be evaluated with NIC VNET cache; mark as not applicable
                        $isCompliant = $null
                        $vnetDdosStatus = 'N/A'
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

    $passed = @($findings | Where-Object { -not $_.IsCompliant }).Count -eq 0

    if ($passed) {
        $testResultMarkdown = "✅ DDoS Protection is enabled for all Public IP addresses, either through DDoS IP Protection enabled directly on the public IP or through DDoS Network Protection enabled on the associated VNET.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "❌ DDoS Protection is not enabled for one or more Public IP addresses. This includes public IPs with DDoS protection explicitly disabled, and public IPs that inherit from a VNET that does not have a DDoS Protection Plan enabled.`n`n%TestResult%"
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
            'Enabled' { '✅ Enabled' }
            'Disabled' { '❌ Disabled' }
            'N/A' { 'N/A' }
            default { $item.VnetDdosProtection }
        }

        # Format overall status
        $statusDisplay = if ($item.IsCompliant) { '✅ Pass' } else { '❌ Fail' }

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
