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

    # Initialize test variables
    $passed = $null
    $testResultMarkdown = ''
    $subscriptions = @()
    $publicIpFindings = @()

    # ---- Azure connection ----
    try {
        $context = Get-AzContext -ErrorAction Stop

        if (-not $context.Environment -or $context.Environment.Name -ne 'AzureCloud') {
            throw 'Unsupported Azure environment'
        }

        $resourceManagementUrl = $context.Environment.ResourceManagerUrl.TrimEnd('/')
    }
    catch {
        #----- Scenario : Not connected to Azure -----
        Add-ZtTestResultDetail -SkippedBecause NotConnectedAzure
        return
    }

    # ---- Get subscriptions ----
    Write-ZtProgress -Activity $activity -Status 'Getting Azure subscriptions'
    try {
        $uri = "$resourceManagementUrl/subscriptions?api-version=2022-12-01"
        $response = Invoke-AzRestMethod -Method GET -Uri $uri -ErrorAction Stop
        $subscriptions = @((($response.Content | ConvertFrom-Json).value))
    }
    catch {
        $testResultMarkdown = "Failed to retrieve Azure subscriptions: $($_.Exception.Message)"
        $passed = $false
    }

    # ---- Collect Public IPs from subscriptions ----
    if ($passed -ne $false -and $subscriptions.Count -gt 0) {
        foreach ($sub in $subscriptions) {
            Write-ZtProgress -Activity $activity -Status "Processing subscription: $($sub.displayName)"

            try {
                $publicIpsUri = "$resourceManagementUrl/subscriptions/$($sub.subscriptionId)/providers/Microsoft.Network/publicIPAddresses?api-version=2025-03-01"
                $publicIpsResponse = Invoke-AzRestMethod -Method GET -Uri $publicIpsUri -ErrorAction Stop
            }
            catch {
                Write-PSFMessage "Error calling Public IP API for $($sub.displayName): $($_.Exception.Message)" -Level Warning
                continue
            }

            $body = $publicIpsResponse.Content | ConvertFrom-Json
            $publicIps = $body.value

             #----- Scenario : No Public IPs found (Skip)-----
            #
            if (-not $publicIps) {
                continue
            }

            # Collect Public IPs from this subscription
            foreach ($pip in $publicIps) {
                $mode = if (
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
                    ProtectionMode   = $mode
                    IsCompliant      = $mode -in @('VirtualNetworkInherited', 'Enabled')
                    SubscriptionName = $sub.displayName
                }
            }
        }
    }
    #endregion Data Collection

    #region Assessment Logic
    if ($subscriptions.Count -eq 0) {
         #----- Scenario : No subscriptions found - Skip
        $testResultMarkdown = 'The Signed in user does not have any active Azure subscription to perform test.'
        Add-ZtTestResultDetail -SkippedBecause NotConnectedAzure -Result $testResultMarkdown
        return
    }

    elseif ($publicIpFindings.Count -eq 0) {
         #----- Scenario :Subscriptions exist but no Public IPs - SKIP
        $testResultMarkdown = 'No Public IP addresses were found in any subscriptions.'
        Add-ZtTestResultDetail -SkippedBecause NotSupported -Result $testResultMarkdown
        return
    }
    else {
        # Public IPs found - evaluate compliance
        $nonCompliant = $publicIpFindings | Where-Object { -not $_.IsCompliant }

        if ($nonCompliant.Count -eq 0) {
            $passed = $true
            $testResultMarkdown = "✅ DDoS Protection is enabled for all Public IP addresses.`n`n%TestResult%"
        }
        else {
            $passed = $false
            $testResultMarkdown = "❌ DDoS Protection is not enabled for one or more Public IP addresses.`n`n%TestResult%"
        }
    }
    #endregion Assessment Logic

    #region Report Generation
    $mdInfo = ''

    if ($publicIpFindings.Count -gt 0) {
        $mdInfo = "## Public IP Address DDoS Protection Details`n`n"
        $mdInfo += "| | Public IP name | Protection Mode |`n"
        $mdInfo += "| :--- | :--- | :--- |`n"

        foreach ($item in $publicIpFindings | Sort-Object IsCompliant, PublicIpName) {
            $icon = if ($item.IsCompliant) { '✅' } else { '❌' }
            $link = "https://portal.azure.com/#@/resource$($item.PublicIpId)"

            $mdInfo += "| $icon | [$($item.PublicIpName)]($link) | $($item.ProtectionMode) |`n"
        }
    }

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
