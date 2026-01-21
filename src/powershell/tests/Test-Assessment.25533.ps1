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
    $activity = "Checking DDoS Protection is enabled for all Public IP Addresses in VNETs"
    Write-ZtProgress -Activity $activity -Status "Checking Azure connection"

    # Check Azure connection
    try {
        $accessToken = Get-AzAccessToken -AsSecureString -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
    }
    catch  {
        Write-PSFMessage $_.Exception.Message -Tag Test -Level Error
    }

    if (!$accessToken) {
        Write-PSFMessage "Azure authentication token not found." -Level Warning
        Add-ZtTestResultDetail -SkippedBecause NoAzureAccess
        return
    }

    # Get Azure subscriptions
    Write-ZtProgress -Activity $activity -Status "Getting Azure subscriptions"

    $resourceManagementUrl = (Get-AzContext).Environment.ResourceManagerUrl
    $subscriptionsUri = $resourceManagementUrl + 'subscriptions?api-version=2022-12-01'

    try {
        $subscriptionsResponse = Invoke-AzRestMethod -Method GET -Uri $subscriptionsUri -ErrorAction Stop

        # Check if the response was successful
        if ($subscriptionsResponse.StatusCode -lt 200 -or $subscriptionsResponse.StatusCode -ge 300) {
            throw "API returned status code: $($subscriptionsResponse.StatusCode). Content: $($subscriptionsResponse.Content)"
        }

        $subscriptions = ($subscriptionsResponse.Content | ConvertFrom-Json).value
    }
    catch {
        Write-PSFMessage "Failed to retrieve Azure subscriptions: $_" -Level Error
        Add-ZtTestResultDetail -SkippedBecause NoAzureAccess
        return
    }

    if (!$subscriptions -or $subscriptions.Count -eq 0) {
        Write-PSFMessage "No Azure subscriptions found." -Level Warning
        $customStatus = 'Investigate'

    }

    $publicIpFindings = @()

    foreach ($sub in $subscriptions) {
        Write-ZtProgress -Activity $activity -Status "Processing subscription: $($sub.displayName)"

        $publicIpsUri = $resourceManagementUrl + "subscriptions/$($sub.subscriptionId)/providers/Microsoft.Network/publicIPAddresses?api-version=2025-03-01"

        try {
            $publicIpsResponse = Invoke-AzRestMethod -Method GET -Uri $publicIpsUri -ErrorAction Stop

            # Check if the response was successful
            if ($publicIpsResponse.StatusCode -lt 200 -or $publicIpsResponse.StatusCode -ge 300) {
                Write-PSFMessage "Unable to list Public IPs in subscription $($sub.displayName) - Status Code: $($publicIpsResponse.StatusCode)" -Tag Test -Level Warning
                continue
            }

            $publicIps = ($publicIpsResponse.Content | ConvertFrom-Json).value
        }
        catch {
            Write-PSFMessage "Unable to list Public IPs in subscription $($sub.displayName): $_" -Tag Test -Level Warning
            continue
        }

        foreach ($pip in $publicIps) {
            $protectionMode = 'Disabled'

            # Check ddosSettings property as per API documentation
            if ($pip.properties.ddosSettings -and $pip.properties.ddosSettings.protectionMode) {
                $protectionMode = $pip.properties.ddosSettings.protectionMode
            }

            # Determine compliance: Pass if VirtualNetworkInherited or Enabled
            # Fail if Disabled or missing
            $isCompliant = $protectionMode -in @('VirtualNetworkInherited', 'Enabled')

            $publicIpFindings += [PSCustomObject]@{
                PublicIpName     = $pip.name
                PublicIpId       = $pip.id
                Location         = $pip.location
                ProtectionMode   = $protectionMode
                IsCompliant      = $isCompliant
                SubscriptionId   = $sub.subscriptionId
                SubscriptionName = $sub.displayName
            }
        }
    }
    #endregion Data Collection

    #region Assessment Logic
    # Initialize test variables
    $testResultMarkdown = ''
    $passed = $false

    # Check if no public IPs found
    if ($publicIpFindings.Count -eq 0) {
        Add-ZtTestResultDetail -TestId '25533' -Status $true -Result "No Public IP addresses found."
        return
    }

    # Determine pass/fail status
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
    $mdInfo = "## Public IP Address DDoS Protection Details`n`n"
    $mdInfo += "| | Public IP address name and id | DdosSettingsProtectionMode value |`n"
    $mdInfo += "| :--- | :--- | :--- |`n"

    foreach ($item in $publicIpFindings | Sort-Object IsCompliant, PublicIpName) {
        $icon = if ($item.IsCompliant) { '✅' } else { '❌' }
        $pipLink = "https://portal.azure.com/#@/resource$($item.PublicIpId)"
        $safeName = Get-SafeMarkdown -Text $item.PublicIpName

        $mdInfo += "| $icon | [$safeName]($pipLink) | ``$($item.ProtectionMode)`` |`n"
    }

    # Replace the placeholder with detailed information
    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo

    # Add test result details

    #endregion Report Generation
    $params = @{
        TestId = '25533'
        Status = $passed
        Title = 'DDoS Protection is enabled for all Public IP Addresses in VNETs'
        Result = $testResultMarkdown
    }
    Add-ZtTestResultDetail @params
}
