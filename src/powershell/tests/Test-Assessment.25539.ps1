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
        TenantType = ('Workforce'),
        TestId = 25539,
        Title = 'IDPS Inspection is Enabled in Deny Mode on Azure Firewall',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    #region Data Collection
    $activity = 'Azure Firewall Intrusion Detection'
    Write-ZtProgress `
        -Activity $activity `
        -Status 'Enumerating Firewall Policies'

    # Query subscriptions using REST API
    $resourceManagerUrl = (Get-AzContext).Environment.ResourceManagerUrl.TrimEnd('/')
    $subscriptionsUri = "$resourceManagerUrl/subscriptions?api-version=2020-01-01"

    try {
        $subscriptionsResponse = Invoke-AzRestMethod -Method GET -Uri $subscriptionsUri -ErrorAction Stop
    }
    catch {
        if ($_.Exception.Response.StatusCode -eq 403 -or $_.Exception.Message -like '*403*' -or $_.Exception.Message -like '*Forbidden*') {
            Add-ZtTestResultDetail -SkippedBecause NoAzureAccess
            return
        }
    }

    $subscriptions = ($subscriptionsResponse.Content | ConvertFrom-Json).value

    if (-not $subscriptions) {
        Add-ZtTestResultDetail -SkippedBecause NoResults
        return
    }

    $results = @()

    foreach ($sub in $subscriptions) {

        Set-AzContext -SubscriptionId $sub.subscriptionId -ErrorAction SilentlyContinue | Out-Null

        # Query Azure Firewall Policies
        try {
            $policiesUri = "$resourceManagerUrl/subscriptions/$($sub.subscriptionId)/providers/Microsoft.Network/firewallPolicies?api-version=2023-04-01"
            Write-ZtProgress -Activity $activity -Status "Enumerating policies in subscription $($sub.displayName)"

            $policyResponse = (Invoke-AzRestMethod -Method GET -Uri $policiesUri -ErrorAction Stop).Content | ConvertFrom-Json
            $policies = $policyResponse.value

        }
        catch {
            Write-PSFMessage "Unable to enumerate firewall policies in subscription $($sub.displayName): $($_.Exception.Message)" -Tag Firewall -Level Warning
            continue
        }

        if (-not $policies) { continue }

        # Check intrusion detection mode for each firewall policy
        foreach ($policyResource in $policies) {

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

            $idMode = $policyResource.Properties.intrusionDetection.mode

            $subContext = Get-AzContext

            $results += [PSCustomObject]@{
                PolicyName             = $policyResource.Name
                SubscriptionName       = $subContext.Subscription.Name
                SubscriptionId         = $subContext.Subscription.Id
                IntrusionDetectionMode = $idMode
                PolicyID               = $policyResource.Id
                Passed                 = $idMode -eq 'Deny'
            }
        }
    }
    #endregion Data Collection

    #region Assessment Logic
    if (-not $results) {
        Add-ZtTestResultDetail -SkippedBecause NoResults
        return
    }

    $passed = ($results | Where-Object { -not $_.Passed }).Count -eq 0

    $testResultMarkdown = ''
    $mdInfo = ''

    if ($passed) {
        $testResultMarkdown = "Intrusion Detection System (IDPS) inspection is set to Deny for all Azure Firewall policies.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "Intrusion Detection System (IDPS) inspection is not set to Deny for all Azure Firewall policies.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    $mdInfo += "## Firewall policies`n`n"
    $mdInfo += "| Policy name | Subscription name | IDPS Inspection mode | Result |`n"
    $mdInfo += "| :--- | :--- | :--- | :--- |`n"

    foreach ($item in $results | Sort-Object PolicyName) {
        $policyLink = "https://portal.azure.com/#resource$($item.PolicyID)"
        $subLink = "https://portal.azure.com/#resource/subscriptions/$($item.SubscriptionId)"
        $policyMd = "[$(Get-SafeMarkdown -Text $item.PolicyName)]($policyLink)"
        $subMd = "[$(Get-SafeMarkdown -Text $item.SubscriptionName)]($subLink)"
        $icon = if ($item.Passed) { '✅' } else { '❌' }
        $mdInfo += "| $policyMd | $subMd | $($item.IntrusionDetectionMode) | $icon |`n"
    }

    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '25539'
        Title  = 'IDPS Inspection is Enabled in Deny Mode on Azure Firewall'
        Status = $passed
        Result = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
