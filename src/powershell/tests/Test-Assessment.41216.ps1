<#
.SYNOPSIS
    Microsoft Security Copilot SCU consumption is monitored and alerted on through Cost Management

.DESCRIPTION
    Discovers Microsoft Security Copilot capacity resources via Azure Resource Graph, then for each
    subscription that hosts a capacity confirms that Cost Management is billing the capacity (Query -
    Usage) and that at least one Consumption budget with qualifying notifications targets the capacity,
    its resource group, or the subscription.

.NOTES
    Test ID: 41216
    Workshop Task: SECOPS_111
    Pillar: SecOps
    Category: AI for security
    Required APIs:
        - Azure Resource Graph (management.azure.com) — capacity discovery
        - Cost Management Query - Usage (Microsoft.CostManagement/query) — subscription scope
        - Consumption Budgets - List (Microsoft.Consumption/budgets) — subscription scope
#>

function Test-Assessment-41216 {
    [ZtTest(
        Category = 'AI for security',
        ImplementationCost = 'Low',
        Service = ('Azure'),
        MinimumLicense = ('Consumption-based: Microsoft Security Copilot'),
        Pillar = 'SecOps',
        RiskLevel = 'Medium',
        SfiPillar = 'Monitor and detect cyberthreats',
        TenantType = ('Workforce'),
        TestId = 41216,
        Title = 'Microsoft Security Copilot SCU consumption is monitored and alerted on through Cost Management',
        UserImpact = 'Low'
    )]
    [CmdletBinding()]
    param()

    #region Data Collection
    Write-PSFMessage '🟦 Start' -Tag Test -Level VeryVerbose

    $activity = 'Checking Security Copilot SCU consumption monitoring'
    $capacityType = 'microsoft.securitycopilot/capacities'

    # Discovery: enumerate Security Copilot capacity resources across all accessible subscriptions via
    # Azure Resource Graph. This check is self-contained and does not depend on any other spec's output.
    Write-ZtProgress -Activity $activity -Status 'Discovering Security Copilot capacities via Resource Graph'

    $argQuery = @"
resources
| where type =~ '$capacityType'
| join kind=leftouter (
    resourcecontainers
    | where type =~ 'microsoft.resources/subscriptions'
    | where properties.state =~ 'Enabled'
    | project subscriptionId, subscriptionName = name
) on subscriptionId
| project id, name, location, resourceGroup, subscriptionId, subscriptionName, provisioningState = tostring(properties.provisioningState)
"@

    $capacities = @()
    try {
        $capacities = @(Invoke-ZtAzureResourceGraphRequest -Query $argQuery)
        Write-PSFMessage "ARG query returned $($capacities.Count) Security Copilot capacity resource(s)" -Tag Test -Level VeryVerbose
    }
    catch {
        Write-PSFMessage "Azure Resource Graph query failed: $($_.Exception.Message)" -Tag Test -Level Warning
        # Invoke-ZtAzureResourceGraphRequest throws "Azure REST request failed with status <code>: ..."
        $httpStatus = $null
        if ($_.Exception.Message -match 'with status (\d+):') { $httpStatus = [int]$Matches[1] }
        $result = if ($httpStatus -in @(401, 403)) {
            '⚠️ Azure Resource Graph returned an authorization error while discovering Security Copilot capacities. Grant the assessing identity at least Reader on the subscriptions being evaluated, then re-run the assessment.'
        }
        else {
            '⚠️ Azure Resource Graph returned an unexpected error while discovering Security Copilot capacities. This is likely transient; re-run the assessment.'
        }
        $params = @{
            TestId       = '41216'
            Title        = 'Microsoft Security Copilot SCU consumption is monitored and alerted on through Cost Management'
            Status       = $false
            Result       = $result
            CustomStatus = 'Investigate'
        }
        Add-ZtTestResultDetail @params
        return
    }

    # Spec: no capacity resources in the tenant -> Skipped (NotApplicable).
    if ($capacities.Count -eq 0) {
        Write-PSFMessage 'No Security Copilot capacity resources found — skipping.' -Tag Test -Level VeryVerbose
        Add-ZtTestResultDetail -SkippedBecause NotApplicable
        return
    }

    # Q1 + Q2: for each subscription that hosts a capacity, pull the last 30 days of Cost Management
    # usage for the capacity resource type and the list of Consumption budgets.
    $costFrom = (Get-Date).ToUniversalTime().AddDays(-30).ToString('yyyy-MM-ddTHH:mm:ssZ')
    $costTo = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')

    $costQueryBody = @{
        type       = 'ActualCost'
        timeframe  = 'Custom'
        timePeriod = @{ from = $costFrom; to = $costTo }
        dataset    = @{
            granularity = 'Daily'
            aggregation = @{ totalCost = @{ name = 'Cost'; function = 'Sum' } }
            grouping    = @(
                @{ type = 'Dimension'; name = 'ResourceId' }
                @{ type = 'Dimension'; name = 'ResourceType' }
            )
            filter      = @{
                dimensions = @{ name = 'ResourceType'; operator = 'In'; values = @($capacityType) }
            }
        }
    } | ConvertTo-Json -Depth 10

    $subscriptionIds = @($capacities | Select-Object -ExpandProperty subscriptionId -Unique)
    $subscriptionData = @{}

    foreach ($subscriptionId in $subscriptionIds) {
        $subEntry = [PSCustomObject]@{
            CostByResourceId = @{}   # lowercased resourceId -> aggregate
            Budgets          = @()
            Q1AuthError      = $false
            Q1Failed         = $false
            Q2AuthError      = $false
            Q2Failed         = $false
        }

        # Q1: Cost Management Query - Usage (POST). Follow properties.nextLink until exhausted.
        Write-ZtProgress -Activity $activity -Status "Querying Cost Management usage for subscription $subscriptionId"
        $costPath = "/subscriptions/$subscriptionId/providers/Microsoft.CostManagement/query?api-version=2025-03-01"
        $nextUri = $null
        $firstPage = $true
        try {
            do {
                if ($firstPage) {
                    $response = Invoke-ZtAzureRequest -Path $costPath -Method POST -Payload $costQueryBody -FullResponse
                    $firstPage = $false
                }
                else {
                    $response = Invoke-ZtAzureRequest -Uri $nextUri -Method POST -Payload $costQueryBody -FullResponse
                }

                if ($response.StatusCode -in @(401, 403)) {
                    $subEntry.Q1AuthError = $true
                    break
                }
                if ($response.StatusCode -ge 400) {
                    $subEntry.Q1Failed = $true
                    break
                }

                $parsed = $response.Content | ConvertFrom-Json -ErrorAction Stop
                $columns = @($parsed.properties.columns)
                $colIndex = @{}
                for ($i = 0; $i -lt $columns.Count; $i++) { $colIndex[$columns[$i].name] = $i }

                foreach ($row in @($parsed.properties.rows)) {
                    $resourceId = [string]$row[$colIndex['ResourceId']]
                    if ([string]::IsNullOrWhiteSpace($resourceId)) { continue }
                    $cost = [double]$row[$colIndex['Cost']]
                    $usageDate = if ($colIndex.ContainsKey('UsageDate')) { [string]$row[$colIndex['UsageDate']] } else { '' }
                    $currency = if ($colIndex.ContainsKey('Currency')) { [string]$row[$colIndex['Currency']] } else { '' }

                    $key = $resourceId.ToLowerInvariant()
                    if (-not $subEntry.CostByResourceId.ContainsKey($key)) {
                        $subEntry.CostByResourceId[$key] = [PSCustomObject]@{
                            Total    = 0.0
                            Peak     = 0.0
                            Days     = [System.Collections.Generic.HashSet[string]]::new()
                            Currency = $currency
                        }
                    }
                    $aggregate = $subEntry.CostByResourceId[$key]
                    $aggregate.Total += $cost
                    if ($cost -gt $aggregate.Peak) { $aggregate.Peak = $cost }
                    if ($cost -gt 0 -and $usageDate) { [void]$aggregate.Days.Add($usageDate) }
                    if (-not $aggregate.Currency -and $currency) { $aggregate.Currency = $currency }
                }

                $nextUri = $parsed.properties.nextLink
            } while ($nextUri)
        }
        catch {
            Write-PSFMessage "Cost Management query failed for subscription '$subscriptionId': $($_.Exception.Message)" -Tag Test -Level Warning
            if ($_.Exception.Message -match 'with status (\d+):' -and [int]$Matches[1] -in @(401, 403)) {
                $subEntry.Q1AuthError = $true
            }
            else {
                $subEntry.Q1Failed = $true
            }
        }

        # Q2: Consumption Budgets - List (GET). Invoke-ZtAzureRequest auto-paginates and unwraps .value.
        Write-ZtProgress -Activity $activity -Status "Querying Consumption budgets for subscription $subscriptionId"
        $budgetsPath = "/subscriptions/$subscriptionId/providers/Microsoft.Consumption/budgets?api-version=2024-08-01"
        try {
            $subEntry.Budgets = @(Invoke-ZtAzureRequest -Path $budgetsPath -ErrorAction Stop)
        }
        catch {
            Write-PSFMessage "Consumption budgets query failed for subscription '$subscriptionId': $($_.Exception.Message)" -Tag Test -Level Warning
            if ($_.Exception.Message -match 'with status (\d+):' -and [int]$Matches[1] -in @(401, 403)) {
                $subEntry.Q2AuthError = $true
            }
            else {
                $subEntry.Q2Failed = $true
            }
        }

        $subscriptionData[$subscriptionId] = $subEntry
    }
    #endregion Data Collection

    #region Assessment Logic
    $passed = $false
    $customStatus = $null
    $nowUtc = (Get-Date).ToUniversalTime()

    # Pre-classify each subscription's budgets: which ones have a qualifying notification (enabled,
    # threshold <= 90, GreaterThan[OrEqualTo], with at least one email/role/group recipient) and what
    # scope they target (explicit ResourceIds, resource groups, the capacity type, or the whole
    # subscription when unfiltered).
    foreach ($subscriptionId in $subscriptionData.Keys) {
        $budgetInfos = @()
        foreach ($budget in $subscriptionData[$subscriptionId].Budgets) {
            $qualifyingThresholds = [System.Collections.Generic.List[double]]::new()

            # A budget only alerts while now falls within its timePeriod; an expired or not-yet-started
            # budget cannot fire, so its notifications must not qualify (spec Q2: "active" budgets).
            $budgetActive = $true
            $parsedBudgetDate = [datetime]::MinValue
            if ($budget.properties.timePeriod.startDate -and [datetime]::TryParse([string]$budget.properties.timePeriod.startDate, [ref]$parsedBudgetDate)) {
                if ($parsedBudgetDate.ToUniversalTime() -gt $nowUtc) { $budgetActive = $false }
            }
            if ($budget.properties.timePeriod.endDate -and [datetime]::TryParse([string]$budget.properties.timePeriod.endDate, [ref]$parsedBudgetDate)) {
                if ($parsedBudgetDate.ToUniversalTime() -lt $nowUtc) { $budgetActive = $false }
            }

            $notifications = $budget.properties.notifications
            $notificationEntries = if ($notifications) { @($notifications.PSObject.Properties) } else { @() }
            foreach ($notificationProperty in $notificationEntries) {
                $notification = $notificationProperty.Value
                $enabled = $notification.enabled -eq $true
                $operatorOk = $notification.operator -in @('GreaterThan', 'GreaterThanOrEqualTo')
                $threshold = 0.0
                $thresholdParsed = [double]::TryParse([string]$notification.threshold, [ref]$threshold)
                $hasRecipient = (@($notification.contactEmails).Count -gt 0) -or (@($notification.contactRoles).Count -gt 0) -or (@($notification.contactGroups).Count -gt 0)
                if ($budgetActive -and $enabled -and $operatorOk -and $thresholdParsed -and $threshold -le 90 -and $hasRecipient) {
                    $qualifyingThresholds.Add($threshold)
                }
            }

            # Flatten the filter (which may be a single dimensions block or an `and` of blocks) so a
            # budget scoped by ResourceId, ResourceGroupName, or ResourceType can be matched to a capacity.
            # A ResourceType filter of the capacity type is a superset of the spec's enumerated scopes:
            # it targets every capacity in the subscription, so it counts as monitoring the capacity.
            $resourceIds = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
            $resourceGroups = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
            $targetsCapacityType = $false
            $filter = $budget.properties.filter
            $hasFilter = $null -ne $filter -and $filter.PSObject.Properties.Count -gt 0
            $dimensionBlocks = @()
            if ($filter.dimensions) { $dimensionBlocks += $filter.dimensions }
            if ($filter.and) { foreach ($clause in $filter.and) { if ($clause.dimensions) { $dimensionBlocks += $clause.dimensions } } }
            foreach ($dimension in $dimensionBlocks) {
                switch ($dimension.name) {
                    'ResourceId' { foreach ($value in @($dimension.values)) { [void]$resourceIds.Add([string]$value) } }
                    'ResourceGroupName' { foreach ($value in @($dimension.values)) { [void]$resourceGroups.Add([string]$value) } }
                    'ResourceType' { if (@($dimension.values) -contains $capacityType) { $targetsCapacityType = $true } }
                }
            }

            $budgetInfos += [PSCustomObject]@{
                Name                 = $budget.name
                Amount               = $budget.properties.amount
                Unit                 = $budget.properties.currentSpend.unit
                TimeGrain            = $budget.properties.timeGrain
                QualifyingThresholds = @($qualifyingThresholds | Sort-Object -Unique)
                TargetsSubscription  = -not $hasFilter
                TargetsCapacityType  = $targetsCapacityType
                ResourceIds          = $resourceIds
                ResourceGroups       = $resourceGroups
            }
        }
        $subscriptionData[$subscriptionId] | Add-Member -NotePropertyName BudgetInfos -NotePropertyValue $budgetInfos -Force
    }

    # Evaluate each discovered capacity.
    $results = foreach ($capacity in $capacities) {
        $subEntry = $subscriptionData[$capacity.subscriptionId]
        $isDeleting = $capacity.provisioningState -in @('Deleting', 'Deleted')

        $totalCost = $null
        $currency = $null
        $daysBilled = $null
        $peakCost = $null
        $budgetName = $null
        $budgetAmount = $null
        $budgetUnit = $null
        $timeGrain = $null
        $thresholds = $null

        $q1Blocked = $subEntry.Q1AuthError -or $subEntry.Q1Failed
        $q2Blocked = $subEntry.Q2AuthError -or $subEntry.Q2Failed

        if (-not $q1Blocked) {
            $aggregate = $subEntry.CostByResourceId[$capacity.id.ToLowerInvariant()]
            if ($aggregate) {
                $totalCost = [math]::Round($aggregate.Total, 2)
                $currency = $aggregate.Currency
                $daysBilled = $aggregate.Days.Count
                $peakCost = [math]::Round($aggregate.Peak, 2)
            }
            else {
                $totalCost = 0.0
                $daysBilled = 0
                $peakCost = 0.0
            }
        }

        # Find the first qualifying budget in the capacity's subscription that targets this capacity,
        # its resource group, the capacity type, or the whole subscription (unfiltered).
        $matchingBudget = $null
        if (-not $q2Blocked) {
            foreach ($budgetInfo in $subEntry.BudgetInfos) {
                if ($budgetInfo.QualifyingThresholds.Count -eq 0) { continue }
                $targetsCapacity = $budgetInfo.TargetsSubscription -or
                    $budgetInfo.TargetsCapacityType -or
                    $budgetInfo.ResourceIds.Contains($capacity.id) -or
                    $budgetInfo.ResourceGroups.Contains($capacity.resourceGroup)
                if ($targetsCapacity) { $matchingBudget = $budgetInfo; break }
            }
        }

        if ($matchingBudget) {
            $budgetName = $matchingBudget.Name
            $budgetAmount = $matchingBudget.Amount
            $budgetUnit = $matchingBudget.Unit
            $timeGrain = $matchingBudget.TimeGrain
            $thresholds = ($matchingBudget.QualifyingThresholds | ForEach-Object { "$_%" }) -join ', '
        }

        $hasCost = ($totalCost -gt 0)
        $rowResult =
            if ($q1Blocked -or $q2Blocked) { '⚠️ Investigate' }
            elseif (-not $hasCost) { if ($isDeleting) { '⚠️ Deleting' } else { '⚠️ Investigate' } }
            elseif ($matchingBudget) { '✅ Pass' }
            else { '❌ Fail' }

        [PSCustomObject]@{
            Name              = $capacity.name
            Id                = $capacity.id
            ResourceGroup     = $capacity.resourceGroup
            SubscriptionId    = $capacity.subscriptionId
            SubscriptionName  = $capacity.subscriptionName
            ProvisioningState = $capacity.provisioningState
            TotalCost         = $totalCost
            Currency          = $currency
            DaysBilled        = $daysBilled
            PeakCost          = $peakCost
            BudgetName        = $budgetName
            BudgetAmount      = $budgetAmount
            BudgetUnit        = $budgetUnit
            TimeGrain         = $timeGrain
            Thresholds        = $thresholds
            Blocked           = ($q1Blocked -or $q2Blocked)
            RowResult         = $rowResult
        }
    }

    # Aggregate across every active (non-deleting) capacity with fail > investigate > pass precedence;
    # pass only when every active capacity is monitored. A single passing capacity must not mask
    # another capacity that is unmonitored (Fail) or unreadable / not yet consuming (Investigate).
    $activeResults = @($results | Where-Object { $_.ProvisioningState -notin @('Deleting', 'Deleted') })
    $failRows = @($activeResults | Where-Object { $_.RowResult -eq '❌ Fail' })
    $passRows = @($activeResults | Where-Object { $_.RowResult -eq '✅ Pass' })
    $investigateRows = @($activeResults | Where-Object { $_.RowResult -eq '⚠️ Investigate' })
    $blockedRows = @($activeResults | Where-Object { $_.Blocked })
    $noCostRows = @($activeResults | Where-Object { -not $_.Blocked -and $_.TotalCost -le 0 })

    if ($failRows.Count -gt 0) {
        # Fail wins: at least one active capacity has consumption but no qualifying budget targets it.
        $testResultMarkdown = "❌ One or more Security Copilot capacities have consumption flowing through Cost Management but no budget with qualifying notifications (enabled, threshold ≤ 90%, with an email, role, or action-group recipient) targeting the capacity, its resource group, or the subscription.`n`n%TestResult%"
    }
    elseif ($passRows.Count -gt 0 -and $investigateRows.Count -eq 0) {
        # Every active capacity is monitored.
        $passed = $true
        $testResultMarkdown = "✅ Microsoft Security Copilot SCU consumption is visible through Cost Management and every capacity is covered by a budget with notifications.`n`n%TestResult%"
    }
    elseif ($blockedRows.Count -gt 0 -and $passRows.Count -eq 0 -and $noCostRows.Count -eq 0) {
        # No capacity could be evaluated because every hosting subscription returned a read/auth error.
        $customStatus = 'Investigate'
        $testResultMarkdown = "⚠️ Cost Management usage or budgets could not be read for the subscription(s) that host a Security Copilot capacity. Grant the assessing identity Cost Management Reader (or Reader) on those subscriptions, then re-run the assessment.`n`n%TestResult%"
    }
    else {
        # Remaining cases are all Investigate: capacities with no billed consumption (Copilot not yet
        # adopted, or the Microsoft 365 E5 inclusion path with no chargeable Azure resource), read
        # errors on some subscriptions, or a pass/investigate mix that prevents confirming every capacity.
        $customStatus = 'Investigate'
        $testResultMarkdown = "⚠️ One or more Security Copilot capacities could not be confirmed as monitored: Cost Management shows no billed consumption for them, or their usage or budgets could not be read. Validate enablement and consumption in the Security Copilot usage monitoring dashboard, and review the capacities marked Investigate below.`n`n%TestResult%"
    }
    #endregion Assessment Logic

    #region Report Generation
    $budgetsPortalUrl = 'https://portal.azure.com/#view/Microsoft_Azure_CostManagement/Menu/~/budgets'

    $tableRows = ''
    foreach ($item in $results | Sort-Object Name) {
        $nameLink = "[$(Get-SafeMarkdown $item.Name)](https://portal.azure.com/#resource$($item.Id))"
        $subscriptionDisplay = if (-not [string]::IsNullOrWhiteSpace($item.SubscriptionName)) { Get-SafeMarkdown $item.SubscriptionName } else { $item.SubscriptionId }

        $costDisplay = if ($null -eq $item.TotalCost) { '—' } elseif ($item.Currency) { '{0:N2} {1}' -f $item.TotalCost, $item.Currency } else { '{0:N2}' -f $item.TotalCost }
        $trendDisplay = if ($null -eq $item.DaysBilled) { '—' } elseif ($item.DaysBilled -eq 0) { 'No billed days' } else { "$($item.DaysBilled) day(s), peak {0:N2}" -f $item.PeakCost }
        $budgetDisplay = if ($item.BudgetName) { Get-SafeMarkdown $item.BudgetName } else { '—' }
        $amountDisplay = if ($null -eq $item.BudgetAmount) { '—' } elseif ($item.BudgetUnit) { '{0:N2} {1}' -f $item.BudgetAmount, $item.BudgetUnit } else { '{0:N2}' -f $item.BudgetAmount }
        $timeGrainDisplay = if ($item.TimeGrain) { $item.TimeGrain } else { '—' }
        $thresholdDisplay = if ($item.Thresholds) { $item.Thresholds } else { '—' }

        $tableRows += "| $nameLink | $subscriptionDisplay | $costDisplay | $trendDisplay | $budgetDisplay | $amountDisplay | $timeGrainDisplay | $thresholdDisplay | $($item.RowResult) |`n"
    }

    $formatTemplate = @'


## [Security Copilot capacity consumption and budgets]({0})

| Capacity | Subscription | Cost (30d) | Daily trend | Budget | Amount | Time grain | Alert thresholds | Result |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
{1}

'@

    $mdInfo = $formatTemplate -f $budgetsPortalUrl, $tableRows
    $testResultMarkdown = $testResultMarkdown -replace '%TestResult%', $mdInfo
    #endregion Report Generation

    $params = @{
        TestId = '41216'
        Title  = 'Microsoft Security Copilot SCU consumption is monitored and alerted on through Cost Management'
        Status = $passed
        Result = $testResultMarkdown
    }
    if ($null -ne $customStatus) {
        $params.CustomStatus = $customStatus
    }

    Add-ZtTestResultDetail @params
}
