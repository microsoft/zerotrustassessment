
<#
 .SYNOPSIS
     Validates Threat intelligence is Enabled in Deny Mode on Azure Firewall.
 .DESCRIPTION
     This test validates that Azure Firewall Policies have Threat Intelligence enabled in Deny mode.
     Checks all firewall policies in the subscription and reports their threat intelligence status.
 .NOTES
     Test ID: 25537
     Category: Azure Network Security
     Required API: Azure Firewall Policies
 #>

function Test-Assessment-25537 {
    [ZtTest(
        Category = 'Azure Network Security',
        ImplementationCost = 'Low',
        MinimumLicense = ('Azure_Firewall_Standard', 'Azure_Firewall_Premium'),
        Pillar = 'Network',
        RiskLevel = 'High',
        SfiPillar = 'Protect networks',
        TenantType = ('Workforce'),
        TestId = 25537,
        Title = 'Threat intelligence is Enabled in Deny Mode on Azure Firewall',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    #region Data Collection
    $activity = 'Azure Firewall Threat Intelligence'
    Write-ZtProgress  -Activity $activity -Status 'Enumerating Firewall Policies'

    # Query 1: List all subscriptions
    $context = Get-AzContext
    if (($context).Environment.name -ne 'AzureCloud') {
        Write-PSFMessage "This test is only applicable to the Global environment." -Tag Test -Level VeryVerbose
        Add-ZtTestResultDetail -SkippedBecause NotSupported
        return
    }

    try {
        $accessToken = Get-AzAccessToken -AsSecureString -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
    }
    catch {
        Write-PSFMessage $_.Exception.Message -Tag Test -Level Error
    }

    if (-not $accessToken) {
        Write-PSFMessage "Azure authentication token not found." -Tag Test -Level Warning
        Add-ZtTestResultDetail -SkippedBecause 'NotConnectedAzure'
        return
    }
    $resourceManagerUrl = ($context).Environment.ResourceManagerUrl.TrimEnd('/')
    $subscriptionsUri = "$resourceManagerUrl/subscriptions?api-version=2025-03-01"

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
        Add-ZtTestResultDetail -SkippedBecause NoAzureAccess
        return
    }
    $results = @()
    foreach ($sub in $subscriptions) {

        Set-AzContext -SubscriptionId $sub.subscriptionId | Out-Null

        # Query 2 : List Azure Firewall Policies
        try {
            $policiesUri = "$resourceManagerUrl/subscriptions/$($sub.subscriptionId)/providers/Microsoft.Network/firewallPolicies?api-version=2025-03-01"
            Write-ZtProgress -Activity $activity -Status "Enumerating policies in subscription $($sub.displayName)"

            $policyResponse = (Invoke-AzRestMethod -Method GET -Uri $policiesUri -ErrorAction Stop ).Content | ConvertFrom-Json
            $policies = $policyResponse.value

        }
        catch {
            Write-PSFMessage "Unable to enumerate firewall policies in subscription $($sub.displayName): $($_.Exception.Message)" -Tag Firewall -Level Warning
            continue
        }

        if (-not $policies) {
            continue
        }

        # Query 2: Get details for each firewall policy and check threatIntelMode
        foreach ($policyResource in $policies) {

            $threatIntelMode = $policyResource.Properties.threatIntelMode

            $subContext = Get-AzContext

            $results += [PSCustomObject]@{
                PolicyName       = $policyResource.Name
                SubscriptionName = $subContext.Subscription.Name
                SubscriptionId   = $subContext.Subscription.Id
                ThreatIntelMode  = $threatIntelMode
                PolicyID         = $policyResource.Id
                Passed           = $threatIntelMode -eq 'Deny'
            }
        }
    }
    #endregion Data Collection

    #region Assessment Logic


    $passed = ($results | Where-Object { -not $_.Passed }).Count -eq 0
    $allAlert = ($results | Where-Object { $_.ThreatIntelMode -ne 'Alert' }).Count -eq 0

    $testResultMarkdown = if ($passed) {
        "Threat Intel is enabled in **Alert and Deny** mode.`n`n%TestResult%"
    }
    elseif ($allAlert) {
        "Threat Intel is enabled in **Alert** mode.`n`n%TestResult%"
    }
    else {
        "Threat Intel is not enabled in **Alert and Deny** mode for all Firewall policies.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    $mdInfo = "## Firewall policies`n`n"
    $mdInfo += "| Policy name | Subscription name | Threat Intel mode | Result |`n"
    $mdInfo += "| :--- | :--- | :--- | :--- |`n"

    foreach ($item in $results | Sort-Object PolicyName) {
        $policyLink = "https://portal.azure.com/#resource$($item.PolicyID)"
        $subLink = "https://portal.azure.com/#resource/subscriptions/$($item.SubscriptionId)"
        $policyMd = "[$(Get-SafeMarkdown -Text $item.PolicyName)]($policyLink)"
        $subMd = "[$(Get-SafeMarkdown -Text $item.SubscriptionName)]($subLink)"
        $icon = if ($item.Passed) {
            '✅'
        }
        else {
            '❌'
        }
        $mdInfo += "| $policyMd | $subMd | $($item.ThreatIntelMode) | $icon |`n"
    }

    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation
    $params = @{
        TestId = '25537'
        Title  = 'Threat intelligence is Enabled in Deny Mode on Azure Firewall'
        Status = $passed
        Result = $testResultMarkdown
    }

    Add-ZtTestResultDetail @params
}
