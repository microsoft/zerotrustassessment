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

    Write-PSFMessage 'Start DDoS Public IP Assessment' -Tag Test -Level VeryVerbose

    if ((Get-MgContext).Environment -ne 'Global') {
        Write-PSFMessage "This test is only applicable to the Global environment." -Tag Test -Level VeryVerbose
        return
    }

    #region Azure Connection Verification
    try {
        $accessToken = Get-AzAccessToken -AsSecureString -ErrorAction Stop
    }
    catch {
        Write-PSFMessage $_.Exception.Message -Tag Test -Level Error
        Add-ZtTestResultDetail -SkippedBecause NoAzureAccess
        return
    }
    #endregion

    #region Data Collection
    $subscriptions = Get-AzSubscription
    $publicIpFindings = @()

    foreach ($sub in $subscriptions) {

        Set-AzContext -SubscriptionId $sub.Id | Out-Null

        try {
            $publicIps = Get-AzPublicIpAddress -ErrorAction Stop
        }
        catch {
            Write-PSFMessage "Unable to list Public IPs in subscription $($sub.Name)." -Tag Test -Level Warning
            continue
        }

        foreach ($pip in $publicIps) {

            $protectionMode = $null
            $source = 'None'

            # Case 1: Explicit DDoS IP protection
            if ($pip.DdosSettings -and $pip.DdosSettings.ProtectionMode) {
                $protectionMode = $pip.DdosSettings.ProtectionMode
                $source = 'PublicIP'
            }

            # Case 2: VNET inherited protection
            elseif ($pip.IpConfiguration -and $pip.IpConfiguration.Id) {

                try {
                    $vnet = Get-AzVirtualNetwork -ResourceGroupName $pip.ResourceGroupName -ErrorAction Stop
                    if ($vnet.EnableDdosProtection) {
                        $protectionMode = 'VirtualNetworkInherited'
                        $source = 'VNET'
                        $vnet.EnableDdosProtection
                    }
                }
                catch {
                    Write-PSFMessage "Failed to resolve VNET for Public IP $($pip.Name)" -Tag Test -Level Debug
                }
            }

            $isCompliant = $protectionMode -in @('Enabled', 'VirtualNetworkInherited')

            $publicIpFindings += [PSCustomObject]@{
                PublicIpName     = $pip.Name
                PublicIpId       = $pip.Id
                Location         = $pip.Location
                AllocationMethod = $pip.PublicIpAllocationMethod
                ProtectionMode   = if ($protectionMode) { $protectionMode } else { 'NotEnabled' }
                ProtectionSource = $source
                IsCompliant      = $isCompliant
                SubscriptionId   = $sub.Id
                SubscriptionName = $sub.Name
            }
        }
    }
    #endregion

    #region Assessment Logic
    if ($publicIpFindings.Count -eq 0) {
        Add-ZtTestResultDetail -TestId '25533' -Status $true -Result "No Public IP addresses found."
        return
    }

    $nonCompliant = $publicIpFindings | Where-Object { -not $_.IsCompliant }
    $passed = ($nonCompliant.Count -eq 0)

    $testResultMarkdown = if ($passed) {
        "DDoS Protection is enabled for all Public IP addresses.`n`n%TestResult%"
    }
    else {
        "DDoS Protection is NOT enabled for one or more Public IP addresses.`n`n%TestResult%"
    }
    #endregion

    #region Result Reporting
    $mdInfo = "## Public IP Address DDoS Protection Status`n`n"
    $mdInfo += "| Public IP | Location | Allocation | Protection Mode | Source | Status |`n"
    $mdInfo += "| :--- | :--- | :--- | :--- | :--- | :--- |`n"

    foreach ($item in $publicIpFindings | Sort-Object PublicIpName) {

        $icon = if ($item.IsCompliant) { '✅' } else { '❌' }
        $pipLink = "https://portal.azure.com/#@/resource$($item.PublicIpId)"
        $safeName = Get-SafeMarkdown -Text $item.PublicIpName

        $mdInfo += "| $icon [$safeName]($pipLink) | $($item.Location) | $($item.AllocationMethod) | $($item.ProtectionMode) | $($item.ProtectionSource) | $icon |`n"
    }


    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo
    Add-ZtTestResultDetail -TestId '25533' -Status $passed -Result $testResultMarkdown
    #endregion
}
