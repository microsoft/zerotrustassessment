<#
.SYNOPSIS
    Validates that Network Security Groups do not allow inbound traffic on insecure ports.

.DESCRIPTION
    This test checks all NSGs across the tenant for inbound Allow rules targeting
    commonly exploited ports (FTP, Telnet, RDP, SSH, SMB, RPC) or wildcard (*) rules.
    These ports are frequent attack vectors and should be restricted or replaced with
    more secure alternatives like Azure Bastion or Just-in-Time VM Access.

.NOTES
    Test ID: 35042
    Category: Azure Network Security
    Required API: Azure Management API - Network Security Groups
#>

function Test-Assessment-35042 {
    [ZtTest(
        Category = 'Azure Network Security',
        ImplementationCost = 'Medium',
        MinimumLicense = ('Azure Virtual Network'),
        Pillar = 'Network',
        RiskLevel = 'High',
        SfiPillar = 'Protect networks',
        TenantType = ('Workforce', 'External'),
        TestId = 35042,
        Title = "Network Security Groups do not allow inbound traffic on insecure ports",
        UserImpact = 'Medium'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking NSG inbound rules for insecure ports'

    # Check if connected to Azure
    Write-ZtProgress -Activity $activity -Status 'Checking Azure connection'

    $azContext = Get-AzContext -ErrorAction SilentlyContinue
    if (-not $azContext) {
        Write-PSFMessage 'Not connected to Azure.' -Level Warning
        Add-ZtTestResultDetail -SkippedBecause NotConnectedAzure
        return
    }

    Write-ZtProgress -Activity $activity -Status 'Querying Azure Resource Graph'

    # Query NSGs for inbound Allow rules on insecure ports
    # Insecure ports: FTP(21), Telnet(23), SSH(22), RDP(3389), SMB(445), RPC(135,139), Wildcard(*)
    $argQuery = @"
resources
| where type =~ 'microsoft.network/networksecuritygroups'
| join kind=leftouter (
    resourcecontainers
    | where type =~ 'microsoft.resources/subscriptions'
    | project subscriptionName=name, subscriptionId
) on subscriptionId
| mv-expand rule = properties.securityRules
| where rule.properties.access =~ 'Allow'
    and rule.properties.direction =~ 'Inbound'
| where rule.properties.destinationPortRange in ('21', '23', '22', '3389', '445', '135', '139', '*')
| project
    NsgName = name,
    NsgId = id,
    SubscriptionName = subscriptionName,
    SubscriptionId = subscriptionId,
    RuleName = tostring(rule.name),
    Port = tostring(rule.properties.destinationPortRange),
    Priority = toint(rule.properties.priority),
    SourceAddress = tostring(rule.properties.sourceAddressPrefix)
"@

    $rules = @()
    try {
        $rules = @(Invoke-ZtAzureResourceGraphRequest -Query $argQuery)
        Write-PSFMessage "ARG Query returned $($rules.Count) records" -Tag Test -Level VeryVerbose
    }
    catch {
        Write-PSFMessage "Azure Resource Graph query failed: $($_.Exception.Message)" -Tag Test -Level Warning
        Add-ZtTestResultDetail -SkippedBecause NotSupported
        return
    }
    #endregion Data Collection

    #region Check NSG existence
    # Also query total NSG count to differentiate "no NSGs" from "no insecure rules"
    $nsgCountQuery = @"
resources
| where type =~ 'microsoft.network/networksecuritygroups'
| summarize Count=count()
"@

    $nsgCount = 0
    try {
        $nsgResult = @(Invoke-ZtAzureResourceGraphRequest -Query $nsgCountQuery)
        if ($nsgResult.Count -gt 0) {
            $nsgCount = $nsgResult[0].Count
        }
    }
    catch {
        Write-PSFMessage "NSG count query failed: $($_.Exception.Message)" -Tag Test -Level Warning
    }

    if ($nsgCount -eq 0) {
        Write-PSFMessage 'No Network Security Groups found.' -Tag Test -Level Verbose
        Add-ZtTestResultDetail -SkippedBecause NotApplicable
        return
    }
    #endregion Check NSG existence

    #region Assessment Logic
    $passed = $rules.Count -eq 0

    # Map port numbers to protocol names for readable output
    $portNames = @{
        '21'   = 'FTP'
        '22'   = 'SSH'
        '23'   = 'Telnet'
        '135'  = 'RPC'
        '139'  = 'NetBIOS'
        '445'  = 'SMB'
        '3389' = 'RDP'
        '*'    = 'All Ports'
    }

    if ($passed) {
        $testResultMarkdown = "✅ No Network Security Groups allow inbound traffic on insecure ports.`n`n%TestResult%"
    }
    else {
        $testResultMarkdown = "❌ One or more Network Security Groups allow inbound traffic on insecure ports.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    $tableRows = ''
    foreach ($item in $rules | Sort-Object SubscriptionName, NsgName, Priority) {
        $nsgLink = "https://portal.azure.com/#resource$($item.NsgId)"
        $subLink = "https://portal.azure.com/#resource/subscriptions/$($item.SubscriptionId)"
        $nsgMd = "[$(Get-SafeMarkdown $item.NsgName)]($nsgLink)"
        $subMd = "[$(Get-SafeMarkdown $item.SubscriptionName)]($subLink)"
        $protocolName = if ($portNames.ContainsKey($item.Port)) { $portNames[$item.Port] } else { $item.Port }
        $portDisplay = "❌ $($item.Port) ($protocolName)"
        $sourceDisplay = if ($item.SourceAddress -eq '*') { 'Any' } else { $item.SourceAddress }

        $tableRows += "| $nsgMd | $subMd | $(Get-SafeMarkdown $item.RuleName) | $portDisplay | $sourceDisplay | $($item.Priority) |`n"
    }

    $formatTemplate = @'


## [{0}]({1})

| NSG name | Subscription | Rule name | Port | Source | Priority |
| :------- | :----------- | :-------- | :--: | :----- | :------: |
{2}

'@
    $reportTitle = 'NSG insecure inbound port rules'
    $portalLink = 'https://portal.azure.com/#browse/Microsoft.Network%2FnetworkSecurityGroups'
    $mdInfo = $formatTemplate -f $reportTitle, $portalLink, $tableRows

    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '35042'
        Title  = 'Network Security Groups do not allow inbound traffic on insecure ports'
        Status = $passed
        Result = $testResultMarkdown
    }
    Add-ZtTestResultDetail @params
}
