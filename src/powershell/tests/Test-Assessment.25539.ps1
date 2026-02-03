<#
.SYNOPSIS
    Validates Intrusion Detection is Enabled in Deny Mode on Azure Firewall.
.DESCRIPTION
    This test validates that Azure Firewall Policies have Intrusion Detection enabled in Deny mode.
    Checks all firewall policies in the subscription and reports their intrusion detection status.
.NOTES
    Test ID: 25539
    Category: Azure Network Security
    Required API: Azure Firewall Policies
#>

function Test-Assessment-25539 {
    [ZtTest(
        Category = 'Azure Network Security',
        ImplementationCost = 'Low',
        MinimumLicense = ('Azure_Firewall_Premium'),
        Pillar = 'Network',
        RiskLevel = 'High',
        SfiPillar = 'Protect networks',
        TenantType = ('Workforce','External'),
        TestId = 25539,
        Title = 'IDPS Inspection is Enabled in Deny Mode on Azure Firewall',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    #region Data Collection
    $activity = 'Azure Firewall Intrusion Detection'
    Write-ZtProgress `
        -Activity $activity `
        -Status 'Checking Azure connection'

    # Check if connected to Azure
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

    Write-ZtProgress `
        -Activity $activity `
        -Status 'Enumerating Firewall Policies'

    # Query subscriptions using REST API
    $resourceManagerUrl = $azContext.Environment.ResourceManagerUrl.TrimEnd('/')
    $subscriptionsUri = "$resourceManagerUrl/subscriptions?api-version=2025-03-01"

    try {
        $subscriptionsResponse = Invoke-AzRestMethod -Method GET -Uri $subscriptionsUri -ErrorAction Stop

        if ($subscriptionsResponse.StatusCode -eq 403) {
            Write-PSFMessage 'The signed in user does not have access to check subscriptions.' -Level Verbose
            Add-ZtTestResultDetail -SkippedBecause NoAzureAccess
            return
        }

        if ($subscriptionsResponse.StatusCode -ge 400) {
            throw "Subscriptions request failed with status code $($subscriptionsResponse.StatusCode)"
        }

        $subscriptionsContent = $subscriptionsResponse.Content.Value
        if (-not $subscriptionsContent) {
            Add-ZtTestResultDetail -SkippedBecause NotSupported
            return
        }

        $subscriptions = ($subscriptionsContent | ConvertFrom-Json).value
    }
    catch {
        Write-PSFMessage "Unable to enumerate subscriptions: $($_.Exception.Message)" -Tag Firewall -Level Warning
        Add-ZtTestResultDetail -SkippedBecause NoAzureAccess
        return
    }

    $results = @()

    foreach ($sub in $subscriptions) {
        Set-AzContext -SubscriptionId $sub.subscriptionId -ErrorAction SilentlyContinue | Out-Null

        # Query Azure Firewall Policies
        try {
            $policiesUri = "$resourceManagerUrl/subscriptions/$($sub.subscriptionId)/providers/Microsoft.Network/firewallPolicies?api-version=2025-03-01"
            Write-ZtProgress -Activity $activity -Status "Enumerating policies in subscription $($sub.displayName)"

            $policyResponse = Invoke-AzRestMethod -Method GET -Uri $policiesUri -ErrorAction Stop

            if ($policyResponse.StatusCode -eq 403) {
                Write-PSFMessage "Access denied to firewall policies in subscription $($sub.displayName): Insufficient permissions" -Tag Firewall -Level Warning
                continue
            }

            if ($policyResponse.StatusCode -ge 400) {
                throw "Firewall policies request failed with status code $($policyResponse.StatusCode)"
            }

            $policyResponseContent = $policyResponse.Content
            if (-not $policyResponseContent) {
                Write-PSFMessage "No response content for policies in subscription $($sub.displayName)" -Tag Firewall -Level Warning
                continue
            }

            $policies = ($policyResponseContent | ConvertFrom-Json).value
        }
        catch {
            Write-PSFMessage "Unable to enumerate firewall policies in subscription $($sub.displayName): $($_.Exception.Message)" -Tag Firewall -Level Warning
            continue
        }

        if (-not $policies) { continue }

        # Step 3: Get individual firewall policy details
        $detailedPolicies = @()
        foreach ($policyResource in $policies) {
            try {
                $detailUri = "$resourceManagerUrl$($policyResource.id)?api-version=2025-03-01"
                $detailResponse = Invoke-AzRestMethod -Method GET -Uri $detailUri -ErrorAction Stop

                if ($detailResponse.StatusCode -eq 403) {
                    Write-PSFMessage "Access denied to firewall policy details in subscription $($sub.displayName): Insufficient permissions" -Tag Firewall -Level Warning
                    continue
                }

                if ($detailResponse.StatusCode -ge 400) {
                    throw "Firewall policy details request failed with status code $($detailResponse.StatusCode)"
                }

                $detailResponseContent = $detailResponse.Content
                if (-not $detailResponseContent) {
                    Write-PSFMessage "No response content for policy $($policyResource.name) in subscription $($sub.displayName)" -Tag Firewall -Level Warning
                    continue
                }

                $detailedPolicy = $detailResponseContent | ConvertFrom-Json
                $detailedPolicies += $detailedPolicy
            }
            catch {
                Write-PSFMessage "Unable to get detailed policy information for $($policyResource.name) in subscription $($sub.displayName): $($_.Exception.Message)" -Tag Firewall -Level Warning
            }
        }

        # Check intrusion detection mode for each firewall policy
        foreach ($policyResource in $detailedPolicies) {

            # Skip if policy is missing required properties
            if (-not $policyResource -or -not $policyResource.Name -or -not $policyResource.Id -or -not $policyResource.Properties) {
                Write-PSFMessage "Firewall policy is missing required properties. Skipping." -Tag Firewall -Level Verbose
                continue
            }

            # Skip if SKU tier is not Premium
            if ($policyResource.Properties.sku.tier -ne 'Premium') {
                Write-PSFMessage "Firewall policy '$($policyResource.name)' does not have Premium SKU. Skipping." -Tag Firewall -Level Verbose
                continue
            }

            # Get intrusion detection mode - if not configured, it's disabled by default (FAIL)
            $idMode = if ($policyResource.Properties.intrusionDetection) {
                $policyResource.Properties.intrusionDetection.mode
            } else {
                'Off'
            }
            # Map intrusion detection mode to user-friendly display values
            $detectionModeDisplay = switch ($idMode) {
                'Deny' { 'Alert and Deny' }
                'Alert' { 'Alert Only' }
                'Off' { 'Disabled' }
            }

            $subContext = Get-AzContext

            $results += [PSCustomObject]@{
                PolicyName             = $policyResource.Name
                SubscriptionName       = $subContext.Subscription.Name
                SubscriptionId         = $subContext.Subscription.Id
                IntrusionDetectionMode = $detectionModeDisplay
                PolicyID               = $policyResource.Id
                Passed                 = $idMode -eq 'Deny'
            }
        }
    }
    #endregion Data Collection

    #region Assessment Logic

    # If no Premium firewall policies found, skip the test
    if ($results.Count -eq 0) {
        Write-PSFMessage 'No Azure Firewall Premium policies found to evaluate.' -Tag Firewall -Level Verbose
        Add-ZtTestResultDetail -SkippedBecause NotSupported
        return
    }

    $failedPolicies = @($results | Where-Object { -not $_.Passed })
    $passed = $failedPolicies.Count -eq 0

    if ($passed) {
        $testResultMarkdown = "Intrusion Detection System (IDPS) inspection is set to Deny for Azure Firewall policies.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "Intrusion Detection System (IDPS) inspection is not set to Deny for Azure Firewall policies.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    $reportTitle = "Firewall policies"
    $tableRows = ""
    $mdInfo = ""

    if ($results.Count -gt 0) {
        # Create a here-string with format placeholders {0}, {1}, etc.
        $formatTemplate = @'

## {0}

| Policy name | Subscription name | Result |
| :--- | :--- | :--- |
{1}

'@

        foreach ($item in $results | Sort-Object PolicyName) {
            $policyLink = "https://portal.azure.com/#resource$($item.PolicyID)"
            $subLink = "https://portal.azure.com/#resource/subscriptions/$($item.SubscriptionId)"
            $policyMd = "[$(Get-SafeMarkdown -Text $item.PolicyName)]($policyLink)"
            $subMd = "[$(Get-SafeMarkdown -Text $item.SubscriptionName)]($subLink)"
            $icon = if ($item.Passed) { '✅' } else { '❌' }
            $resultText = "$icon $($item.IntrusionDetectionMode)"
            $tableRows += "| $policyMd | $subMd | $resultText |`n"
        }

        # Format the template by replacing placeholders with values
        $mdInfo = $formatTemplate -f $reportTitle, $tableRows
    }

    # Replace the placeholder with the detailed information
    $testResultMarkdown = $testResultMarkdown -replace "%TestResult%", $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '25539'
        Status = $passed
        Result = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
