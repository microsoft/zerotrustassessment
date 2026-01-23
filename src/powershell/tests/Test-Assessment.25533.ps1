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
    Write-ZtProgress -Activity $activity -Status 'Checking Azure connection'

    # --- Azure connection & ARM endpoint ---
    try {
        $context = Get-AzContext -ErrorAction Stop

        if ($context.Environment.Name -ne 'AzureCloud') {
            throw "Unsupported Azure environment: $($context.Environment.Name)"
        }

        $resourceManagementUrl = $context.Environment.ResourceManagerUrl.TrimEnd('/')
    }
    catch {
        Add-ZtTestResultDetail -SkippedBecause NotConnectedAzure
        return
    }

    # --- Get subscriptions ---
    Write-ZtProgress -Activity $activity -Status 'Getting Azure subscriptions'
    $subscriptions = @()

    try {
        $subscriptionsUri = "$resourceManagementUrl/subscriptions?api-version=2022-12-01"
        $subscriptionsResponse = Invoke-AzRestMethod -Method GET -Uri $subscriptionsUri -ErrorAction Stop

        if ($subscriptionsResponse.StatusCode -ne 200) {
            throw "Failed to retrieve subscriptions. StatusCode=$($subscriptionsResponse.StatusCode)"
        }

        $subscriptions = ($subscriptionsResponse.Content | ConvertFrom-Json).value
    }
    catch {
        Write-PSFMessage $_ -Level Error
        Add-ZtTestResultDetail -SkippedBecause NoAzureAccess
        return
    }

    if (-not $subscriptions -or $subscriptions.Count -eq 0) {
        Add-ZtTestResultDetail -SkippedBecause NoAzureAccess
        return
    }

    # --- Collect Public IPs ---
    $publicIpFindings = @()

    foreach ($sub in $subscriptions) {
        Write-ZtProgress -Activity $activity -Status "Processing subscription: $($sub.displayName)"

        $publicIpsUri = "$resourceManagementUrl/subscriptions/$($sub.subscriptionId)/providers/Microsoft.Network/publicIPAddresses?api-version=2025-03-01"

        try {
            $publicIpsResponse = Invoke-AzRestMethod -Method GET -Uri $publicIpsUri -ErrorAction Stop

            if ($publicIpsResponse.StatusCode -lt 200 -or $publicIpsResponse.StatusCode -ge 300) {
                Write-PSFMessage "Failed to list Public IPs in $($sub.displayName)" -Level Warning
                continue
            }

            $publicIps = ($publicIpsResponse.Content | ConvertFrom-Json).value
        }
        catch {
            Write-PSFMessage $_ -Level Warning
            continue
        }

        foreach ($pip in $publicIps) {
            $protectionMode = if (
                $pip.properties.ddosSettings -and
                $pip.properties.ddosSettings.protectionMode
            ) {
                $pip.properties.ddosSettings.protectionMode
            }
            else {
                'Disabled'
            }

            $publicIpFindings += [PSCustomObject]@{
                PublicIpName     = $pip.name
                PublicIpId       = $pip.id
                Location         = $pip.location
                ProtectionMode   = $protectionMode
                IsCompliant      = $protectionMode -in @('VirtualNetworkInherited', 'Enabled')
                SubscriptionId   = $sub.subscriptionId
                SubscriptionName = $sub.displayName
            }
        }
    }
    #endregion Data Collection

    #region Assessment Logic
    if ($publicIpFindings.Count -eq 0) {
        Add-ZtTestResultDetail -TestId 25533 -Status $false -Result 'No Public IP addresses found.'
        return
    }

    $nonCompliant = $publicIpFindings | Where-Object { -not $_.IsCompliant }
    $passed = ($nonCompliant.Count -eq 0)

    if ($passed) {
        $testResultMarkdown = "DDoS Protection is enabled for all Public IP addresses.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "DDoS Protection is not enabled for one or more Public IP addresses.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    $mdInfo  = "## Public IP Address DDoS Protection Details`n`n"
    $mdInfo += "| | Public IP address name and id | DdosSettingsProtectionMode value |`n"
    $mdInfo += "| :--- | :--- | :--- |`n"

    foreach ($item in $publicIpFindings | Sort-Object IsCompliant, PublicIpName) {
        $icon     = if ($item.IsCompliant) { '✅' } else { '❌' }
        $pipLink  = "https://portal.azure.com/#@/resource$($item.PublicIpId)"
        $safeName = Get-SafeMarkdown -Text $item.PublicIpName

        $mdInfo += "| $icon | [$safeName]($pipLink) | ``$($item.ProtectionMode)`` |`n"
    }

    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    # --- Final result (splatted) ---
    $params = @{
        TestId = 25533
        Status = $passed
        Title  = 'DDoS Protection is enabled for all Public IP Addresses in VNETs'
        Result = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
